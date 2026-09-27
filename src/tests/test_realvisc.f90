!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module testrealvisc
!
! Unit tests for the Shakura-Sunyaev physical viscosity (viscosity.f90).
!
! :Dependencies: io, part, testutils, viscosity
! :Owner: will-roscoe
!
 implicit none
 public :: test_realvisc
 private

contains

subroutine test_realvisc(ntests, npass)
 use io,        only:id,master
 use part,      only:nptmass,xyzmh_ptmass
 use testutils, only:checkval,update_test_scores
 use viscosity, only:irealvisc,shearparam,shearfunc
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(4), nptmass_save
 real    :: nu, nu_expected, cs, r
 real, parameter :: tol = 1.e-10

 if (id == master) write(*,"(/,a,/)") '--> TESTING SHAKURA-SUNYAEV PHYSICAL VISCOSITY'
 nfailed(:) = 0
 nptmass_save = nptmass
 shearparam = 0.005
 cs = 0.02
 r  = 30.

 ! irealvisc=4: nu = alpha cs^2 / Omega, Omega = sqrt(M/r^3) about sink 1
 irealvisc = 4
 nptmass = 1
 xyzmh_ptmass(:,1) = 0.
 xyzmh_ptmass(1,1) = 2.;  xyzmh_ptmass(2,1) = -1.
 xyzmh_ptmass(4,1) = 0.0477
 nu = shearfunc(2. + r, -1., 0., cs)
 nu_expected = shearparam*cs**2/sqrt(0.0477/r**3)
 call checkval(nu, nu_expected, tol, nfailed(1), 'irealvisc=4: Keplerian about the host mass and position')

 ! off the midplane: r is the spherical distance from the host, as in case(2)
 nu = shearfunc(2. + 3., -1. + 4., 12., cs)
 nu_expected = shearparam*cs**2/sqrt(0.0477/13.**3)
 call checkval(nu, nu_expected, tol, nfailed(2), 'irealvisc=4: spherical distance from the host')

 ! no sink: no viscosity rather than an assumed host
 nptmass = 0
 nu = shearfunc(r, 0., 0., cs)
 call checkval(nu, 0., tol, nfailed(3), 'irealvisc=4: zero without a host sink')

 ! irealvisc=2 unchanged: G*M = 1 about the origin
 irealvisc = 2
 nu = shearfunc(r, 0., 0., cs)
 nu_expected = shearparam*cs**2*r**1.5
 call checkval(nu, nu_expected, tol, nfailed(4), 'irealvisc=2: unchanged (G*M = 1, origin)')

 irealvisc = 0
 nptmass = nptmass_save
 call update_test_scores(ntests, nfailed, npass)
end subroutine test_realvisc

end module testrealvisc
