!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module testfld
!
! Unit tests for the flux-limited diffusion lambda used with the
! radiative-approximation cooling (icooling = 9, doFLD).
!
! :References: Forgan et al. (2009), MNRAS 394, 882
!
! :Owner: will-roscoe
!
! :Runtime parameters: None
!
! :Dependencies: boundary, datafiles, deriv, dim, densityforce, eos, eos_stamatellos,
!   io, part, physcon, testutils, unifdis, units
!
 implicit none
 public :: test_fld

 private

contains

subroutine test_fld(ntests,npass)
 use io, only:id,master
 integer, intent(inout) :: ntests,npass

 if (id==master) write(*,"(/,a,/)") '--> TESTING FLUX-LIMITED DIFFUSION LAMBDA'
 call test_limiter(ntests,npass)
 call test_gradh_fallback(ntests,npass)
 call test_first_pass(ntests,npass)
 call test_fld_switch(ntests,npass)
 call test_diffusion_rate(ntests,npass)
 call test_fld_conservation(ntests,npass)
 call test_lambda_inactive(ntests,npass)

end subroutine test_fld

!-----------------------------------------------------------------------
! lambda(R) = (2 + R)/(6 + 3R + R^2): 1/3 in the diffusion limit,
! -> 1/R in the free-streaming limit, decreasing in between
!-----------------------------------------------------------------------
subroutine test_limiter(ntests,npass)
 use densityforce, only:fld_limiter
 use testutils,    only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(3),i
 real    :: r,prev
 logical :: monotone

 nfail(:) = 0
 call checkval(fld_limiter(0.),1./3.,epsilon(0.),nfail(1),'lambda(0) = 1/3 (optically thick)')
 call checkval(1.e6*fld_limiter(1.e6),1.,1.e-5,nfail(2),'R*lambda(R) -> 1 (free streaming)')
 monotone = .true.
 prev = fld_limiter(0.)
 do i=1,200
    r = 0.1*i
    if (fld_limiter(r) >= prev) monotone = .false.
    prev = fld_limiter(r)
 enddo
 call checkval(monotone,.true.,nfail(3),'lambda decreases with R')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_limiter

!-----------------------------------------------------------------------
! a non-positive stored gradh (1/Omega with Omega < 0) is replaced by 1,
! and that replacement is what the gradient then uses
!-----------------------------------------------------------------------
subroutine test_gradh_fallback(ntests,npass)
 use densityforce, only:fld_gradh
 use testutils,    only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(4),nbad

 nfail(:) = 0
 nbad = 0
 call checkval(fld_gradh(real(1.3,kind=4),nbad),real(real(1.3,kind=4)),0.,nfail(1),'positive gradh used as stored')
 call checkval(fld_gradh(0._4,nbad),1.,0.,nfail(2),'zero gradh replaced by 1')
 call checkval(fld_gradh(-2._4,nbad),1.,0.,nfail(3),'negative gradh replaced by 1')
 call checkval(nbad,2,0,nfail(4),'replacements counted')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_gradh_fallback

