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
! :Dependencies: dump_utils, infile_utils, io, mass_loading, part, testutils
! :Owner: will-roscoe
!
 use mass_loading, only: iload_factor, iload, iload_dt,                  &
                         dm_load, mloadfactor, r_orb, t_orb,             &
                         t_init,                                          &
                         init_massloading, step_mass_loading,             &
                         log_massloading,                                 &
                         write_options_massloading, read_options_massloading,       &
                         write_options_massloading_setup, read_options_massloading_setup, &
                         write_headeropts_massloading, read_headeropts_massloading,  &
                         set_massloading_r_ref,                            &
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
 call test_init_edgecases(ntests, npass)
 call test_update_torb(ntests, npass)
 call test_apply_guards(ntests, npass)
 call test_step_guards(ntests, npass)
 call test_log_massloading(ntests, npass)
 call test_options_io(ntests, npass)
 call test_headeropts_io(ntests, npass)
 call test_set_r_ref(ntests, npass)
 call test_first_substep_init(ntests, npass)
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

!---------------------------------------------------------------------------
! test_init_edgecases
!   Covers init_massloading/parse_massloading branches not exercised by
!   test_init's fresh-start derivation: the n_p0<=0 bail-out, the dump-header
!   restart path (back-derives mloadfactor for chi/xi modes only), and the
!   "loading off / invalid mode" default case.
!---------------------------------------------------------------------------
subroutine test_init_edgecases(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(5)
 real     :: m_disc0
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> init edge-case tests'
 nfailed(:) = 0

 ! --- n_p0 <= 0: bails out before parse_massloading; derived values untouched ---
 call reset_massloading()
 npartoftypetot(igas) = 0
 iload_factor = 0;  iload = 0.5;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(dm_load, 0., tol, nfailed(1), 'n_p0<=0: bails out, dm_load left at 0')

 ! --- restart path, chi/xi modes: dm_load preset (as if read from dump header);
 !     mloadfactor is back-derived from dm_load/M_disc0 ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 m_disc0 = massoftype(igas) * real(npartoftypetot(igas))
 iload_factor = 1;  iload = 0.;  iload_dt = -1.
 dm_load = 0.02;  mloadfactor = 0.   ! simulates header-restored dm_load
 call init_massloading()
 call checkval(mloadfactor, dm_load/m_disc0, tol, nfailed(2), &
    'restart (mode1): mloadfactor back-derived from dm_load/M_disc0')

 ! --- restart path, beta mode: dm_load preset is *not* used to back-derive
 !     mloadfactor (mloadfactor instead comes from the header's own field) ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 2;  iload = 0.;  iload_dt = -1.
 dm_load = 0.02;  mloadfactor = 0.07   ! as if both restored from header
 call init_massloading()
 call checkval(mloadfactor, 0.07, tol, nfailed(3), &
    'restart (mode2): mloadfactor left as restored, not back-derived from dm_load')

 ! --- default/off case (-1 or any value outside 0..2): parse_massloading
 !     marks initialised and returns without deriving anything ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = -1;  iload = 0.5;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(dm_load, 0., tol, nfailed(4), 'mode -1 (off): dm_load left at 0')

 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 7;  iload = 0.5;  iload_dt = -1.   ! out-of-range -> default branch
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call checkval(mloadfactor, 0., tol, nfailed(5), 'mode 7 (invalid): falls through to default/off branch')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_init_edgecases

!---------------------------------------------------------------------------
! test_update_torb
!   Covers update_t_orb's branches: Kepler-period derivation when a sink mass
!   is available, the dtmax fallback when it isn't (or when the resolved
!   interval is non-positive), and the fixed-iload_dt path when calc_torb is
!   .false.  Exercised indirectly through step_mass_loading, since
!   update_t_orb is module-private.
!---------------------------------------------------------------------------
subroutine test_update_torb(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas, nptmass, xyzmh_ptmass
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(4)
 real     :: t_expected
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> update_t_orb branch tests (via step_mass_loading)'
 nfailed(:) = 0

 ! --- calc_torb (iload_dt<=0) with a sink mass present -> Kepler period ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 nptmass = 1
 xyzmh_ptmass(:,:)  = 0.
 xyzmh_ptmass(4,1)  = 4.0
 r_orb = 1.0
 iload_factor = 0;  iload = 0.1;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_expected = 2. * acos(-1.) * r_orb**1.5 / sqrt(xyzmh_ptmass(4,1))
 call step_mass_loading(0.1, 0.1, 1.0, 1, 0_1)
 call checkval(t_orb, t_expected, tol, nfailed(1), 'calc_torb: Kepler period from sink mass')

 ! --- calc_torb with no sinks present -> falls back to dtmax ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 nptmass = 0
 iload_factor = 0;  iload = 0.1;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call step_mass_loading(0.1, 0.1, 3.0, 1, 0_1)
 call checkval(t_orb, 3.0, tol, nfailed(2), 'calc_torb: no sink mass -> t_orb = dtmax')

 ! --- not calc_torb (iload_dt>0): uses the fixed interval directly ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 nptmass = 0
 iload_factor = 0;  iload = 0.1;  iload_dt = 2.5
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 call step_mass_loading(0.1, 0.1, 1.0, 1, 0_1)
 call checkval(t_orb, 2.5, tol, nfailed(3), 'fixed interval: t_orb = iload_dt')

 ! --- not calc_torb but resolved interval is non-positive -> dtmax fallback.
 !     NOTE: parse_massloading ties calc_torb := (iload_dt<=0), so this state
 !     (calc_torb=.false. with iload_dt<=0) cannot arise from the public
 !     setup path; we reach it here only by mutating iload_dt *after* init
 !     has already latched calc_torb=.false., which update_t_orb defends
 !     against directly via its own `if (t_orb<=0) t_orb=dtmax` guard. ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 nptmass = 0
 iload_factor = 0;  iload = 0.1;  iload_dt = 2.5
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 iload_dt = 0.
 call step_mass_loading(0.1, 0.1, 4.0, 1, 0_1)
 call checkval(t_orb, 4.0, tol, nfailed(4), 'else-branch non-positive t_orb -> dtmax fallback')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_update_torb

!---------------------------------------------------------------------------
! test_apply_guards
!   Covers the early-return guards in apply_partmass_const/apply_partmass_exp
!   (both module-private; reached only via step_mass_loading).
!
!   NOTE: each guard is a compound `.or.` condition, e.g.
!     apply_partmass_const: dm_load==0 .or. n_p0<=0 .or. t_orb<=0 .or. dt<=0
!   but step_mass_loading's own call-site guard
!     (.not.dofrac_load .and. dm_load==0) .or. (dofrac_load .and. mloadfactor==0)
!   already filters out dm_load==0 / mloadfactor==0 before either routine is
!   reached, and n_p0<=0 can only coexist with an un-initialised module (which
!   is filtered the same way — see test_init_edgecases). Those three operands
!   are therefore unreachable dead defensive code from the public API; only
!   t_orb<=0 and dt<=0 are reachable, and (for gcov line coverage of the
!   guarded `if` line) exercising either is sufficient.
!---------------------------------------------------------------------------
subroutine test_apply_guards(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(4)
 real     :: m_before
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> apply_partmass_* guard tests (via step_mass_loading)'
 nfailed(:) = 0

 ! --- const (mode 0): dt <= 0 -> no-op ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 0;  iload = 0.1;  iload_dt = 2.0
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0., 2.0, 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(1), 'const: dt<=0 -> mass unchanged')

 ! --- const (mode 0): t_orb <= 0 -> no-op (dtmax=0, no sinks -> t_orb resolves to 0) ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 0;  iload = 0.1;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0.5, 0., 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(2), 'const: t_orb<=0 -> mass unchanged')

 ! --- exp (mode 2): dt <= 0 -> no-op ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 2;  iload = 0.05;  iload_dt = 2.0
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0., 2.0, 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(3), 'exp: dt<=0 -> mass unchanged')

 ! --- exp (mode 2): t_orb <= 0 -> no-op ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 2;  iload = 0.05;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0.5, 0., 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(4), 'exp: t_orb<=0 -> mass unchanged')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_apply_guards

