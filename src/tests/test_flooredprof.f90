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
 use eos_stamatellos, only:get_T_profile,get_T0_from_lum,iprofile,T0_prof,n_prof,&
                           R0_prof,T_bg_prof,qprofile
 implicit none
 public :: run_test_flooredprof
 private
contains

subroutine run_test_flooredprof(ntests,npass)
 use units,   only:set_units
 use physcon, only:au,solarm
 integer, intent(inout) :: ntests,npass
 integer :: nfail(9)
 real(kind=8) :: tol,L_02

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
 qprofile = 0.d0

 !
 ! lumdisc=3: T0 derived from the stellar luminosity rather than read.
 ! sigma_SB T0^4 = L/(4 pi AU^2), the same normalisation get_cs_from_lum uses.
 !
 L_02 = 0.23d0*0.2d0**2.3d0          ! Eker relation at 0.2 Msun, as phantom applies it
 call checkval(get_T0_from_lum(L_02), 108.547d0, tol, nfail(5), 'T0(L* of 0.2 Msun)')
 call checkval(get_T0_from_lum(0.23d0*0.01d0**2.3d0), 19.388d0, tol, nfail(6), &
               'T0(L* of 0.01 Msun)')
 call checkval(get_T0_from_lum(1.d0), 395.451d0, tol, nfail(7), 'T0(1 Lsun)')

 ! T0 scales as L^(1/4), so 16x the luminosity is exactly 2x the temperature
 call checkval(get_T0_from_lum(16.d0*L_02)/get_T0_from_lum(L_02), 2.d0, tol, nfail(8), &
               'T0 scales as L^(1/4)')

 ! a derived T0 must feed get_T_profile unchanged
 T0_prof = get_T0_from_lum(L_02)
 call checkval(get_T_profile(1.d0), sqrt(T0_prof**2 + T_bg_prof**2), tol, nfail(9), &
               'derived T0 flows into get_T_profile')

 call update_test_scores(ntests,nfail,npass)

 iprofile = 1
 qprofile = 0.
 T0_prof  = 100.
end subroutine run_test_flooredprof

end module test_flooredprof