!-----------------------------------------------------------------------
! lambda from the first density pass of a run must see the temperature
! gradient and must not depend on the gradh left by a previous pass
! (there is none on a fresh start or a restart: gradh is not dumped)
!-----------------------------------------------------------------------
subroutine test_first_pass(ntests,npass)
 use boundary,        only:set_boundary,xmin,xmax,ymin,ymax,zmin,zmax,dxbound,dybound,dzbound
 use deriv,           only:get_derivs_global
 use dim,             only:maxp,maxphase,periodic
 use datafiles,       only:find_phantom_datafile
 use eos,             only:ieos,icooling,init_eos,finish_eos,gamma
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep,lambda_FLD
 use io,              only:id,master
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact, &
                           iphase,isetphase,igas,gradh
 use physcon,         only:solarm,au,pi
 use testutils,       only:checkval,update_test_scores
 use unifdis,         only:set_unifdis
 use units,           only:set_units,unit_density,unit_ergg
 integer, intent(inout) :: ntests,npass
 integer :: nfail(5),ierr,i,ninner,nsteep,ieos_old,icooling_old
 real    :: gamma_old,psep,rho_cgs,totmass,T,u_cgs,x,diffmax,lammax_steep,lammin,lam_uniform_err
 real, allocatable :: lam1(:)
 logical :: doFLD_old
 character(len=120) :: pdir

 ! the opacity table is found under PHANTOM_DIR/data (or downloaded) as in test_eos_stam
 call get_environment_variable('PHANTOM_DIR',pdir)
 if (len_trim(pdir) == 0 .or. len_trim(find_phantom_datafile(eos_file,'eos/lombardi')) == 0) then
    if (id==master) write(*,"(a)") '  --> skipping first-pass lambda test (no opacity table)'
    return
 endif

 if (id==master) write(*,"(/,a)") '--> first density pass of a run: lambda sees the gradient'
 ieos_old = ieos; icooling_old = icooling; doFLD_old = doFLD; gamma_old = gamma
 ieos = 24; icooling = 9; doFLD = .true.; gamma = 5./3.   ! as setup_disc sets for lumdisc
 call set_units(mass=solarm,dist=au,G=1.d0)
 ! the normal path: reads the table and allocates the cooling stores once
 call init_eos(ieos,ierr)
 if (ierr /= 0) then
    if (id==master) write(*,"(a)") '  --> skipping first-pass lambda test (init_eos failed)'
    ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
    return
 endif
 call init_part()
 call set_boundary(-0.5,0.5,-0.5,0.5,-0.5,0.5)
 psep = dxbound/16.
 npart = 0
 call set_unifdis('cubic',id,master,xmin,xmax,ymin,ymax,zmin,zmax,psep,hfact,npart,xyzh,periodic)
 npartoftype(:) = 0
 npartoftype(igas) = npart
 rho_cgs = 1.e-12
 totmass = rho_cgs/unit_density*dxbound*dybound*dzbound
 massoftype(igas) = totmass/npart
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,iactive=.true.)
 allocate(lam1(npart))

 ! T(x) = 30 K (1 + 0.5 sin 2 pi x): a known gradient, periodic in the box
 do i=1,npart
    T = 30.*(1. + 0.5*sin(2.*pi*xyzh(1,i)/dxbound))
    call getintenerg_opdep(T,rho_cgs,u_cgs)
    vxyzu(4,i) = u_cgs/unit_ergg
 enddo

 gradh(:,1:npart) = 0.        ! as on any fresh start or restart
 call get_derivs_global()
 lam1(1:npart) = lambda_FLD(1:npart)
 call get_derivs_global()      ! same state, gradh now from the pass above

 nfail(:) = 0
 ninner = 0; nsteep = 0; diffmax = 0.; lammax_steep = 0.; lammin = huge(0.)
 do i=1,npart
    if (.not.inner(xyzh(:,i))) cycle
    ninner = ninner + 1
    lammin = min(lammin,lam1(i))
    diffmax = max(diffmax,abs(lam1(i) - lambda_FLD(i))/lambda_FLD(i))
    x = 2.*pi*xyzh(1,i)/dxbound
    if (abs(cos(x)) > 0.7) then   ! steepest part of the profile
       nsteep = nsteep + 1
       lammax_steep = max(lammax_steep,lam1(i))
    endif
 enddo
 ! guards the next check: an uncomputed lambda is 0, which is also < 1/3
 call checkval(lammin > 0. .and. ninner > 0,.true.,nfail(4),'first pass: lambda computed')
 call checkval(lammax_steep < 1./3. .and. nsteep > 0,.true.,nfail(1), &
               'first pass: lambda < 1/3 where T has a gradient')
 call checkval(diffmax,0.,1.e-3,nfail(2),'first pass lambda = second pass lambda')

 ! uniform temperature: no gradient, so lambda = 1/3 everywhere
 call getintenerg_opdep(30.,rho_cgs,u_cgs)
 vxyzu(4,1:npart) = u_cgs/unit_ergg
 call get_derivs_global()
 lam_uniform_err = 0.
 do i=1,npart
    if (inner(xyzh(:,i))) lam_uniform_err = max(lam_uniform_err,abs(lambda_FLD(i) - 1./3.))
 enddo
 call checkval(lam_uniform_err,0.,1.e-6,nfail(3),'uniform T: lambda = 1/3')

 ! conductivity: k = 16 sigma lambda T^3/(kappa rho) = 4 a c lambda T^3/(kappa rho), in code units
 do i=1,npart
    if (inner(xyzh(:,i))) exit
 enddo
 call check_conductivity(i,nfail(5))

 call update_test_scores(ntests,nfail,npass)
 deallocate(lam1)
 call finish_eos(ieos,ierr)
 ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old

contains