!---------------------------------------------------------------------------
! test_step_guards
!   Covers step_mass_loading's own top-level early-return guard: loading off
!   (iload_factor<0), constant-mode with a zero rate (dm_load==0), and
!   exponential-mode with a zero rate (mloadfactor==0) — each must short
!   circuit before update_r_orb/update_t_orb/apply_* are ever invoked.
!---------------------------------------------------------------------------
subroutine test_step_guards(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(3)
 real     :: m_before
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> step_mass_loading guard tests'
 nfailed(:) = 0

 ! --- loading off: guard short-circuits regardless of stale dm_load/mloadfactor ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = -1
 dm_load = 1.e-6;  mloadfactor = 0.1
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0.5, 2.0, 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(1), 'off: guard short-circuits on mode alone')

 ! --- constant mode with a zero rate (iload=0 -> dm_load derives to 0) ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 0;  iload = 0.;  iload_dt = 2.0
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0.5, 2.0, 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(2), 'const: dm_load==0 -> guard short-circuits')

 ! --- exponential mode with a zero rate (iload=0 -> mloadfactor derives to 0) ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 2;  iload = 0.;  iload_dt = 2.0
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call step_mass_loading(0.5, 0.5, 2.0, 1, 0_1)
 call checkval(massoftype(igas), m_before, tol, nfailed(3), 'exp: mloadfactor==0 -> guard short-circuits')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_step_guards

