!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module test_flooredprof
!
! Unit tests of the floored power-law temperature profile (get_T_profile)
!
! :References: Mercer & Stamatellos 2020 (n=2 preset)
! :Owner: will-roscoe
! :Runtime parameters: None
! :Dependencies: eos_stamatellos, physcon, testutils, units
!
 use testutils,       only:checkval,update_test_scores
 use eos_stamatellos, only:get_T_profile,iprofile,T0_prof,n_prof,R0_prof,T_bg_prof,qprofile
 implicit none
 public :: run_test_flooredprof
 private
contains

subroutine run_test_flooredprof(ntests,npass)
 use units,   only:set_units
 use physcon, only:au,solarm
 integer, intent(inout) :: ntests,npass
 integer :: nfail(4)
 real(kind=8) :: tol

 call set_units(dist=au,mass=solarm,G=1.d0)   ! code radius r == radius in AU
 iprofile  = 2
 T0_prof   = 100.d0
 n_prof    = 2.d0
 R0_prof   = 0.01d0
 T_bg_prof = 10.d0
 qprofile  = 0.d0            ! => q_eff default 0.35 (slope 0.7)
 tol       = 1.d-3
 nfail(:)  = 0

 ! MS20 preset values, hand-computed:
 call checkval(get_T_profile(1.d0),   100.495d0, tol, nfail(1), 'T(1 AU)   = 100.5 K')
 call checkval(get_T_profile(10.d0),   22.319d0, tol, nfail(2), 'T(10 AU)  = 22.3 K')
 call checkval(get_T_profile(1000.d0), 10.031d0, tol, nfail(3), 'T(1000AU) -> Tinf floor')

 ! qprofile override changes the slope: q_eff=0.4 at 10 AU
 qprofile = 0.4d0
 call checkval(get_T_profile(10.d0),   18.741d0, tol, nfail(4), 'T(10 AU) with qprofile=0.4')

 call update_test_scores(ntests,nfail,npass)

 iprofile = 1
 qprofile = 0.
end subroutine run_test_flooredprof

end module test_flooredprof