!-----------------------------------------------------------------------
! the FLD conductivity of particle i against 4 a c lambda T^3/(kappa rho)
! from the same opacity lookup; guards against mixing CGS and code units
!-----------------------------------------------------------------------
subroutine check_conductivity(i,nfail)
 use eos_stamatellos, only:get_k_fld,getopac_opdep,lambda_FLD
 use units,           only:unit_opacity,unit_density,unit_ergg,get_radconst_code,get_c_code
 use part,            only:rhoh,xyzh,vxyzu,massoftype,igas
 use testutils,       only:checkval
 integer, intent(in)    :: i
 integer, intent(inout) :: nfail
 real :: rhoi,ki,Ti,kbar,kpart,T2,gmw,k_expected

 rhoi = rhoh(xyzh(4,i),massoftype(igas))
 call get_k_fld(rhoi,vxyzu(4,i),i,ki,Ti)
 call getopac_opdep(vxyzu(4,i)*unit_ergg,rhoi*unit_density,kbar,kpart,T2,gmw)
 k_expected = 4.*get_radconst_code()*get_c_code()*lambda_FLD(i)*Ti**3/((kpart/unit_opacity)*rhoi)
 call checkval(ki/k_expected,1.,1.e-6,nfail,'FLD conductivity = 4 a c lambda T^3/(kappa rho)')

end subroutine check_conductivity


 ! away from the edges, so a non-periodic build tests full kernels only
 logical function inner(xyzhi)
  real, intent(in) :: xyzhi(4)
  inner = periodic .or. all(abs(xyzhi(1:3)) < 0.3)
 end function inner

end subroutine test_first_pass