!---------------------------------------------------------------------------
! test_log_massloading
!   Smoke-tests log_massloading's early-return (loading off/uninitialised)
!   and normal (active, prints summary) paths. The routine is pure logging —
!   it derives and writes a one-line summary but mutates no module or part
!   state — so the meaningful assertion is that calling it, in either branch,
!   leaves massoftype(igas) untouched.
!---------------------------------------------------------------------------
subroutine test_log_massloading(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(2)
 real     :: m_before
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> log_massloading smoke tests'
 nfailed(:) = 0

 ! --- early return: loading off ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = -1
 m_before = massoftype(igas)
 call log_massloading(0.5)
 call checkval(massoftype(igas), m_before, tol, nfailed(1), 'log (off): pure logging, no state mutation')

 ! --- normal path: loading active, writes M_disc/M_disc0 + dm_p summary ---
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 iload_factor = 0;  iload = 0.1;  iload_dt = 2.0
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 m_before = massoftype(igas)
 call log_massloading(0.5)
 call checkval(massoftype(igas), m_before, tol, nfailed(2), 'log (active): pure logging, no state mutation')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_log_massloading

!---------------------------------------------------------------------------
! test_options_io
!   Round-trips the .in and .setup option blocks through real infile_utils
!   databases: write with write_options_massloading[_setup], reload via
!   open_db_from_file, and verify read_options_massloading[_setup] restores
!   the written values — including R_ref pickup in the setup variant.
!
!   NOTE: the deprecated-`iload_dm` migration-error branches in both
!   read_options_* routines call io::fatal, which invokes `die` (process
!   termination) at severity 4 — exercising that path would abort the test
!   binary, so it is intentionally left untested (cf. the documented-bug
!   convention used throughout this coverage pass: dangerous dead ends are
!   noted, not exercised).
!---------------------------------------------------------------------------
subroutine test_options_io(ntests, npass)
 use infile_utils, only: inopts, open_db_from_file, close_db, write_inopt
 use io,           only: id, master
 use testutils,    only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 type(inopts), allocatable :: db(:)
 integer :: nfailed(7), ierr, nerr, lu
 character(len=*), parameter :: fname = 'test_massloading_opts.tmp'
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> options I/O round-trip tests'
 nfailed(:) = 0

 ! --- runtime (.in) options round-trip ---
 call reset_massloading()
 iload_factor = 1;  iload = 0.025;  iload_dt = 3.5
 open(newunit=lu, file=fname, status='replace', form='formatted')
 call write_options_massloading(lu)
 close(lu)

 iload_factor = -99;  iload = -99.;  iload_dt = -99.   ! clobber before reading back
 nerr = 0
 call open_db_from_file(db, fname, 78, ierr)
 call checkval(ierr, 0, 0, nfailed(1), 'options: db opened from written .in file')
 call read_options_massloading(db, nerr)
 call close_db(db)
 call checkval(iload_factor, 1,     0,   nfailed(2), 'options: iload_factor round-trips')
 call checkval(iload,        0.025, tol, nfailed(3), 'options: iload round-trips')
 call checkval(iload_dt,     3.5,   tol, nfailed(4), 'options: iload_dt round-trips')
 call checkval(nerr,         0,     0,   nfailed(5), 'options: no read errors reported')

 ! --- setup (.setup) options round-trip, including R_ref pickup ---
 call reset_massloading()
 iload_factor = 2;  iload = 0.08;  iload_dt = -1.;  r_orb = 1.0
 open(newunit=lu, file=fname, status='replace', form='formatted')
 call write_options_massloading_setup(lu)
 call write_inopt(50.0, 'R_ref', 'reference radius', lu)
 close(lu)

 iload_factor = -99;  r_orb = -99.
 nerr = 0
 call open_db_from_file(db, fname, 78, ierr)
 call read_options_massloading_setup(db, nerr)
 call close_db(db)
 call checkval(iload_factor, 2,    0,   nfailed(6), 'setup options: iload_factor round-trips')
 call checkval(r_orb,        50.0, tol, nfailed(7), 'setup options: r_orb picked up from R_ref entry')

 ! clean up temp file: open_db_from_file already closed unit 78, so
 ! reopen+delete to remove it from disk
 open(newunit=lu, file=fname, status='old', form='formatted')
 close(lu, status='delete')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_options_io

!---------------------------------------------------------------------------
! test_headeropts_io
!   Round-trips the dump-header restart fields (dm_load, r_orb, t_init —
!   m_p0 is module-private and not independently observable) through a real
!   dump_h, and verifies read_headeropts_massloading's early return when
!   loading is switched off (fields left untouched).
!---------------------------------------------------------------------------
subroutine test_headeropts_io(ntests, npass)
 use dump_utils, only: dump_h, allocate_header, free_header
 use io,         only: id, master
 use testutils,  only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 type(dump_h) :: hdr
 integer :: nfailed(6), ierr
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> dump-header I/O round-trip tests'
 nfailed(:) = 0

 ! --- write + read round-trip when loading is active ---
 call reset_massloading()
 iload_factor = 1
 dm_load = 4.2e-7;  r_orb = 12.5;  t_init = 3.3
 hdr  = allocate_header(nreal=10)
 ierr = 0
 call write_headeropts_massloading(hdr, ierr)
 call checkval(ierr, 0, 0, nfailed(1), 'header write: no error')

 dm_load = -1.;  r_orb = -1.;  t_init = -1.   ! clobber before reading back
 call read_headeropts_massloading(hdr)
 call checkval(dm_load, 4.2e-7, tol, nfailed(2), 'header round-trip: dm_load')
 call checkval(r_orb,   12.5,   tol, nfailed(3), 'header round-trip: r_orb')
 call checkval(t_init,  3.3,    tol, nfailed(4), 'header round-trip: t_init')

 ! --- read early-return when loading disabled: fields left untouched ---
 iload_factor = -1
 dm_load = -7.;  r_orb = -7.
 call read_headeropts_massloading(hdr)
 call checkval(dm_load, -7., tol, nfailed(5), 'header read: early return when off (dm_load untouched)')
 call checkval(r_orb,   -7., tol, nfailed(6), 'header read: early return when off (r_orb untouched)')

 call free_header(hdr)
 call update_test_scores(ntests, nfailed, npass)
end subroutine test_headeropts_io

!---------------------------------------------------------------------------
! test_set_r_ref
!   Covers set_massloading_r_ref's positive/non-positive branches.
!---------------------------------------------------------------------------
subroutine test_set_r_ref(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(2)
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> set_massloading_r_ref branch tests'
 nfailed(:) = 0

 call reset_massloading()
 r_orb = 5.0
 call set_massloading_r_ref(20.0)
 call checkval(r_orb, 20.0, tol, nfailed(1), 'set_r_ref: positive r updates r_orb')

 call set_massloading_r_ref(-3.0)
 call checkval(r_orb, 20.0, tol, nfailed(2), 'set_r_ref: non-positive r leaves r_orb unchanged')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_set_r_ref

!---------------------------------------------------------------------------
! test_first_substep_init
!   Regression for the first-interval t_orb gap.  On a fresh (or restarted)
!   run the first sub-steps occur with istepfrac < 2**nbinmax while t_orb is
!   still at its 0 default, because update_t_orb used to be invoked only at
!   sync points (istepfrac == 2**nbinmax).  apply_partmass_* then early-
!   returned on t_orb<=0 for the whole first dtmax interval, freezing
!   massoftype(igas) and emitting no [mass_loading] output.  The fix makes
!   step_mass_loading also derive t_orb on any call where it is still <=0, so
!   loading is active from the very first sub-step.
!
!   This case is exercised off-sync (istepfrac=1, nbinmax=4 -> 2**4=16): the
!   pre-fix gate would NOT enter the update block under individual timesteps,
!   leaving t_orb=0 and the mass unchanged.  Post-fix the mass advances to the
!   exact direct-evaluation value regardless of the build's ind_timesteps.
!---------------------------------------------------------------------------
subroutine test_first_substep_init(ntests, npass)
 use part,      only: massoftype, npartoftypetot, igas, nptmass, xyzmh_ptmass
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer  :: nfailed(2)
 real     :: mp_saved, m_expected, t_orb_expected
 real, parameter :: tol = 1.e-5

 if (id == master) write(*,"(a)") '  --> first sub-step t_orb-init regression'
 nfailed(:) = 0

 ! calc_torb (Kepler) path with a sink present so t_orb resolves to a finite
 ! positive value when derived: t_orb = 2*pi*r_orb^1.5 / sqrt(M_star).
 call reset_massloading()
 massoftype(igas)     = 1.e-4
 npartoftypetot(igas) = 1000
 nptmass = 1
 xyzmh_ptmass(:,:)  = 0.
 xyzmh_ptmass(4,1)  = 4.0
 r_orb = 1.0
 iload_factor = 0;  iload = 0.1;  iload_dt = -1.
 dm_load = 0.;  mloadfactor = 0.
 call init_massloading()
 t_init = 0.
 t_orb  = 0.   ! reset_massloading does not clear t_orb; force the fresh-start sentinel

 mp_saved       = massoftype(igas)
 t_orb_expected = 2. * acos(-1.) * r_orb**1.5 / sqrt(xyzmh_ptmass(4,1))
 m_expected     = mp_saved + dm_load * 0.5 / (t_orb_expected * real(npartoftypetot(igas)))

 ! off-sync first sub-step: time=0.5, dt=0.5, dtmax=10, istepfrac=1, nbinmax=4
 call step_mass_loading(0.5, 0.5, 10.0, 1, 4_1)

 call checkval(t_orb,            t_orb_expected, tol, nfailed(1), 'first sub-step: t_orb derived off-sync')
 call checkval(massoftype(igas), m_expected,     tol, nfailed(2), 'first sub-step: mass advances off-sync')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_first_substep_init

end module testmassloading
