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
 use mass_loading, only: iload_factor, iload, iload_dt, &
                         dm_load, mloadfactor, r_orb, t_orb, &
                         init_massloading, step_mass_loading
 implicit none
 public :: test_massloading
 private

contains

subroutine test_massloading(ntests, npass)
 use io,        only: id, master
 integer, intent(inout) :: ntests, npass
 if (id == master) write(*,"(/,a,/)") '--> TESTING MASS LOADING MODULE'
 call test_init(ntests, npass)
 call test_apply(ntests, npass)
end subroutine test_massloading

!---------------------------------------------------------------------------
! test_init: verify dm_load and mloadfactor are correctly derived for each type
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

 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 m_disc0 = massoftype(igas) * real(npartoftypetot(igas))   ! = 0.1

 ! type 0: chi mode — user gives chi, derive xi
 iload_factor = 0;  iload = 0.1;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(mloadfactor, 0.1,         tol, nfailed(1), 'type0: mloadfactor = chi')
 call checkval(dm_load,     0.1*m_disc0, tol, nfailed(2), 'type0: dm_load = chi*Mdisc0')

 ! type 1: xi mode — user gives xi, back-derive chi
 iload_factor = 1;  iload = 0.01
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(dm_load,     0.01,            tol, nfailed(3), 'type1: dm_load = xi')
 call checkval(mloadfactor, 0.01/m_disc0,    tol, nfailed(4), 'type1: mloadfactor = xi/Mdisc0')

 ! type 2: beta mode — mloadfactor = beta, dm_load = 0
 iload_factor = 2;  iload = 0.05
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(mloadfactor, 0.05, tol, nfailed(5), 'type2: mloadfactor = beta')
 call checkval(dm_load,     0.,   tol, nfailed(6), 'type2: dm_load = 0')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_init

!---------------------------------------------------------------------------
! test_apply: verify massoftype changes correctly for each loading type
!---------------------------------------------------------------------------
subroutine test_apply(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer(kind=1) :: nbinmax_test
 integer         :: nfailed(3)
 real    :: m_before, dt_test, t_orb_test, m_expected, scale
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> apply loading tests'
 nfailed(:) = 0

 ! Set up a sink for M_star (needed by calc_massloading_rate when calc_torb=.true.)
 ! Use fixed iload_dt so calc_torb=.false., avoiding MPI bcast complications in unit test.
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 t_orb_test           = 2.0
 dt_test              = 0.01
 nbinmax_test         = 0_1     ! 2**0 = 1

 ! --- type 0: constant chi ---
 iload_factor = 0;  iload = 0.1;  iload_dt = t_orb_test  ! fixed interval = t_orb
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 ! step_massloading with istepfrac=1 == 2**nbinmax_test triggers t_orb update
 m_before   = massoftype(igas)
 m_expected = m_before + dm_load * dt_test / (t_orb_test * real(npartoftypetot(igas)))
 call step_mass_loading(0., dt_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(1), 'type0: massoftype increments correctly')

 ! --- type 1: constant xi ---
 iload_factor = 1;  iload = 0.01;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 massoftype(igas) = 1.e-4      ! reset
 call init_massloading()
 m_before   = massoftype(igas)
 m_expected = m_before + dm_load * dt_test / (t_orb_test * real(npartoftypetot(igas)))
 call step_mass_loading(0., dt_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(2), 'type1: massoftype increments correctly')

 ! --- type 2: exponential beta ---
 iload_factor = 2;  iload = 0.05;  iload_dt = t_orb_test
 dm_load = 0.;  mloadfactor = 0.
 massoftype(igas) = 1.e-4
 call init_massloading()
 m_before   = massoftype(igas)
 scale      = exp(log(1. + mloadfactor) * dt_test / t_orb_test)
 m_expected = m_before * scale
 call step_mass_loading(0., dt_test, t_orb_test, 1, nbinmax_test)
 call checkval(massoftype(igas), m_expected, tol, nfailed(3), 'type2: massoftype scales correctly')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_apply

end module testmassloading