!-----------------------------------------------------------------------
! 'do FLD' in the .in must switch FLD (doFLD) on and off. It was read
! into fld_opt and never copied, so FLD ran whatever the .in said.
!-----------------------------------------------------------------------
subroutine test_fld_switch(ntests,npass)
 use cooling_radapprox, only:read_options_cooling_radapprox
 use eos_stamatellos,   only:doFLD
 use infile_utils,      only:inopts,open_db_from_file,close_db,write_inopt
 use testutils,         only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 type(inopts), allocatable :: db(:)
 integer :: nfail(2),ierr,nerr,lu,iopt
 logical :: doFLD_old
 character(len=*), parameter :: fname = 'test_fld_switch.tmp'

 nfail(:) = 0
 doFLD_old = doFLD
 do iopt = 0,1
    open(newunit=lu,file=fname,status='replace',form='formatted')
    call write_inopt('eos_lom.dat','EOS_file','table',lu)
    call write_inopt(iopt,'do FLD','Do FLD? (1) yes (0) no',lu)
    close(lu)
    doFLD = (iopt == 0)   ! start from the opposite state
    nerr = 0
    call open_db_from_file(db,fname,78,ierr)
    call read_options_cooling_radapprox(db,nerr)
    call close_db(db)
    call checkval(merge(1,0,doFLD),iopt,0,nfail(iopt+1),'do FLD = '//achar(48+iopt)//' sets doFLD')
 enddo
 doFLD = doFLD_old
 call update_test_scores(ntests,nfail,npass)

end subroutine test_fld_switch

!-----------------------------------------------------------------------
! the SPH diffusion term against the continuum (1/rho) div(k grad T):
! T = T0 (1 + eps sin 2 pi x/L) at uniform density, so with k ~ const
! du/dt = -(k/rho) (2 pi/L)^2 (T - T0) (Forgan et al. 2009 eq. 18 in this
! limit). Uses the code's own k, so it holds whatever value k has.
!-----------------------------------------------------------------------
subroutine test_diffusion_rate(ntests,npass)
 use boundary,        only:set_boundary,xmin,xmax,ymin,ymax,zmin,zmax,dxbound,dybound,dzbound
 use cooling,         only:cooling_in_step
 use deriv,           only:get_derivs_global
 use dim,             only:maxp,maxphase,periodic,mhd
 use datafiles,       only:find_phantom_datafile
 use eos,             only:ieos,icooling,init_eos,finish_eos,gamma
 use io,              only:id,master
 use physcon,         only:solarm,au,pi
 use testutils,       only:checkval,update_test_scores
 use unifdis,         only:set_unifdis
 use units,           only:set_units,unit_density,unit_ergg
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep,get_k_fld,duFLD
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact, &
                           iphase,isetphase,igas,rhoh
 integer, intent(inout) :: ntests,npass
 integer :: ierr,i,ieos_old,icooling_old
 real    :: gamma_old,psep,rho_cgs,totmass,T,u_cgs
 logical :: doFLD_old,cooling_in_step_old
 character(len=120) :: pdir
 integer :: nfail(1),n
 real    :: T0,eps,rhoi,ki,Ti,expected,ratio,rsum,rmin,rmax,wk2

 if (id==master) write(*,"(/,a)") '--> FLD diffusion rate against (1/rho) div(k grad T)'
 if (mhd) then   ! force.F90 runs the radiative pair terms only when .not. mhd
    if (id==master) write(*,"(a)") '  --> skipping diffusion-rate test (MHD build: no FLD pair term)'
    return
 endif
 call get_environment_variable('PHANTOM_DIR',pdir)
 if (len_trim(pdir) == 0 .or. len_trim(find_phantom_datafile(eos_file,'eos/lombardi')) == 0) then
    if (id==master) write(*,"(a)") '  --> skipping diffusion-rate test (no opacity table)'
    return
 endif
 ieos_old = ieos; icooling_old = icooling; doFLD_old = doFLD; gamma_old = gamma
 ieos = 24; icooling = 9; doFLD = .true.; gamma = 5./3.
 ! as init_cooling sets for icooling = 9: the radiative update is called with the particle index
 cooling_in_step_old = cooling_in_step; cooling_in_step = .true.
 call set_units(mass=solarm,dist=au,G=1.d0)
 call init_eos(ieos,ierr)
 if (ierr /= 0) then
    if (id==master) write(*,"(a)") '  --> skipping diffusion-rate test (init_eos failed)'
    ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
    cooling_in_step = cooling_in_step_old
    return
 endif
 call init_part()
 call set_boundary(-0.5,0.5,-0.5,0.5,-0.5,0.5)
 psep = dxbound/24.
 npart = 0
 call set_unifdis('cubic',id,master,xmin,xmax,ymin,ymax,zmin,zmax,psep,hfact,npart,xyzh,periodic)
 npartoftype(:) = 0
 npartoftype(igas) = npart
 rho_cgs = 1.e-12
 totmass = rho_cgs/unit_density*dxbound*dybound*dzbound
 massoftype(igas) = totmass/npart
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,iactive=.true.)

 T0 = 30.; eps = 0.01
 do i=1,npart
    T = T0*(1. + eps*sin(2.*pi*xyzh(1,i)/dxbound))
    call getintenerg_opdep(T,rho_cgs,u_cgs)
    vxyzu(4,i) = u_cgs/unit_ergg
 enddo
 call get_derivs_global()            ! lambda from a converged density pass
 call get_derivs_global(dt=1.)       ! the FLD pair sum runs only when dt > 0

 wk2 = (2.*pi/dxbound)**2
 n = 0; rsum = 0.; rmin = huge(0.); rmax = -huge(0.)
 do i=1,npart
    if (.not.(periodic .or. all(abs(xyzh(1:3,i)) < 0.25))) cycle
    if (abs(sin(2.*pi*xyzh(1,i)/dxbound)) < 0.5) cycle
    rhoi = rhoh(xyzh(4,i),massoftype(igas))
    call get_k_fld(rhoi,vxyzu(4,i),i,ki,Ti)
    expected = -(ki/rhoi)*wk2*(Ti - T0)
    ratio = duFLD(i)/expected
    n = n + 1; rsum = rsum + ratio
    rmin = min(rmin,ratio); rmax = max(rmax,ratio)
 enddo
 if (id==master) write(*,"(a,i6,a,3(1x,es12.5))") '  particles ',n, &
      '  du_FLD/continuum mean min max:',rsum/max(n,1),rmin,rmax
 nfail(:) = 0
 call checkval(rsum/max(n,1),1.,0.05,nfail(1),'du_FLD matches (1/rho) div(k grad T)')
 call update_test_scores(ntests,nfail,npass)
 call finish_eos(ieos,ierr)
 ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
 cooling_in_step = cooling_in_step_old

end subroutine test_diffusion_rate

