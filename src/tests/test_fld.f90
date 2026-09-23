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
 integer :: nfail(4),ierr,i,ninner,nsteep,ieos_old,icooling_old
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

 call update_test_scores(ntests,nfail,npass)
 deallocate(lam1)
 call finish_eos(ieos,ierr)
 ieos = ieos_old; icooling = icooling_old; doFLD = doFLD_old; gamma = gamma_old

contains

 ! away from the edges, so a non-periodic build tests full kernels only
 logical function inner(xyzhi)
  real, intent(in) :: xyzhi(4)
  inner = periodic .or. all(abs(xyzhi(1:3)) < 0.3)
 end function inner

end subroutine test_first_pass

end module testfld
