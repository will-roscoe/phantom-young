!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module testmassloading
!
! Unit tests for the mass_loading module (evolve_massloading.f90).
!
! :Dependencies: io, mass_loading, part, testutils
! :Owner: will-roscoe
!
 use mass_loading, only: iload_factor, iload, iload_dt,          &
                         dm_load, mloadfactor, r_orb, t_orb,     &
                         t_init,                                  &
                         init_massloading, step_mass_loading,     &
                         reset_massloading
 implicit none
 public :: test_massloading
 private

contains

subroutine test_massloading(ntests, npass)
 use io, only: id, master
 integer, intent(inout) :: ntests, npass
 if (id == master) write(*,"(/,a,/)") '--> TESTING MASS LOADING MODULE'
 call test_init(ntests, npass)
 call test_apply(ntests, npass)
 call test_full_orbit(ntests, npass)
end subroutine test_massloading

!---------------------------------------------------------------------------
! test_init
!   Verify dm_load and mloadfactor are correctly derived for each mode.
!---------------------------------------------------------------------------
subroutine test_init(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(6)
 real     :: m_disc0
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> init derivation tests'
 nfailed(:) = 0

 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 m_disc0 = massoftype(igas) * real(npartoftypetot(igas))   ! = 0.1

 ! mode 0: chi — user gives chi, derive xi
 iload_factor = 0;  iload = 0.1;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(mloadfactor, 0.1,         tol, nfailed(1), 'mode0: mloadfactor = chi')
 call checkval(dm_load,     0.1*m_disc0, tol, nfailed(2), 'mode0: dm_load = chi*Mdisc0')

 ! mode 1: xi — user gives xi, back-derive chi
 iload_factor = 1;  iload = 0.01
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(dm_load,     0.01,         tol, nfailed(3), 'mode1: dm_load = xi')
 call checkval(mloadfactor, 0.01/m_disc0, tol, nfailed(4), 'mode1: mloadfactor = xi/Mdisc0')

 ! mode 2: beta — mloadfactor = beta, dm_load = 0
 iload_factor = 2;  iload = 0.05
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(mloadfactor, 0.05, tol, nfailed(5), 'mode2: mloadfactor = beta')
 call checkval(dm_load,     0.,   tol, nfailed(6), 'mode2: dm_load = 0')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_init

!---------------------------------------------------------------------------
! test_apply
!   Verify the direct-evaluation formula for each loading mode over a
!   single sub-step.  Uses t_init = 0. so elapsed time = time - 0. = time.
!---------------------------------------------------------------------------
subroutine test_apply(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer(kind=1) :: nbinmax_test
 integer  :: nfailed(3)
 real     :: mp_saved, m_expected, t_orb_test, dt_test
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> apply loading tests (direct evaluation)'
 nfailed(:)   = 0
 t_orb_test   = 2.0
 dt_test      = 0.5       ! time elapsed since t_init; step from t=0 to t=0.5
 nbinmax_test = 0_1       ! 2**0 = 1 -> triggers t_orb update each step

 ! --- mode 0: constant chi ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 0;  iload = 0.1;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init   = 0.
 mp_saved = massoftype(igas)
 m_expected = mp_saved + dm_load * dt_test / (t_orb_test * real(npartoftypetot(igas)))
 call step_mass_loading(dt_test, dt_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(1), 'mode0: direct eval at t=dt')

 ! --- mode 1: constant xi ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 1;  iload = 0.01;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init   = 0.
 mp_saved = massoftype(igas)
 m_expected = mp_saved + dm_load * dt_test / (t_orb_test * real(npartoftypetot(igas)))
 call step_mass_loading(dt_test, dt_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(2), 'mode1: direct eval at t=dt')

 ! --- mode 2: exponential beta ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 2;  iload = 0.05;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init   = 0.
 mp_saved = massoftype(igas)
 m_expected = mp_saved * exp(log(1. + mloadfactor) * dt_test / t_orb_test)
 call step_mass_loading(dt_test, dt_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(3), 'mode2: direct eval at t=dt')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_apply

!---------------------------------------------------------------------------
! test_full_orbit
!   After exactly one interval T the analytical result is exact:
!     mode 0/1:  m_p0 + xi / n_p0
!     mode 2:    m_p0 * (1 + beta)
!   This verifies the formulas reproduce the defining property of each mode.
!---------------------------------------------------------------------------
subroutine test_full_orbit(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer(kind=1) :: nbinmax_test
 integer  :: nfailed(3)
 real     :: mp_saved, m_expected, t_orb_test
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> full-orbit exact result tests'
 nfailed(:)   = 0
 t_orb_test   = 2.0
 nbinmax_test = 0_1

 ! --- mode 0: after one T, mass increased by chi*M_disc0 / n_p0 = xi / n_p0 ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 0;  iload = 0.1;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init   = 0.
 mp_saved = massoftype(igas)
 m_expected = mp_saved + dm_load / real(npartoftypetot(igas))   ! t - t_init = T
 call step_mass_loading(t_orb_test, t_orb_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(1), 'mode0: m_p0 + xi/n_p0 after one orbit')

 ! --- mode 1: same formula, xi set directly ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 1;  iload = 0.01;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init   = 0.
 mp_saved = massoftype(igas)
 m_expected = mp_saved + dm_load / real(npartoftypetot(igas))
 call step_mass_loading(t_orb_test, t_orb_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(2), 'mode1: m_p0 + xi/n_p0 after one orbit')

 ! --- mode 2: after one T, mass scaled by (1+beta) exactly ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 2;  iload = 0.05;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init   = 0.
 mp_saved = massoftype(igas)
 m_expected = mp_saved * (1. + mloadfactor)   ! exp(ln(1+beta)*T/T) = 1+beta
 call step_mass_loading(t_orb_test, t_orb_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(3), 'mode2: m_p0*(1+beta) after one orbit')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_full_orbit

end module testmassloading