!-----------------------------------------------------------------------
! the FLD exchange within a pair must be antisymmetric, so the total
! sum_i m_i du_FLD,i vanishes: both sides need the same kernel gradient
! when h_i /= h_j. A density wave along x makes the smoothing lengths differ.
!-----------------------------------------------------------------------
subroutine test_fld_conservation(ntests,npass)
 use boundary,        only:set_boundary,xmin,xmax,ymin,ymax,zmin,zmax,dxbound,dybound,dzbound
 use cooling,         only:cooling_in_step
 use deriv,           only:get_derivs_global
 use dim,             only:maxp,maxphase,periodic,mhd
 use datafiles,       only:find_phantom_datafile
 use eos,             only:ieos,icooling,init_eos,finish_eos,gamma
 use io,              only:id,master
 use physcon,         only:solarm,au,pi
 use testutils,       only:checkval,update_test_scores
 use unifdis,         only:set_unifdis
 use units,           only:set_units,unit_density,unit_ergg
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep,duFLD
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact, &
                           iphase,isetphase,igas
 integer, intent(inout) :: ntests,npass
 integer :: ierr,i,ieos_old,icooling_old
 real    :: gamma_old,psep,rho_cgs,totmass,T,u_cgs
 logical :: doFLD_old,cooling_in_step_old
 character(len=120) :: pdir
 integer :: nfail(2)
 real    :: esum,eabs

 if (id==master) write(*,"(/,a)") '--> FLD exchange conserves energy when h varies'
 if (mhd) then   ! force.F90 runs the radiative pair terms only when .not. mhd
    if (id==master) write(*,"(a)") '  --> skipping FLD conservation test (MHD build: no FLD pair term)'
    return
 endif
 call get_environment_variable('PHANTOM_DIR',pdir)
 if (len_trim(pdir) == 0 .or. len_trim(find_phantom_datafile(eos_file,'eos/lombardi')) == 0) then
    if (id==master) write(*,"(a)") '  --> skipping FLD conservation test (no opacity table)'
    return
 endif
 ieos_old = ieos; icooling_old = icooling; doFLD_old = doFLD; gamma_old = gamma
 ieos = 24; icooling = 9; doFLD = .true.; gamma = 5./3.
 ! as init_cooling sets for icooling = 9: the radiative update is called with the particle index
 cooling_in_step_old = cooling_in_step; cooling_in_step = .true.
 call set_units(mass=solarm,dist=au,G=1.d0)
 call init_eos(ieos,ierr)
 if (ierr /= 0) then
    if (id==master) write(*,"(a)") '  --> skipping FLD conservation test (init_eos failed)'
    ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
    cooling_in_step = cooling_in_step_old
    return
 endif
 call init_part()
 call set_boundary(-0.5,0.5,-0.5,0.5,-0.5,0.5)
 psep = dxbound/16.
 npart = 0
 call set_unifdis('cubic',id,master,xmin,xmax,ymin,ymax,zmin,zmax,psep,hfact,npart,xyzh,periodic)
 npartoftype(:) = 0
 npartoftype(igas) = npart
 rho_cgs = 1.e-12
 totmass = rho_cgs/unit_density*dxbound*dybound*dzbound
 massoftype(igas) = totmass/npart
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,iactive=.true.)

 ! density wave along x (smoothing lengths vary by ~10%); T peaks a quarter-wave away
 do i=1,npart
    xyzh(1,i) = xyzh(1,i) + 0.05*dxbound*sin(2.*pi*xyzh(1,i)/dxbound)
 enddo
 do i=1,npart
    T = 30.*(1. + 0.5*cos(2.*pi*xyzh(1,i)/dxbound))
    call getintenerg_opdep(T,rho_cgs,u_cgs)
    vxyzu(4,i) = u_cgs/unit_ergg
 enddo
 call get_derivs_global()
 call get_derivs_global(dt=1.)

 ! equal particle masses, so sum_i m_i du_i is proportional to sum_i du_i
 esum = sum(duFLD(1:npart))
 eabs = sum(abs(duFLD(1:npart)))
 if (id==master) write(*,"(a,es12.5)") '  sum du_FLD / sum |du_FLD| = ',esum/max(eabs,tiny(0.))
 nfail(:) = 0
 call checkval(eabs > 0.,.true.,nfail(1),'FLD pair term ran (du_FLD not all zero)')
 call checkval(abs(esum)/max(eabs,tiny(0.)),0.,1.e-10,nfail(2),'sum_i m_i du_FLD,i = 0')
 call update_test_scores(ntests,nfail,npass)
 call finish_eos(ieos,ierr)
 ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
 cooling_in_step = cooling_in_step_old

end subroutine test_fld_conservation

