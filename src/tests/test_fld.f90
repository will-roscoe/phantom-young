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
! :Dependencies: boundary, cooling, datafiles, deriv, dim, densityforce, eos,
!   eos_stamatellos, fld_implicit, fld_options, io, part, physcon, testutils,
!   timestep, timestep_ind, unifdis, units
!
 implicit none
 public :: test_fld

 private

 ! settings fld_box changes, restored by fld_box_done
 integer :: box_ieos,box_icooling
 real    :: box_gamma,box_dtmax
 logical :: box_doFLD,box_cooling_in_step

contains

subroutine test_fld(ntests,npass)
 use eos_stamatellos, only:fld_solver
 use io,              only:id,master
 integer, intent(inout) :: ntests,npass
 integer :: isolver,solver_old

 if (id==master) write(*,"(/,a,/)") '--> TESTING FLUX-LIMITED DIFFUSION LAMBDA'
 call test_limiter(ntests,npass)
 call test_gradh_fallback(ntests,npass)
 call test_first_pass(ntests,npass)
 call test_fld_switch(ntests,npass)
 call test_fld_options(ntests,npass)
 call test_diffusion_rate(ntests,npass)
 call test_fld_conservation(ntests,npass)
 call test_lambda_inactive(ntests,npass)
 call test_relaxation_inf_guard(ntests,npass)
 call test_fld_solver_option(ntests,npass)
 solver_old = fld_solver
 do isolver=1,2
    fld_solver = isolver
    if (id==master) write(*,"(/,a,i1,a)") '--> implicit FLD tests with fld_solver = ',isolver, &
                                           trim(merge(' (Gauss-Seidel)',' (Jacobi-PCG)  ',isolver==1))
    call test_fld_implicit_step(ntests,npass)
    call test_fld_implicit_explicit_limit(ntests,npass)
    call test_fld_implicit_zero_lambda(ntests,npass)
    call test_fld_implicit_fixed_boundary(ntests,npass)
    call test_fld_implicit_capped(ntests,npass)
    call test_fld_implicit_residual(ntests,npass)
    call test_fld_implicit_split(ntests,npass)
    call test_fld_implicit_conserve_unconverged(ntests,npass)
    call test_fld_implicit_owed(ntests,npass)
    call test_fld_implicit_derivs(ntests,npass)
    call test_fld_implicit_limit(ntests,npass)
    call test_fld_implicit_run_counts(ntests,npass)
 enddo
 fld_solver = solver_old
 call test_fld_implicit_cg(ntests,npass)
 call test_fld_implicit_stiffness(ntests,npass)

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
! fld_mode records the scheme: 0 off, 1 explicit, 2 implicit (default)
!-----------------------------------------------------------------------
subroutine test_fld_switch(ntests,npass)
 use cooling_radapprox, only:read_options_cooling_radapprox
 use eos_stamatellos,   only:doFLD,fld_mode
 use infile_utils,      only:inopts,open_db_from_file,close_db,write_inopt
 use testutils,         only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 type(inopts), allocatable :: db(:)
 integer :: nfail(7),ierr,nerr,lu,iopt,fld_mode_old
 logical :: doFLD_old
 character(len=*), parameter :: fname = 'test_fld_switch.tmp'

 nfail(:) = 0
 doFLD_old = doFLD
 fld_mode_old = fld_mode
 do iopt = 0,2
    open(newunit=lu,file=fname,status='replace',form='formatted')
    call write_inopt('eos_lom.dat','EOS_file','table',lu)
    call write_inopt(iopt,'do FLD','Do FLD? (0) no (1) explicit (2) implicit',lu)
    close(lu)
    doFLD = (iopt == 0)   ! start from the opposite state
    fld_mode = -1
    nerr = 0
    call open_db_from_file(db,fname,78,ierr)
    call read_options_cooling_radapprox(db,nerr)
    call close_db(db)
    call checkval(merge(1,0,doFLD),merge(0,1,iopt==0),0,nfail(2*iopt+1),'do FLD = '//achar(48+iopt)//' sets doFLD')
    call checkval(fld_mode,iopt,0,nfail(2*iopt+2),'do FLD = '//achar(48+iopt)//' sets fld_mode')
 enddo
 ! an .in without the key gets the implicit scheme
 open(newunit=lu,file=fname,status='replace',form='formatted')
 call write_inopt('eos_lom.dat','EOS_file','table',lu)
 close(lu)
 fld_mode = -1
 nerr = 0
 call open_db_from_file(db,fname,78,ierr)
 call read_options_cooling_radapprox(db,nerr)
 call close_db(db)
 call checkval(fld_mode,2,0,nfail(7),'do FLD absent defaults to 2')
 doFLD = doFLD_old
 fld_mode = fld_mode_old
 call update_test_scores(ntests,nfail,npass)

end subroutine test_fld_switch

!-----------------------------------------------------------------------
! fld_solver in the .in selects the implicit solver: 1 Gauss-Seidel
! (also when the key is absent), 2 Jacobi-PCG; any other value is a read
! error, which stops the run at start-up
!-----------------------------------------------------------------------
subroutine test_fld_solver_option(ntests,npass)
 use cooling_radapprox, only:read_options_cooling_radapprox,write_options_cooling_radapprox
 use eos_stamatellos,   only:fld_solver
 use infile_utils,      only:inopts,open_db_from_file,close_db,write_inopt
 use testutils,         only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 type(inopts), allocatable :: db(:)
 integer :: nfail(7),solver_old,nerr,iopt
 character(len=*), parameter :: fname = 'test_fld_solver.tmp'

 nfail(:) = 0
 solver_old = fld_solver
 do iopt=1,2
    nerr = read_solver(iopt)
    call checkval(fld_solver,iopt,0,nfail(iopt),'fld_solver = '//achar(48+iopt)//' is read')
    call checkval(nerr,0,0,nfail(2+iopt),'fld_solver = '//achar(48+iopt)//' is accepted')
 enddo
 nerr = read_solver(-1)
 call checkval(fld_solver,1,0,nfail(5),'fld_solver absent defaults to 1 (Gauss-Seidel)')
 call checkval(read_solver(0) > 0 .and. read_solver(3) > 0,.true.,nfail(6),'fld_solver = 0 or 3 is a read error')
 ! the value written to the .in is read back
 fld_solver = 2
 open(newunit=iopt,file=fname,status='replace',form='formatted')
 call write_options_cooling_radapprox(iopt)
 close(iopt)
 fld_solver = -1
 nerr = 0
 call open_db_from_file(db,fname,78,iopt)
 call read_options_cooling_radapprox(db,nerr)
 call close_db(db)
 call checkval(fld_solver,2,0,nfail(7),'fld_solver written to the .in and read back')
 fld_solver = solver_old
 call update_test_scores(ntests,nfail,npass)

contains

! read a .in with fld_solver = val (no key when val < 0); returns the error count
integer function read_solver(val)
 integer, intent(in) :: val
 integer :: lu,ierr
 open(newunit=lu,file=fname,status='replace',form='formatted')
 call write_inopt('eos_lom.dat','EOS_file','table',lu)
 if (val >= 0) call write_inopt(val,'fld_solver','solver',lu)
 close(lu)
 fld_solver = -1
 read_solver = 0
 call open_db_from_file(db,fname,78,ierr)
 call read_options_cooling_radapprox(db,read_solver)
 call close_db(db)
end function read_solver

end subroutine test_fld_solver_option

!-----------------------------------------------------------------------
! do FLD = 1 and RADIATION=yes + icooling 9 are refused at start-up unless
! I_WILL_NOT_PUBLISH_CRAP is true, when they only warn
!-----------------------------------------------------------------------
subroutine test_fld_options(ntests,npass)
 use fld_options, only:env_is_true,check_fld_options,ierr_fld_warn,ierr_fld_fatal
 use testutils,   only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(13),ierr
 character(len=200) :: msg

 nfail(:) = 0
 call checkval(env_is_true('1'),.true.,nfail(1),'env 1 is true')
 call checkval(env_is_true(' YeS '),.true.,nfail(2),'env YeS is true')
 call checkval(env_is_true('0') .or. env_is_true('') .or. env_is_true('nope'),.false.,nfail(3), &
               'env 0/empty/other is false')

 call check_fld_options(2,.false.,.false.,.false.,.false.,ierr,msg)
 call checkval(ierr,0,0,nfail(4),'mode 2 without radiation is fine')
 call check_fld_options(0,.false.,.false.,.false.,.false.,ierr,msg)
 call checkval(ierr,0,0,nfail(5),'mode 0 is fine')
 call check_fld_options(1,.false.,.false.,.false.,.false.,ierr,msg)
 call checkval(ierr,ierr_fld_fatal,0,nfail(6),'mode 1 is fatal')
 call checkval(index(msg,'do FLD = 2') > 0,.true.,nfail(7),'mode 1 message names do FLD = 2')
 call check_fld_options(1,.false.,.false.,.false.,.true.,ierr,msg)
 call checkval(ierr,ierr_fld_warn,0,nfail(8),'mode 1 with the env var only warns')

 call check_fld_options(2,.true.,.true.,.false.,.false.,ierr,msg)
 call checkval(ierr,ierr_fld_fatal,0,nfail(9),'radiation exchange on with icooling 9 is fatal')
 call checkval(index(msg,'gas-rad_exchange') > 0 .and. index(msg,'implicit_radiation') > 0,.true.,nfail(10), &
               'radiation message names both keys')
 call check_fld_options(2,.true.,.false.,.false.,.false.,ierr,msg)
 call checkval(ierr,0,0,nfail(11),'radiation build with both keys off is fine')
 call check_fld_options(0,.true.,.false.,.true.,.false.,ierr,msg)
 call checkval(ierr,ierr_fld_fatal,0,nfail(12),'implicit_radiation on with icooling 9 is fatal')
 call check_fld_options(2,.true.,.true.,.true.,.true.,ierr,msg)
 call checkval(ierr,ierr_fld_warn,0,nfail(13),'radiation keys on with the env var only warn')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_fld_options

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
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep,get_k_fld,duFLD,fld_mode
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact, &
                           iphase,isetphase,igas,rhoh
 integer, intent(inout) :: ntests,npass
 integer :: fld_mode_old
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
 fld_mode_old = fld_mode; fld_mode = 1
 call get_derivs_global(dt=1.)       ! the explicit FLD pair sum (do FLD = 1) runs only when dt > 0
 fld_mode = fld_mode_old

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
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep,duFLD,fld_mode
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact, &
                           iphase,isetphase,igas
 integer, intent(inout) :: ntests,npass
 integer :: fld_mode_old
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
 fld_mode_old = fld_mode; fld_mode = 1   ! the explicit pair term
 call get_derivs_global(dt=1.)
 fld_mode = fld_mode_old

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

!-----------------------------------------------------------------------
! a backward relaxation step with |dt| >> t_therm and u > u_eq divides by
! exp(dt/t_therm) = 0; the result must stay finite and keep the input u
!-----------------------------------------------------------------------
subroutine test_relaxation_inf_guard(ntests,npass)
 use cooling_radapprox, only:radcool_evolve_ui
 use datafiles,         only:find_phantom_datafile
 use eos,               only:ieos,init_eos,finish_eos
 use eos_stamatellos,   only:eos_file,ttherm_store,ueqi_store
 use io,                only:id,master
 use part,              only:massoftype,igas
 use physcon,           only:solarm,au
 use testutils,         only:checkval,update_test_scores
 use units,             only:set_units
 integer, intent(inout) :: ntests,npass
 integer :: nfail(2),ierr,ieos_old
 real    :: u,u0,massoftype_old
 character(len=120) :: pdir

 if (id==master) write(*,"(/,a)") '--> backward relaxation with |dt| >> t_therm stays finite'
 call get_environment_variable('PHANTOM_DIR',pdir)
 if (len_trim(pdir) == 0 .or. len_trim(find_phantom_datafile(eos_file,'eos/lombardi')) == 0) then
    if (id==master) write(*,"(a)") '  --> skipping relaxation guard test (no opacity table)'
    return
 endif
 ieos_old = ieos; ieos = 24
 call set_units(mass=solarm,dist=au,G=1.d0)
 call init_eos(ieos,ierr)
 if (ierr /= 0) then
    if (id==master) write(*,"(a)") '  --> skipping relaxation guard test (init_eos failed)'
    ieos = ieos_old
    return
 endif
 massoftype_old = massoftype(igas)
 massoftype(igas) = 1.e-6   ! with h = 1: rho ~ 1e-12 g/cm^3, inside the table
 ttherm_store(1) = 1.e-3
 ueqi_store(1)   = 1.
 u0 = 2.
 u  = u0
 call radcool_evolve_ui(u,-1.e3,1,1.e4,1.)   ! dt/t_therm = -1e6; floor (10 K) far below u0

 nfail(:) = 0
 call checkval(u <= huge(u) .and. u == u,.true.,nfail(1),'backward relaxation stays finite')
 call checkval(u,u0,0.,nfail(2),'non-finite result falls back to the input u')
 call update_test_scores(ntests,nfail,npass)
 massoftype(igas) = massoftype_old
 call finish_eos(ieos,ierr)
 ieos = ieos_old

end subroutine test_relaxation_inf_guard
! a 24^3 box (periodic in periodic builds) at rho = 1e-12 g/cc with the
! FLD hybrid on, T(x) a 30 K / 30(1+amp) K step or 30(1 + amp sin) K, and
! lambda from a density pass. Returns .false. (the test skips) without the
! opacity table; fld_box_done restores the settings it changed
!-----------------------------------------------------------------------
logical function fld_box(profile,amp)
 use boundary,        only:set_boundary,xmin,xmax,ymin,ymax,zmin,zmax,dxbound,dybound,dzbound
 use cooling,         only:cooling_in_step
 use datafiles,       only:find_phantom_datafile
 use deriv,           only:get_derivs_global
 use dim,             only:maxp,maxphase,periodic,ind_timesteps
 use eos,             only:ieos,icooling,init_eos,gamma
 use eos_stamatellos, only:eos_file,doFLD,getintenerg_opdep
 use io,              only:id,master
 use part,            only:init_part,npart,npartoftype,massoftype,xyzh,vxyzu,hfact,iphase,isetphase,igas,ibin
 use physcon,         only:solarm,au,pi
 use timestep,        only:dtmax
 use unifdis,         only:set_unifdis
 use units,           only:set_units,unit_density,unit_ergg
 character(len=*), intent(in) :: profile   ! 'step' or 'sine'
 real,             intent(in) :: amp
 character(len=120) :: pdir
 integer :: i,ierr
 real    :: psep,rho_cgs,T,u_cgs

 fld_box = .false.
 call get_environment_variable('PHANTOM_DIR',pdir)
 if (len_trim(pdir) == 0 .or. len_trim(find_phantom_datafile(eos_file,'eos/lombardi')) == 0) then
    if (id==master) write(*,"(a)") '  --> skipping (no opacity table)'
    return
 endif
 box_ieos = ieos; box_icooling = icooling; box_doFLD = doFLD; box_gamma = gamma
 box_cooling_in_step = cooling_in_step; box_dtmax = dtmax
 ieos = 24; icooling = 9; doFLD = .true.; gamma = 5./3.; cooling_in_step = .true.
 call set_units(mass=solarm,dist=au,G=1.d0)
 call init_eos(ieos,ierr)
 if (ierr /= 0) then
    if (id==master) write(*,"(a)") '  --> skipping (init_eos failed)'
    call fld_box_done(finish=.false.)
    return
 endif
 call init_part()
 call set_boundary(-0.5,0.5,-0.5,0.5,-0.5,0.5)
 psep = dxbound/24.
 npart = 0
 call set_unifdis('cubic',id,master,xmin,xmax,ymin,ymax,zmin,zmax,psep,hfact,npart,xyzh,periodic)
 npartoftype(:) = 0; npartoftype(igas) = npart
 rho_cgs = 1.e-12
 massoftype(igas) = rho_cgs/unit_density*dxbound*dybound*dzbound/npart
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,iactive=.true.)
 if (ind_timesteps) ibin(1:npart) = 0
 do i=1,npart
    if (profile == 'step') then
       T = merge(30.*(1.+amp),30.,xyzh(1,i) > 0.)
    else
       T = 30.*(1. + amp*sin(2.*pi*xyzh(1,i)/dxbound))
    endif
    call getintenerg_opdep(T,rho_cgs,u_cgs)
    vxyzu(4,i) = u_cgs/unit_ergg
 enddo
 dtmax = 1.
 call get_derivs_global()   ! lambda from a converged density pass
 fld_box = .true.

end function fld_box

subroutine fld_box_done(finish)
 use cooling,  only:cooling_in_step
 use dim,      only:maxp,maxphase
 use eos,      only:ieos,icooling,finish_eos,gamma
 use eos_stamatellos, only:doFLD
 use part,     only:npart,iphase,isetphase,igas
 use timestep, only:dtmax
 logical, intent(in), optional :: finish   ! .false. if init_eos failed
 integer :: ierr
 logical :: do_finish

 do_finish = .true.
 if (present(finish)) do_finish = finish
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,iactive=.true.)
 if (do_finish) call finish_eos(ieos,ierr)
 ieos = box_ieos; icooling = box_icooling; doFLD = box_doFLD; gamma = box_gamma
 cooling_in_step = box_cooling_in_step; dtmax = box_dtmax

end subroutine fld_box_done

!-----------------------------------------------------------------------
! one implicit solve at dt: with individual timesteps dt_i = dtmax/2**ibin(i),
! so every particle goes to bin 0 (derivs assigns bins) and dtmax = dt
!-----------------------------------------------------------------------
subroutine solve_at(dt)
 use dim,          only:ind_timesteps
 use fld_implicit, only:do_fld_implicit
 use part,         only:npart,xyzh,vxyzu,ibin
 use timestep,     only:dtmax
 real, intent(in) :: dt

 dtmax = dt
 if (ind_timesteps) ibin(1:npart) = 0
 call do_fld_implicit(dt,npart,xyzh,vxyzu)

end subroutine solve_at

!-----------------------------------------------------------------------
! the temperature an active particle reaches after dt at rate du_FLD
!-----------------------------------------------------------------------
real function T_after(i,dt)
 use eos_stamatellos, only:duFLD,getopac_opdep
 use part,            only:xyzh,vxyzu,massoftype,igas,rhoh
 use units,           only:unit_ergg,unit_density
 integer, intent(in) :: i
 real,    intent(in) :: dt
 real :: kb,kp,mu

 call getopac_opdep((vxyzu(4,i) + dt*duFLD(i))*unit_ergg,rhoh(xyzh(4,i),massoftype(igas))*unit_density, &
                    kb,kp,T_after,mu)

end function T_after

!-----------------------------------------------------------------------
! a temperature step. At dt = 1e3 t_cell, beyond the diffusion time of
! the box, T' stays within the old extremes (no new extrema). At a dt
! of a few cell diffusion times the solve converges and fld_leak reports
! sum m du / sum m |du|
!-----------------------------------------------------------------------
subroutine test_fld_implicit_step(ntests,npass)
 use eos_stamatellos, only:duFLD
 use fld_implicit,    only:fld_leak,fld_nsweeps,fld_nsplits,fld_resid,fld_tol
 use io,              only:id,master
 use part,            only:npart,massoftype,igas
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(5),i
 real    :: dt,Tnew,Tmin,Tmax,dsum,dabs,leak_big

 if (id==master) write(*,"(/,a)") '--> FLD implicit: temperature step'
 if (.not. fld_box('step',1.)) return    ! 30 K and 60 K halves
 dt = 1.e3*t_cell()                       ! beyond the diffusion time of the box
 call solve_at(dt)
 leak_big = fld_leak
 Tmin = huge(0.); Tmax = -huge(0.)
 do i=1,npart
    Tnew = T_after(i,dt)
    Tmin = min(Tmin,Tnew); Tmax = max(Tmax,Tnew)
 enddo
 if (id==master) write(*,"(a,es9.2,a,i6,a,i4,a,es10.3,a,2(1x,f9.4),a,es10.3)") '  dt ',dt,'  sweeps ',fld_nsweeps, &
    '  splits ',fld_nsplits,'  residual ',fld_resid,'  T min max',Tmin,Tmax,'  leak ',leak_big
 nfail(:) = 0
 call checkval(Tmin >= 30.*(1.-1.e-6),.true.,nfail(1),'step at dt >> t_diff: no T below the cold side')
 call checkval(Tmax <= 60.*(1.+1.e-6),.true.,nfail(2),'step at dt >> t_diff: no T above the hot side')

 dt = 1.e-2                               ! a few cell diffusion times: converges
 call solve_at(dt)
 dsum = 0.; dabs = 0.
 do i=1,npart
    dsum = dsum + massoftype(igas)*duFLD(i); dabs = dabs + massoftype(igas)*abs(duFLD(i))
 enddo
 if (id==master) write(*,"(a,es9.2,a,i6,a,es10.3,a,es10.3)") '  dt ',dt,'  sweeps ',fld_nsweeps, &
    '  residual ',fld_resid,'  leak ',fld_leak
 call checkval(fld_resid < fld_tol,.true.,nfail(3),'step at a few t_diff: converged')
 call checkval(abs(fld_leak - dsum/dabs) < 1.e-12,.true.,nfail(4),'fld_leak = sum m du_FLD / sum m |du_FLD|')
 call checkval(abs(fld_leak) < 100.*fld_tol,.true.,nfail(5),'global timesteps, converged: |leak| < 100 fld_tol')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_step

!-----------------------------------------------------------------------
! as dt -> 0 the implicit rate tends to the explicit pair sum of the
! force pass (do FLD = 1), particle by particle
!-----------------------------------------------------------------------
subroutine test_fld_implicit_explicit_limit(ntests,npass)
 use deriv,           only:get_derivs_global
 use dim,             only:mhd
 use eos_stamatellos, only:duFLD,fld_mode
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: fld_mode_old
 integer :: nfail(2)
 real    :: dt,errmax,dumax
 real, allocatable :: du_explicit(:)

 if (id==master) write(*,"(/,a)") '--> FLD implicit: tends to the explicit term as dt -> 0'
 if (mhd) then   ! force.F90 runs the explicit pair term only when .not. mhd
    if (id==master) write(*,"(a)") '  --> skipping (MHD build: no explicit FLD pair term to compare with)'
    return
 endif
 if (.not. fld_box('sine',0.01)) return
 dt = 1.e-8
 fld_mode_old = fld_mode; fld_mode = 1
 call get_derivs_global(dt=dt)          ! the explicit pair sum
 fld_mode = fld_mode_old
 du_explicit = duFLD(1:npart)
 call solve_at(dt)
 dumax  = maxval(abs(du_explicit))
 errmax = maxval(abs(duFLD(1:npart) - du_explicit))/max(dumax,tiny(0.))
 if (id==master) write(*,"(a,es10.3,a,es10.3)") '  max |du_explicit| ',dumax,'  max |du_implicit - du_explicit|/max ',errmax
 nfail(:) = 0
 call checkval(dumax > 0.,.true.,nfail(1),'explicit pair term ran')
 call checkval(errmax,0.,1.e-4,nfail(2),'implicit du_FLD at small dt = explicit du_FLD')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_explicit_limit

!-----------------------------------------------------------------------
! a particle with lambda = 0 has k = 0: no exchange, no NaN
!-----------------------------------------------------------------------
subroutine test_fld_implicit_zero_lambda(ntests,npass)
 use eos_stamatellos, only:duFLD,lambda_FLD
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(2)

 if (id==master) write(*,"(/,a)") '--> FLD implicit: a particle with lambda = 0'
 if (.not. fld_box('step',1.)) return
 lambda_FLD(1) = 0.        ! a derivs call would recompute lambda, so call the solve directly
 call solve_at(1.e-1)
 nfail(:) = 0
 call checkval(all(duFLD(1:npart) == duFLD(1:npart)),.true.,nfail(1),'lambda = 0: no NaN in du_FLD')
 call checkval(duFLD(1),0.,1.e-30,nfail(2),'lambda = 0: no exchange for that particle')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_zero_lambda

!-----------------------------------------------------------------------
! individual timesteps: an active particle surrounded by inactive ones
! sees them as a fixed boundary, and uses its own bin's dt
!-----------------------------------------------------------------------
subroutine test_fld_implicit_fixed_boundary(ntests,npass)
 use dim,             only:ind_timesteps,maxp,maxphase
 use eos_stamatellos, only:duFLD
 use fld_implicit,    only:do_fld_implicit,fld_nsweeps,fld_leak
 use io,              only:id,master
 use part,            only:npart,xyzh,vxyzu,iphase,isetphase,igas,ibin
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(3),i,iact
 real    :: du_dt1,du_dt2,leak1

 if (id==master) write(*,"(/,a)") '--> FLD implicit: inactive neighbours are a fixed boundary'
 if (.not. ind_timesteps .or. maxphase /= maxp) then
    if (id==master) write(*,"(a)") '  --> skipping (needs individual timesteps)'
    return
 endif
 if (.not. fld_box('step',1.)) return
 iact = minloc(abs(xyzh(1,1:npart)),1)            ! a particle at the step
 do i=1,npart
    iphase(i) = isetphase(igas,iactive=(i==iact))
 enddo
 ibin(iact) = 0
 call do_fld_implicit(1.,npart,xyzh,vxyzu)        ! dt_i = dtmax/2**0 = 1
 du_dt1 = duFLD(iact)
 leak1  = fld_leak
 nfail(:) = 0
 call checkval(fld_nsweeps <= 2,.true.,nfail(1),'all neighbours fixed: converges at once')
 ibin(iact) = 3                                   ! dt_i = 1/8, whatever dt the call passes
 call do_fld_implicit(1.,npart,xyzh,vxyzu)
 du_dt2 = duFLD(iact)
 call checkval(abs(du_dt2) > abs(du_dt1),.true.,nfail(2),'the particle uses its own bin dt (shorter dt, faster rate)')

 ! every other particle active: the exchange with the inactive half is not returned this step
 do i=1,npart
    iphase(i) = isetphase(igas,iactive=(mod(i,2)==0))
 enddo
 ibin(1:npart) = 0
 call do_fld_implicit(1.,npart,xyzh,vxyzu)
 if (id==master) write(*,"(a,es10.3,a,es10.3)") '  leak, one active particle: ',leak1, &
    '  half the particles active: ',fld_leak
 call checkval(abs(fld_leak) <= 1.,.true.,nfail(3),'half active: leak finite and within [-1,1]')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_fixed_boundary

!-----------------------------------------------------------------------
! a sweep cap of 5 at dt = 100 t_cell: the step is split until it
! converges, with T' bounded. With splitting off as well, and one sweep
! at dt >> t_diff: warn, and the flux-limited exchange keeps T' within the old
! extremes, with no NaN
!-----------------------------------------------------------------------
subroutine test_fld_implicit_capped(ntests,npass)
 use eos_stamatellos, only:duFLD
 use fld_implicit,    only:fld_sweep_cap,fld_split_depth,fld_nsplits,fld_resid,fld_tol
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(6),cap_old,depth_old
 real    :: dt,Tmin,Tmax

 if (id==master) write(*,"(/,a)") '--> FLD implicit: sweep cap reached'
 if (.not. fld_box('step',1.)) return
 cap_old = fld_sweep_cap; depth_old = fld_split_depth
 dt = 100.*t_cell()
 fld_sweep_cap = 5
 call solve_at(dt)
 call T_range(dt,Tmin,Tmax)
 if (id==master) write(*,"(a,i5,a,es10.3,a,2(1x,f9.4))") '  cap 5: splits ',fld_nsplits,'  residual ',fld_resid, &
    '  T min max',Tmin,Tmax
 nfail(:) = 0
 call checkval(fld_nsplits > 0 .and. fld_resid < fld_tol,.true.,nfail(1),'cap 5 at dt = 100 t_cell: converges by splitting')
 call checkval(Tmin >= 30.*(1.-1.e-6) .and. Tmax <= 60.*(1.+1.e-6),.true.,nfail(2), &
               'cap 5 at dt = 100 t_cell: T within the old extremes')
 call checkval(all(duFLD(1:npart) == duFLD(1:npart)),.true.,nfail(3),'cap 5 at dt = 100 t_cell: finite du_FLD')

 dt = 1.e6
 fld_sweep_cap = 1; fld_split_depth = 0
 call solve_at(dt)
 call T_range(dt,Tmin,Tmax)
 if (id==master) write(*,"(a,es10.3,a,2(1x,f9.4))") '  one sweep, no splits: residual ',fld_resid,'  T min max',Tmin,Tmax
 call checkval(fld_resid > fld_tol,.true.,nfail(4),'one sweep at dt >> t_diff: not converged')
 call checkval(all(duFLD(1:npart) == duFLD(1:npart)),.true.,nfail(5),'one sweep at dt >> t_diff: finite du_FLD')
 call checkval(Tmin >= 30.*(1.-1.e-6) .and. Tmax <= 60.*(1.+1.e-6),.true.,nfail(6), &
               'one sweep at dt >> t_diff: T within the old extremes')
 fld_sweep_cap = cap_old; fld_split_depth = depth_old
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_capped

!-----------------------------------------------------------------------
! the lowest and highest temperature the particles reach after dt
!-----------------------------------------------------------------------
subroutine T_range(dt,Tmin,Tmax)
 use part, only:npart
 real, intent(in)  :: dt
 real, intent(out) :: Tmin,Tmax
 integer :: i

 Tmin = huge(0.); Tmax = -huge(0.)
 do i=1,npart
    Tmin = min(Tmin,T_after(i,dt)); Tmax = max(Tmax,T_after(i,dt))
 enddo

end subroutine T_range

!-----------------------------------------------------------------------
! the shortest cell diffusion time, min_i c_v,i / sum_j K_ij, of the
! current box (code time)
!-----------------------------------------------------------------------
real function t_cell()
 use fld_implicit, only:fld_tcell

 call solve_at(1.e-8)
 t_cell = fld_tcell

end function t_cell

!-----------------------------------------------------------------------
! sweeps, splits, residual and leak at dt/t_cell = 1, 10, 100, 1000; at
! 1000 the result meets the residual criterion everywhere
!-----------------------------------------------------------------------
subroutine test_fld_implicit_residual(ntests,npass)
 use eos_stamatellos, only:duFLD
 use fld_implicit,    only:fld_nsweeps,fld_nsplits,fld_resid,fld_leak,fld_tol
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(2),m
 real    :: tc,ratio

 if (id==master) write(*,"(/,a)") '--> FLD implicit: residual criterion'
 if (.not. fld_box('step',1.)) return
 tc = t_cell()
 if (id==master) write(*,"(a,es10.3)") '  t_cell (code time) ',tc
 do m=0,3
    ratio = 10.**m
    call solve_at(ratio*tc)
    if (id==master) write(*,"(a,es8.1,a,i7,a,i5,a,es10.3,a,es10.3)") '  dt/t_cell ',ratio,'  sweeps ',fld_nsweeps, &
       '  splits ',fld_nsplits,'  residual ',fld_resid,'  leak ',fld_leak
 enddo
 nfail(:) = 0
 call checkval(fld_resid < fld_tol,.true.,nfail(1),'dt = 1e3 t_cell: max |r_i|/(c_v,i T_i) < fld_tol')
 call checkval(all(duFLD(1:npart) == duFLD(1:npart)),.true.,nfail(2),'dt = 1e3 t_cell: finite du_FLD')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_residual

!-----------------------------------------------------------------------
! the stiffness max_i sum_j K_ij dt_ij / c_v,i uses each particle's own
! step: dt/t_cell when every particle is on the step passed in, and
! dt_i/t_cell when (individual timesteps) the particles are on a longer one
!-----------------------------------------------------------------------
subroutine test_fld_implicit_stiffness(ntests,npass)
 use dim,          only:ind_timesteps
 use fld_implicit, only:do_fld_implicit,fld_stiff,fld_tcell
 use io,           only:id,master
 use part,         only:npart,xyzh,vxyzu,ibin
 use testutils,    only:checkval,update_test_scores
 use timestep,     only:dtmax
 integer, intent(inout) :: ntests,npass
 integer :: nfail(2)
 real    :: tc

 if (id==master) write(*,"(/,a)") '--> FLD implicit: stiffness diagnostic'
 if (.not. fld_box('step',1.)) return
 tc = t_cell()
 nfail(:) = 0
 call solve_at(10.*tc)
 if (id==master) write(*,"(a,es12.5)") '  dt = 10 t_cell: stiffness ',fld_stiff
 call checkval(fld_stiff,10.*tc/fld_tcell,1.e-12,nfail(1),'stiffness = dt/t_cell, all on the step')
 if (ind_timesteps) then
    dtmax = 10.*tc; ibin(1:npart) = 0
    call do_fld_implicit(0.25*dtmax,npart,xyzh,vxyzu)
    if (id==master) write(*,"(a,es12.5,a,es12.5)") '  bin 0, dt passed dtmax/4: stiffness ',fld_stiff, &
       '  dt/t_cell ',0.25*dtmax/fld_tcell
    call checkval(fld_stiff,dtmax/fld_tcell,1.e-12,nfail(2),'stiffness uses dt_i, not the dt passed in')
 endif
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_stiffness

!-----------------------------------------------------------------------
! the run totals for the end-of-run summary: every solve is counted,
! and a solve that reaches the limiter is counted as limited with its
! residual; fld_summary reports them
!-----------------------------------------------------------------------
subroutine test_fld_implicit_run_counts(ntests,npass)
 use fld_implicit, only:fld_sweep_cap,fld_split_depth,fld_resid,fld_summary, &
                        fld_nsolves_run,fld_nlimited_run,fld_resid_limited
 use io,           only:id,master
 use testutils,    only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(5),ns,nl,cap_old,depth_old,iu
 real    :: tc
 character(len=200) :: line

 if (id==master) write(*,"(/,a)") '--> FLD implicit: run totals for the end-of-run summary'
 if (.not. fld_box('step',1.)) return
 tc = t_cell()
 nfail(:) = 0
 ns = fld_nsolves_run; nl = fld_nlimited_run
 call solve_at(10.*tc)
 call checkval(fld_nsolves_run == ns+1 .and. fld_nlimited_run == nl,.true.,nfail(1), &
               'a converged solve is counted, not as limited')
 cap_old = fld_sweep_cap; depth_old = fld_split_depth
 fld_sweep_cap = 1; fld_split_depth = 0
 call solve_at(1.e3*tc)
 fld_sweep_cap = cap_old; fld_split_depth = depth_old
 call checkval(fld_nsolves_run == ns+2 .and. fld_nlimited_run == nl+1,.true.,nfail(2), &
               'a solve that reaches the limiter is counted as limited')
 call checkval(fld_resid_limited >= fld_resid .and. fld_resid_limited > 0.,.true.,nfail(3), &
               'the worst limited residual is kept')
 open(newunit=iu,status='scratch',action='readwrite')
 call fld_summary(iu)
 rewind(iu)
 line = ''
 read(iu,"(a)",end=10) line
10 close(iu)
 if (id==master) write(*,"(a,a)") '  summary: ',trim(line)
 call checkval(index(line,'flux-limited') > 0,.true.,nfail(4),'fld_summary reports the limited solves')
 fld_nsolves_run = 0; fld_nlimited_run = 0; fld_resid_limited = 0.
 open(newunit=iu,status='scratch',action='readwrite')
 call fld_summary(iu)
 rewind(iu)
 line = ''
 read(iu,"(a)",end=20) line
20 close(iu)
 call checkval(len_trim(line) == 0,.true.,nfail(5),'fld_summary is silent when nothing was solved')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_run_counts

!-----------------------------------------------------------------------
! a sweep cap of 5 at dt = 10 t_cell: the solve converges by splitting
! the step, and agrees with an unsplit solve under a large cap to within
! the time-discretisation difference of one backward-Euler step against
! 16 steps of dt/16 (measured 0.17 of max |du| free, 0.22 periodic)
!-----------------------------------------------------------------------
subroutine test_fld_implicit_split(ntests,npass)
 use eos_stamatellos, only:duFLD
 use fld_implicit,    only:fld_sweep_cap,fld_nsweeps,fld_nsplits,fld_resid,fld_tol
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(4),cap_old,nsweep_ref,nsplit_ref
 real    :: dt,err
 real, allocatable :: du_ref(:)

 if (id==master) write(*,"(/,a)") '--> FLD implicit: step splitting when the sweep cap is reached (dt = 10 t_cell)'
 if (.not. fld_box('step',1.)) return
 dt = 10.*t_cell()
 cap_old = fld_sweep_cap
 fld_sweep_cap = 100000
 call solve_at(dt)
 du_ref = duFLD(1:npart); nsweep_ref = fld_nsweeps; nsplit_ref = fld_nsplits
 fld_sweep_cap = 5
 call solve_at(dt)
 fld_sweep_cap = cap_old
 err = maxval(abs(duFLD(1:npart) - du_ref))/maxval(abs(du_ref))
 if (id==master) write(*,"(a,i7,a,i7,a,i5,a,es10.3)") '  reference sweeps ',nsweep_ref,'  capped: sweeps ',fld_nsweeps, &
    '  splits ',fld_nsplits,'  max |du - du_ref|/max |du_ref| ',err
 nfail(:) = 0
 call checkval(nsplit_ref,0,0,nfail(1),'large cap: reference converges without splitting')
 call checkval(fld_nsplits > 0,.true.,nfail(2),'cap 5: the step is split')
 call checkval(fld_resid < fld_tol,.true.,nfail(3),'cap 5: converged after splitting')
 call checkval(err,0.,0.3,nfail(4),'cap 5: du_FLD matches the unsplit reference')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_split

!-----------------------------------------------------------------------
! splitting off and one sweep at dt = 1e3 t_cell: far from converged,
! but the pairwise update still conserves sum m du_FLD to round-off,
! and the pair coefficients are exactly symmetric
!-----------------------------------------------------------------------
subroutine test_fld_implicit_conserve_unconverged(ntests,npass)
 use eos_stamatellos, only:duFLD
 use fld_implicit,    only:fld_sweep_cap,fld_split_depth,fld_resid,fld_leak,fld_tol,fld_pair_asymmetry
 use io,              only:id,master
 use part,            only:npart,massoftype,igas
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(6),cap_old,depth_old,i
 real    :: dt,dsum,dabs,Tmin,Tmax,asym

 if (id==master) write(*,"(/,a)") '--> FLD implicit: conservation without convergence'
 if (.not. fld_box('step',1.)) return
 dt = 1.e3*t_cell()
 cap_old = fld_sweep_cap; depth_old = fld_split_depth
 fld_sweep_cap = 1; fld_split_depth = 0
 call solve_at(dt)
 fld_sweep_cap = cap_old; fld_split_depth = depth_old
 asym = fld_pair_asymmetry()
 dsum = 0.; dabs = 0.; Tmin = huge(0.); Tmax = -huge(0.)
 do i=1,npart
    dsum = dsum + massoftype(igas)*duFLD(i)*dt; dabs = dabs + massoftype(igas)*abs(duFLD(i))*dt
    Tmin = min(Tmin,T_after(i,dt)); Tmax = max(Tmax,T_after(i,dt))
 enddo
 if (id==master) write(*,"(a,es10.3,a,es10.3,a,es10.3,a,2(1x,es10.3))") '  residual ',fld_resid, &
    '  sum m du/sum m |du| ',dsum/max(dabs,tiny(0.)),'  leak ',fld_leak,'  T min max',Tmin,Tmax
 nfail(:) = 0
 call checkval(fld_resid > fld_tol,.true.,nfail(1),'one sweep, no splitting: not converged')
 call checkval(all(duFLD(1:npart) == duFLD(1:npart)),.true.,nfail(2),'not converged: finite du_FLD')
 call checkval(abs(dsum)/max(dabs,tiny(0.)) < 1.e-12,.true.,nfail(3),'not converged: sum m du_FLD = 0 to round-off')
 call checkval(abs(fld_leak) < 1.e-12,.true.,nfail(4),'not converged: |fld_leak| < 1e-12')
 call checkval(asym,0.,0.,nfail(5),'K_ij = K_ji exactly')
 call checkval(dabs > 0. .and. Tmin >= 30.*(1.-1.e-6) .and. Tmax <= 60.*(1.+1.e-6),.true.,nfail(6), &
               'not converged: energy still moves, T within the old extremes')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_conserve_unconverged

!-----------------------------------------------------------------------
! individual timesteps: an active particle's exchange with an inactive
! neighbour goes to the neighbour's owed_FLD, which the neighbour applies
! (and zeroes) when it next solves, so a full cycle conserves energy to
! round-off; two active particles in different bins exchange over the
! shorter of their two steps
!-----------------------------------------------------------------------
subroutine test_fld_implicit_owed(ntests,npass)
 use dim,             only:ind_timesteps,maxp,maxphase
 use eos_stamatellos, only:duFLD,owed_FLD,lambda_FLD
 use fld_implicit,    only:do_fld_implicit
 use io,              only:id,master
 use part,            only:npart,xyzh,vxyzu,iphase,isetphase,igas,ibin,iactive
 use testutils,       only:checkval,update_test_scores
 use timestep,        only:dtmax
 use timestep_ind,    only:get_dt
 integer, intent(inout) :: ntests,npass
 integer :: nfail(8),i,i1,i2
 real    :: ecycle,eabs,ei,eB,oB,e02,e22,e00,pair02
 real, allocatable :: r2(:)

 if (id==master) write(*,"(/,a)") '--> FLD implicit: owed exchange with inactive neighbours'
 if (.not. ind_timesteps .or. maxphase /= maxp) then
    if (id==master) write(*,"(a)") '  --> skipping (needs individual timesteps)'
    return
 endif
 if (.not. fld_box('step',1.)) return
 dtmax = 10.*t_cell()
 i1 = minloc(abs(xyzh(1,1:npart)),1)               ! a particle at the step
 nfail(:) = 0
 ecycle = 0.; eabs = 0.
 ! A: everyone active, i1 in bin 1 and the rest in bin 0
 ibin(1:npart) = 0; ibin(i1) = 1
 iphase(1:npart) = isetphase(igas,iactive=.true.)
 call do_fld_implicit(dtmax,npart,xyzh,vxyzu)
 call add_energy()
 call checkval(all(owed_FLD(1:npart) == 0.),.true.,nfail(1),'everyone active: nothing owed')
 ! B: half way through the bin-0 step only i1 is active
 do i=1,npart
    iphase(i) = isetphase(igas,iactive=(i==i1))
 enddo
 call do_fld_implicit(dtmax,npart,xyzh,vxyzu)
 eB = duFLD(i1)*get_dt(dtmax,ibin(i1)); oB = sum(owed_FLD(1:npart))
 call add_energy()
 if (id==master) write(*,"(a,es12.4,a,es12.4,a,i5)") '  i1 alone: energy in ',eB,'  owed by it ',oB, &
    '  neighbours owed ',count(owed_FLD(1:npart) /= 0.)
 call checkval(abs(eB) > 0. .and. count(owed_FLD(1:npart) /= 0.) > 0,.true.,nfail(2),'inactive neighbours are owed')
 call checkval(abs(eB + oB) <= 1.e-12*abs(eB),.true.,nfail(3),'what i1 gains its neighbours are owed')
 ! C: everyone active again at the end of the bin-0 step
 iphase(1:npart) = isetphase(igas,iactive=.true.)
 call do_fld_implicit(dtmax,npart,xyzh,vxyzu)
 call add_energy()
 if (id==master) write(*,"(a,es12.4,a,es12.4)") '  cycle: sum m du dt ',ecycle,'  sum m |du dt| ',eabs
 call checkval(all(owed_FLD(1:npart) == 0.),.true.,nfail(4),'owed applied and zeroed when the neighbours solve')
 call checkval(abs(ecycle) <= 1.e-12*eabs,.true.,nfail(5),'a full cycle conserves energy to round-off')

 ! two active neighbours across the step, every other particle with k = 0
 allocate(r2(npart))
 do i=1,npart
    r2(i) = sum((xyzh(1:3,i) - xyzh(1:3,i1))**2)
    if (xyzh(1,i)*xyzh(1,i1) >= 0.) r2(i) = huge(0.)
 enddo
 i2 = minloc(r2,1)
 lambda_FLD(1:npart) = 0.; lambda_FLD(i1) = 1./3.; lambda_FLD(i2) = 1./3.
 do i=1,npart
    iphase(i) = isetphase(igas,iactive=(i==i1 .or. i==i2))
 enddo
 e02 = pair_energy(0_1,2_1,pair02)
 e22 = pair_energy(2_1,2_1)
 e00 = pair_energy(0_1,0_1)
 if (id==master) write(*,"(a,3es12.4,a,es10.3,a,es10.3)") '  pair energy, bins (0,2) (2,2) (0,0):',e02,e22,e00, &
    '  i1 + i2 ',pair02,'  (0,2)/(2,2) - 1 ',e02/e22 - 1.
 call checkval(abs(e02 - e22) <= 1.e-6*abs(e22),.true.,nfail(6),'bins 0 and 2 exchange over the bin-2 step')
 call checkval(abs(e02 - e00) > 1.e-3*abs(e00),.true.,nfail(7),'and not over the bin-0 step')
 call checkval(abs(pair02) <= 1.e-14*abs(e02),.true.,nfail(8),'the pair exchange is antisymmetric')
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

contains

subroutine add_energy()
 do i=1,npart
    if (.not.iactive(iphase(i))) cycle
    ei = duFLD(i)*get_dt(dtmax,ibin(i))
    ecycle = ecycle + ei; eabs = eabs + abs(ei)
 enddo
end subroutine add_energy

! energy per unit mass i1 gains with i1 in bin b1 and i2 in bin b2; sum is that plus i2's
real function pair_energy(b1,b2,sum12)
 integer(kind=1), intent(in) :: b1,b2
 real, intent(out), optional :: sum12
 ibin(i1) = b1; ibin(i2) = b2
 owed_FLD(1:npart) = 0.
 call do_fld_implicit(dtmax,npart,xyzh,vxyzu)
 pair_energy = duFLD(i1)*get_dt(dtmax,b1)
 if (present(sum12)) sum12 = pair_energy + duFLD(i2)*get_dt(dtmax,b2)
end function pair_energy

end subroutine test_fld_implicit_owed

!-----------------------------------------------------------------------
! do FLD = 2 through derivs: the solve runs after the density pass (its
! du_FLD is the direct solve's), the force pass leaves du_FLD alone, T
! stays bounded at dt = 10 t_cell, and a corrector repeat (icall = 2)
! keeps du_FLD as it was
!-----------------------------------------------------------------------
subroutine test_fld_implicit_derivs(ntests,npass)
 use deriv,           only:get_derivs_global
 use eos_stamatellos, only:duFLD,fld_mode
 use fld_implicit,    only:fld_nsweeps
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(4),fld_mode_old,nsweeps
 real    :: dt,err,Tmin,Tmax
 real, allocatable :: du_direct(:),du_first(:),du_repeat(:)

 if (id==master) write(*,"(/,a)") '--> FLD implicit: do FLD = 2 runs the solve in derivs'
 if (.not. fld_box('step',1.)) return
 fld_mode_old = fld_mode; fld_mode = 2
 dt = 10.*t_cell()                       ! no splitting, so the two solves take the same path
 call solve_at(dt)                       ! sets dtmax = dt and bin 0, as derivs will see them
 duFLD(1:npart) = 0.; fld_nsweeps = 0
 call get_derivs_global(dt=dt)
 nsweeps = fld_nsweeps
 du_first = duFLD(1:npart)
 call T_range(dt,Tmin,Tmax)
 call get_derivs_global(dt=dt,icall=2)
 du_repeat = duFLD(1:npart)
 call solve_at(dt)                       ! the direct solve, with the lambda this density pass left
 du_direct = duFLD(1:npart)
 err = maxval(abs(du_first - du_direct))/maxval(abs(du_direct))
 if (id==master) write(*,"(a,i6,a,es10.3,a,2(1x,f9.4))") '  derivs: sweeps ',nsweeps, &
    '  max |du - du_direct|/max |du_direct| ',err,'  T min max',Tmin,Tmax
 nfail(:) = 0
 call checkval(nsweeps > 0,.true.,nfail(1),'derivs runs the implicit solve')
 call checkval(err,0.,1.e-3,nfail(2),'derivs du_FLD = the direct solve (force pass leaves it)')
 call checkval(Tmin >= 30.*(1.-1.e-6) .and. Tmax <= 60.*(1.+1.e-6),.true.,nfail(3), &
               'derivs at dt = 10 t_cell: T within the old extremes')
 call checkval(all(du_repeat == du_first),.true.,nfail(4),'corrector repeat (icall = 2) keeps du_FLD')
 fld_mode = fld_mode_old
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_derivs

!-----------------------------------------------------------------------
! do FLD = 2 through derivs at small dt matches the continuum rate
! (1/rho) div(k grad T) for a sine wave, as test_diffusion_rate checks
! for do FLD = 1
!-----------------------------------------------------------------------
subroutine test_fld_implicit_limit(ntests,npass)
 use boundary,        only:dxbound
 use deriv,           only:get_derivs_global
 use dim,             only:periodic
 use eos_stamatellos, only:duFLD,get_k_fld,fld_mode
 use io,              only:id,master
 use part,            only:npart,xyzh,vxyzu,massoftype,igas,rhoh
 use physcon,         only:pi
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(1),i,n,fld_mode_old
 real    :: wk2,rhoi,ki,Ti,expected,rsum,dt

 if (id==master) write(*,"(/,a)") '--> FLD implicit: do FLD = 2 at small dt matches (1/rho) div(k grad T)'
 if (.not. fld_box('sine',0.01)) return
 fld_mode_old = fld_mode; fld_mode = 2
 dt = 1.e-3*t_cell()
 call get_derivs_global(dt=dt)
 wk2 = (2.*pi/dxbound)**2
 n = 0; rsum = 0.
 do i=1,npart
    if (.not.(periodic .or. all(abs(xyzh(1:3,i)) < 0.25))) cycle
    if (abs(sin(2.*pi*xyzh(1,i)/dxbound)) < 0.5) cycle
    rhoi = rhoh(xyzh(4,i),massoftype(igas))
    call get_k_fld(rhoi,vxyzu(4,i),i,ki,Ti)
    expected = -(ki/rhoi)*wk2*(Ti - 30.)
    n = n + 1; rsum = rsum + duFLD(i)/expected
 enddo
 if (id==master) write(*,"(a,i6,a,es12.5)") '  particles ',n,'  du_FLD/continuum mean ',rsum/max(n,1)
 nfail(:) = 0
 call checkval(rsum/max(n,1),1.,0.05,nfail(1),'do FLD = 2 at small dt matches (1/rho) div(k grad T)')
 fld_mode = fld_mode_old
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_limit

!-----------------------------------------------------------------------
! the step at dt/t_cell = 1, 10, 100, 1000 with each solver: CG converges
! without splitting, in under a quarter of the Gauss-Seidel sweeps at
! 1000 (iterations ~ sqrt(dt/t_cell) against ~ dt/t_cell), to the same T' (each solve is within fld_tol T_hi of the exact
! T' in max norm, and its exchange within fld_tol T_hi more, so the two
! differ by at most 4 fld_tol T_hi); and a repeated CG solve is bitwise
! identical
!-----------------------------------------------------------------------
subroutine test_fld_implicit_cg(ntests,npass)
 use eos_stamatellos, only:duFLD,fld_solver
 use fld_implicit,    only:fld_nsweeps,fld_nsplits,fld_resid,fld_leak,fld_tol
 use io,              only:id,master
 use part,            only:npart
 use testutils,       only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(5),m,i,solver_old,nsw(2,0:3)
 real    :: tc,dt,dTmax,dTworst,resid_cg
 real, allocatable :: T_gs(:),du_cg(:)
 logical :: cg_clean

 if (id==master) write(*,"(/,a)") '--> FLD implicit: Jacobi-PCG against Gauss-Seidel'
 if (.not. fld_box('step',1.)) return    ! 30 K and 60 K halves
 solver_old = fld_solver
 tc = t_cell()
 allocate(T_gs(npart))
 cg_clean = .true.; dTworst = 0.; resid_cg = 0.
 do m=0,3
    dt = 10.**m*tc
    fld_solver = 1
    call solve_at(dt)
    nsw(1,m) = fld_nsweeps
    do i=1,npart
       T_gs(i) = T_after(i,dt)
    enddo
    fld_solver = 2
    call solve_at(dt)
    nsw(2,m) = fld_nsweeps
    cg_clean = cg_clean .and. fld_nsplits == 0 .and. fld_resid < fld_tol
    resid_cg = max(resid_cg,fld_resid)
    dTmax = 0.
    do i=1,npart
       dTmax = max(dTmax,abs(T_after(i,dt) - T_gs(i)))
    enddo
    dTworst = max(dTworst,dTmax)
    if (id==master) write(*,"(a,es8.1,a,i7,a,i6,a,i4,a,es10.3,a,es10.3,a,es10.3)") '  dt/t_cell ',10.**m, &
       '  GS sweeps ',nsw(1,m),'  CG iterations ',nsw(2,m),'  splits ',fld_nsplits,'  residual ',fld_resid, &
       '  leak ',fld_leak,'  max |T_CG - T_GS| (K) ',dTmax
 enddo
 dt = 100.*tc
 call solve_at(dt)
 du_cg = duFLD(1:npart)
 call solve_at(dt)
 nfail(:) = 0
 call checkval(cg_clean,.true.,nfail(1),'CG: converged without splitting at dt/t_cell = 1 to 1000')
 call checkval(dTworst <= 4.*fld_tol*60.,.true.,nfail(2),'CG: T'' = the Gauss-Seidel T'' within 4 fld_tol T_hi')
 call checkval(4*nsw(2,3) < nsw(1,3),.true.,nfail(3),'CG: < 1/4 the Gauss-Seidel sweeps at 1000 t_cell')
 call checkval(all(nsw(2,:) > 0),.true.,nfail(4),'CG: iterations counted in fld_nsweeps')
 call checkval(all(duFLD(1:npart) == du_cg),.true.,nfail(5),'CG: a repeated solve is bitwise identical')
 fld_solver = solver_old
 call update_test_scores(ntests,nfail,npass)
 call fld_box_done()

end subroutine test_fld_implicit_cg

end module testfld