!-----------------------------------------------------------------------
! lambda must not depend on which neighbours are active this step: with
! individual timesteps an active particle has inactive neighbours, and the
! gradient of the radiation energy density needs all of them
!-----------------------------------------------------------------------
subroutine test_lambda_inactive(ntests,npass)
 use boundary,        only:set_boundary,xmin,xmax,ymin,ymax,zmin,zmax,dxbound,dybound,dzbound
 use cooling,         only:cooling_in_step
 use deriv,           only:get_derivs_global
 use dim,             only:maxp,maxphase,periodic
 use datafiles,       only:find_phantom_datafile
 use eos,             only:ieos,icooling,init_eos,finish_eos,gamma
 use io,              only:id,master
 use physcon,         only:solarm,au,pi
 use testutils,       only:checkval,update_test_scores
 use unifdis,         only:set_unifdis
 use units,           only:set_units,unit_density,unit_ergg
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep,lambda_FLD
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact, &
                           iphase,isetphase,igas
 integer, intent(inout) :: ntests,npass
 integer :: ierr,i,ieos_old,icooling_old
 real    :: gamma_old,psep,rho_cgs,totmass,T,u_cgs
 logical :: doFLD_old,cooling_in_step_old
 character(len=120) :: pdir
 integer :: nfail(1),nact
 real    :: diffmax
 real, allocatable :: lam_all(:)

 if (maxphase /= maxp) then
    if (id==master) write(*,"(a)") '  --> skipping lambda/inactive-neighbour test (no iphase in this build)'
    return
 endif
 if (id==master) write(*,"(/,a)") '--> lambda does not depend on neighbour activity'
 call get_environment_variable('PHANTOM_DIR',pdir)
 if (len_trim(pdir) == 0 .or. len_trim(find_phantom_datafile(eos_file,'eos/lombardi')) == 0) then
    if (id==master) write(*,"(a)") '  --> skipping lambda/inactive-neighbour test (no opacity table)'
    return
 endif
 ieos_old = ieos; icooling_old = icooling; doFLD_old = doFLD; gamma_old = gamma
 ieos = 24; icooling = 9; doFLD = .true.; gamma = 5./3.
 ! as init_cooling sets for icooling = 9: the radiative update is called with the particle index
 cooling_in_step_old = cooling_in_step; cooling_in_step = .true.
 call set_units(mass=solarm,dist=au,G=1.d0)
 call init_eos(ieos,ierr)
 if (ierr /= 0) then
    if (id==master) write(*,"(a)") '  --> skipping lambda/inactive-neighbour test (init_eos failed)'
    ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
    cooling_in_step = cooling_in_step_old
    return
 endif
 call init_part()
 call set_boundary(-0.5,0.5,-0.5,0.5,-0.5,0.5)
 psep = dxbound/16.
 npart = 0
 call set_unifdis('cubic',id,master,xmin,xmax,ymin,ymax,zmin,zmax,psep,hfact,npart,xyzh,periodic)
 npartoftype(:) = 0
 npartoftype(igas) = npart
 rho_cgs = 1.e-12
 totmass = rho_cgs/unit_density*dxbound*dybound*dzbound
 massoftype(igas) = totmass/npart
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,iactive=.true.)

 do i=1,npart
    T = 30.*(1. + 0.5*sin(2.*pi*xyzh(1,i)/dxbound))
    call getintenerg_opdep(T,rho_cgs,u_cgs)
    vxyzu(4,i) = u_cgs/unit_ergg
 enddo
 allocate(lam_all(npart))
 call get_derivs_global()
 call get_derivs_global()
 lam_all(1:npart) = lambda_FLD(1:npart)

 ! every other particle inactive, as on a step of the individual-timestep scheme
 do i=1,npart,2
    iphase(i) = isetphase(igas,iactive=.false.)
 enddo
 call get_derivs_global()

 diffmax = 0.; nact = 0
 do i=2,npart,2
    if (.not.(periodic .or. all(abs(xyzh(1:3,i)) < 0.25))) cycle
    nact = nact + 1
    diffmax = max(diffmax,abs(lambda_FLD(i) - lam_all(i))/lam_all(i))
 enddo
 if (id==master) write(*,"(a,i6,a,es12.5)") '  active particles ',nact,'  max rel change in lambda: ',diffmax
 nfail(:) = 0
 call checkval(diffmax,0.,1.e-6,nfail(1),'lambda unchanged with half the neighbours inactive')
 call update_test_scores(ntests,nfail,npass)
 iphase(1:npart) = isetphase(igas,iactive=.true.)
 deallocate(lam_all)
 call finish_eos(ieos,ierr)
 ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old
 cooling_in_step = cooling_in_step_old

end subroutine test_lambda_inactive

end module testfld
