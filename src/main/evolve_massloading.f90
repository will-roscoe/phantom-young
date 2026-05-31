!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module mass_loading
!
! Provides mass loading (comoving) of gas particles.
!
! Configuration allows for:
!   - constant or exponential mass loading behaviour.
!   - loading interval to be defined by r_orb or a chosen fixed value.
!   - compatible with IND_TIMESTEPS = yes & no.
!
! Configuration:
!
!   - iload_factor:
!       * -1 : off (no loading)
!       *  0 : constant (A) behaviour, iload used as chi.
!              chi  --> constant rate given as fraction of initial disc mass per T.
!       *  1 : constant (A) behaviour, iload used as xi.
!              xi   --> constant rate given as absolute mass per interval T.
!       *  2 : fractional (B) behaviour, iload used as beta.
!              beta --> mass scales by a factor of 1+beta every interval T.
!   - iload: see above
!   - iload_dt:
!       *  <=0 : interval T found by computing orbital period at r_orb.
!       *  >0  : iload_dt is the fixed interval length.
!
!
! Mathematical Description:
!   In the constant (A) formulation given by Mercer & Stamatellos 2020:
!
!       Mdot = xi / T
!           xi    = chi * M_disc0
!           T     = t_orb(R) = 2*pi * R^(3/2) / (G*M_star)^(1/2)   [G=1]
!
!   Considering the disc to comprise of n_p particles (initially n_p0):
!
!       M_disc(t) = M_disc0 + Mdot * t
!       m_p(t)    = m_p0 + xi * t / (T * n_p0)
!
!   Each timestep dt the per-particle mass is incremented by:
!
!       dm_p = dm_load * dt / (t_orb * n_p0)
!
!   In the exponential (B) formulation:
!
!       M(t)   = M_disc0 * exp( ln(1+beta) * t/T )
!       m_p(t) = m_p0   * exp( ln(1+beta) * t/T )
!       M(t+T)/M(t) = 1+beta
!
!   Each timestep dt the per-particle mass is scaled by:
!
!       m_p -> m_p * exp( ln(1+beta) * dt / t_orb )
!
!
! For modes 0 and 1, both dm_load (xi) and mloadfactor (chi) are always set:
!   mode 0: mloadfactor = iload (user chi),  dm_load = iload * M_disc0
!   mode 1: dm_load     = iload (user xi),   mloadfactor = iload / M_disc0
!   mode 2: mloadfactor = iload (user beta), dm_load = 0.
!
! .in parameters (3 only): iload_factor, iload, iload_dt
! Dump header:              dm_load, r_orb, m_p0, t_init (restart safety)
! Runtime-derived:          n_p0, m_p0 from part; t_orb from r_orb + M_star
!
! Compile-time isolation: wrap `use mass_loading` and call site in evolve.f90
! with #ifdef MASS_LOADING / #endif.
!
! :Owner: will-roscoe
!
! :Runtime parameters:
!   iload_factor -- loading mode (-1=off, 0=chi, 1=xi, 2=beta)
!   iload        -- factor value (chi / xi / beta)
!   iload_dt     -- interval [code units]; <=0 = orbital period at r_orb
!
! :Dependencies: dim, dump_utils, infile_utils, io, mpiutils, part
!
 use part, only: igas
 implicit none

 public :: init_massloading, step_mass_loading,                   &
           log_massloading,                                       &
           write_options_massloading, read_options_massloading,   &
           write_options_massloading_setup,                       &
           read_options_massloading_setup,                        &
           write_headeropts_massloading,                          &
           read_headeropts_massloading,                           &
           set_massloading_r_ref,                                 &
           reset_massloading

 ! .in parameters
 integer, public :: iload_factor =  -1   ! -1=off, 0=chi, 1=xi, 2=beta
 real,    public :: iload        =   0.  ! chi / xi / beta
 real,    public :: iload_dt     =  -1.  ! interval; <=0 -> compute T_orb

 ! derived quantities (always set for modes 0 and 1)
 real, public :: mloadfactor  = 0.
    ! chi (modes 0/1) or beta (mode 2)
 real, public :: dm_load      = 0.
    ! xi (modes 0/1); 0 for mode 2
 real, public :: r_orb        = 1.
    ! reference radius used to compute T_orb
 real, public :: t_orb        = 0.
    ! current effective loading interval (updated at each sync point)
 real, public :: t_init       = -1.
    ! simulation time of first loading step; -1 = not yet set (fresh start sentinel)
    ! persisted in dump header; also settable from tests or setup code

 ! private state — set once at init, never in .in
 integer(kind=8), private :: n_p0        = 0
    ! initial gas particle count
 real,            private :: m_p0        = 0.
    ! initial per-particle mass (M_disc0 / n_p0)
 integer,         private :: id_mstar    = 1
    ! sink index for host star (defaults to first sink)
 logical,         private :: dofrac_load = .false.
    ! .true. for beta/exponential mode (iload_factor=2)
 logical,         private :: calc_torb   = .false.
    ! .true. when iload_dt<=0: compute T_orb from r_orb and M_star each sync point
 logical,         private :: initialised = .false.

 private

contains

!-----------------------------------------------------------------------
! init_massloading
!   Reads initial particle state from the part module, then delegates
!   to parse_massloading to set dm_load / mloadfactor / flags.
!   Called lazily on first step_mass_loading call, or explicitly from
!   phantomsetup.
!-----------------------------------------------------------------------
subroutine init_massloading()
 use part, only: massoftype, npartoftypetot
 use io,   only: iprint, id, master
 real :: m_disc0

 n_p0 = npartoftypetot(igas)
 if (n_p0 <= 0) return
 if (m_p0 == 0.) m_p0 = massoftype(igas)   ! fresh start; on restart m_p0 is read from dump header
 m_disc0 = m_p0 * real(n_p0)

 ! restart path: dm_load already set from dump header — back-derive mloadfactor
 if (dm_load /= 0.) then
    if (iload_factor == 0 .or. iload_factor == 1) then
       ! back-derive chi for display only; m_disc0 here is evolved not initial
       if (m_disc0 > 0.) mloadfactor = dm_load / m_disc0
    endif
    dofrac_load = (iload_factor == 2)
    calc_torb   = (iload_dt <= 0.)
    initialised = .true.
    if (id == master) &
       write(iprint,"(1x,a,i0,a,es12.4,a,es12.4)") &
          '[mass_loading] restart: type=', iload_factor, &
          '  dm_load=', dm_load, '  r_orb=', r_orb
    return
 endif

 call parse_massloading(m_disc0)
end subroutine init_massloading

!-----------------------------------------------------------------------
! parse_massloading
!   Derives dm_load, mloadfactor, dofrac_load, and calc_torb from the
!   module-level .in parameters.  Called only on a fresh (non-restart) run.
!-----------------------------------------------------------------------
subroutine parse_massloading(m_disc0)
 use io, only: iprint, id, master
 real, intent(in) :: m_disc0

 select case(iload_factor)
 case(0)   ! chi mode: user gives chi, derive xi
    mloadfactor = iload
    dm_load     = iload * m_disc0
    dofrac_load = .false.
 case(1)   ! xi mode: user gives xi, back-derive chi
    dm_load     = iload
    if (m_disc0 > 0.) mloadfactor = iload / m_disc0
    dofrac_load = .false.
 case(2)   ! beta mode: no xi equivalent
    mloadfactor = iload
    dm_load     = 0.
    dofrac_load = .true.
 case default  ! -1 or any invalid value: loading off
    initialised = .true.   ! prevents lazy-init on every step when loading is off
    return
 end select

 calc_torb   = (iload_dt <= 0.)
 initialised = .true.

 if (id == master) &
    write(iprint,"(1x,a,i0,a,es12.4,a,es12.4,a,es12.4,a,i0)") &
       '[mass_loading] init: type=', iload_factor, &
       '  iload=',       iload,       &
       '  mloadfactor=', mloadfactor, &
       '  dm_load=',     dm_load,     &
       '  n_p0=',        n_p0
end subroutine parse_massloading

!-----------------------------------------------------------------------
! update_r_orb
!   Currently a no-op: r_orb is set from setup via set_massloading_r_ref
!   or restored from the dump header on restart.
!   Extension point: could evolve to recompute r_orb from particle
!   distributions (e.g. disc centre-of-mass radius) in future.
!-----------------------------------------------------------------------
subroutine update_r_orb()
end subroutine update_r_orb

!-----------------------------------------------------------------------
! update_t_orb
!   Recomputes the loading interval at each sync point.
!   If calc_torb: derives T_orb = 2*pi * r_orb^1.5 / sqrt(M_star) [G=1].
!   Otherwise: uses the fixed iload_dt.
!-----------------------------------------------------------------------
subroutine update_t_orb(t, dtmax)
 use part,     only: nptmass, xyzmh_ptmass
 use mpiutils, only: bcast_mpi
 use io,       only: iprint, id, master, iverbose
 real, intent(in) :: t, dtmax
 real :: M_primary

 if (calc_torb) then
    M_primary = 0.
    if (id == master .and. nptmass > 0) M_primary = xyzmh_ptmass(4, id_mstar)
    call bcast_mpi(M_primary)
    if (M_primary > 0.) then
       t_orb = 2. * acos(-1.) * r_orb**1.5 / sqrt(M_primary)
    else
       t_orb = dtmax
    endif
 else
    t_orb = iload_dt
 endif

 if (t_orb <= 0.) t_orb = dtmax

 if (id == master .and. iverbose >= 1) &
    write(iprint,"(1x,a,es12.4,a,es12.4)") &
       '[mass_loading] t=', t, '  t_orb=', t_orb
end subroutine update_t_orb

!-----------------------------------------------------------------------
! apply_partmass_const
!   Constant loading (modes 0 and 1):
!       m_p(t) = m_p0 + dm_load * (t - t_init) / (T * n_p0)
!   Computed directly from m_p0 and elapsed time to avoid accumulating
!   floating-point error over many binsteps.  t_init is set on first call.
!   For varying T uses the current t_orb for the full elapsed time (a
!   reasonable approximation when T changes slowly).
!-----------------------------------------------------------------------
subroutine apply_partmass_const(dt, time)
 use part, only: massoftype
 use io,   only: iprint, id, master, iverbose
 real, intent(in) :: dt, time
 real :: m_old

 if (dm_load == 0. .or. n_p0 <= 0 .or. t_orb <= 0. .or. dt <= 0.) return
 if (t_init < 0.) t_init = time
 m_old            = massoftype(igas)
 massoftype(igas) = m_p0 + dm_load * (time - t_init) / (t_orb * real(n_p0))

 if (id == master .and. iverbose >= 2) &
    write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4)") &
       '[mass_loading] t=', time, &
       '  dm/m=', (massoftype(igas) - m_old) / m_old, &
       '  m_gas=', massoftype(igas)
end subroutine apply_partmass_const

!-----------------------------------------------------------------------
! apply_partmass_exp
!   Exponential/beta loading (mode 2):
!       m_p(t) = m_p0 * exp( ln(1+beta) * (t - t_init) / T )
!   Computed directly from m_p0 and elapsed time to avoid accumulating
!   floating-point error over many binsteps.  t_init is set on first call.
!   For varying T uses the current t_orb for the full elapsed time (a
!   reasonable approximation when T changes slowly).
!-----------------------------------------------------------------------
subroutine apply_partmass_exp(dt, time)
 use part, only: massoftype
 use io,   only: iprint, id, master, iverbose
 real, intent(in) :: dt, time
 real :: m_old

 if (mloadfactor == 0. .or. t_orb <= 0. .or. dt <= 0.) return
 if (t_init < 0.) t_init = time
 m_old            = massoftype(igas)
 massoftype(igas) = m_p0 * exp(log(1. + mloadfactor) * (time - t_init) / t_orb)

 if (id == master .and. iverbose >= 2) &
    write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4)") &
       '[mass_loading] t=', time, &
       '  dm/m=', (massoftype(igas) - m_old) / m_old, &
       '  m_gas=', massoftype(igas)
end subroutine apply_partmass_exp

!-----------------------------------------------------------------------
! step_mass_loading
!   Public entry point called from evol_prestep each substep.
!   Lazy-initialises on first call, then at each sync point refreshes
!   r_orb and t_orb before applying the per-particle mass increment.
!-----------------------------------------------------------------------
subroutine step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)
 use dim, only: ind_timesteps
 real,            intent(in) :: time, dt, dtmax
 integer,         intent(in) :: istepfrac
 integer(kind=1), intent(in) :: nbinmax

 if (.not. initialised) call init_massloading()
 if (iload_factor < 0) return
 if (.not. dofrac_load .and. dm_load    == 0.) return
 if (dofrac_load       .and. mloadfactor == 0.) return

 if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) then
    call update_r_orb()
    call update_t_orb(time, dtmax)
 endif

 if (dofrac_load) then
    call apply_partmass_exp(dt, time)
 else
    call apply_partmass_const(dt, time)
 endif
end subroutine step_mass_loading

!-----------------------------------------------------------------------
! log_massloading
!   Print a one-line summary of disc mass evolution at each dump point.
!   M_disc_now = massoftype(igas) * npartoftypetot(igas)
!   M_disc_0   = m_p0 * n_p0
!   No-op when iload_factor < 0 (mass loading off) or not yet initialised.
!-----------------------------------------------------------------------
subroutine log_massloading(time)
 use part, only: massoftype, npartoftypetot
 use io,   only: iprint, id, master
 real, intent(in) :: time
 real             :: m_disc_now, m_disc_0, dm_p, ratio

 if (iload_factor < 0 .or. n_p0 <= 0 .or. m_p0 <= 0.) return

 m_disc_now = massoftype(igas) * real(npartoftypetot(igas))
 m_disc_0   = m_p0 * real(n_p0)
 ratio      = m_disc_now / m_disc_0
 dm_p       = massoftype(igas) - m_p0

 if (id == master) write(iprint, &
    "('[mass_loading] dump: t=',es10.3,'  M_disc/M_disc0=',es10.3,'  dm_p=',es10.3)") &
    time, ratio, dm_p

end subroutine log_massloading

!-----------------------------------------------------------------------
! I/O routines
!-----------------------------------------------------------------------

subroutine write_options_massloading(iunit)
 use infile_utils, only: write_inopt
 integer, intent(in) :: iunit

 write(iunit,"(/,a)") '# options for mass loading'
 call write_inopt(iload_factor, 'iload_factor', &
    'loading mode: -1=off, 0=chi (fraction/orbit), 1=xi (absolute/orbit), 2=beta (exponential)', iunit)
 call write_inopt(iload,   'iload',   &
    'loading factor: chi (mode 0), xi [code units] (mode 1), or beta (mode 2)', iunit)
 call write_inopt(iload_dt,'iload_dt', &
    'loading interval [code units]; <=0 = orbital period at r_orb', iunit)
end subroutine write_options_massloading

subroutine read_options_massloading(db, nerr)
 use infile_utils, only: inopts, read_inopt
 use io,           only: iprint, id, master, fatal
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr
 integer :: ierr_v1
 real    :: dummy_v1

 ! >>> COMPAT_CHECK_V1: remove when all configs migrated to v2 params <<<
 ierr_v1 = 0
 call read_inopt(dummy_v1, 'iload_dm', db, err=ierr_v1)
 if (ierr_v1 == 0) then
    if (id == master) then
       write(iprint,"(a)") '[mass_loading] FATAL: deprecated param "iload_dm" found.'
       write(iprint,"(a)") '  Migrate: set  iload_factor = 1'
       write(iprint,"(a)") '                iload        = <xi value from iload_dm>'
       write(iprint,"(a)") '                iload_dt     = <interval>'
       write(iprint,"(a)") '  Remove:  iload_dm  and old bare  iload  from .in file.'
    endif
    call fatal('mass_loading','deprecated v1 parameter "iload_dm" in .in file; see migration message above')
 endif
 ! >>> END COMPAT_CHECK_V1 <<<

 call read_inopt(iload_factor, 'iload_factor', db, errcount=nerr, min=-1)
 call read_inopt(iload,        'iload',        db, errcount=nerr)
 call read_inopt(iload_dt,     'iload_dt',     db, errcount=nerr)
end subroutine read_options_massloading

subroutine write_options_massloading_setup(iunit)
 use infile_utils, only: write_inopt
 integer, intent(in) :: iunit

 write(iunit,"(/,a)") '# options for mass loading'
 call write_inopt(iload_factor,'iload_factor', &
    'loading mode: -1=off, 0=chi, 1=xi, 2=beta (exponential)', iunit)
 call write_inopt(iload,   'iload',   'loading factor: chi / xi / beta', iunit)
 call write_inopt(iload_dt,'iload_dt', &
    'loading interval [code units]; <=0 = orbital period', iunit)
end subroutine write_options_massloading_setup

subroutine read_options_massloading_setup(db, nerr)
 use infile_utils, only: inopts, read_inopt
 use io,           only: iprint, id, master, fatal
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr
 real    :: r_ref_tmp, dummy_v1
 integer :: ierr, ierr_v1

 ! >>> COMPAT_CHECK_V1: remove when all configs migrated to v2 params <<<
 ierr_v1 = 0
 call read_inopt(dummy_v1, 'iload_dm', db, err=ierr_v1)
 if (ierr_v1 == 0) then
    if (id == master) then
       write(iprint,"(a)") '[mass_loading] FATAL: deprecated param "iload_dm" found in .setup file.'
       write(iprint,"(a)") '  Migrate: set  iload_factor = 1,  iload = <xi value>,  iload_dt = <interval>'
    endif
    call fatal('mass_loading','deprecated v1 parameter "iload_dm" in .setup file')
 endif
 ! >>> END COMPAT_CHECK_V1 <<<

 call read_inopt(iload_factor, 'iload_factor', db, errcount=nerr, min=-1)
 call read_inopt(iload,        'iload',        db, errcount=nerr)
 call read_inopt(iload_dt,     'iload_dt',     db, errcount=nerr)

 ! pick up R_ref from setup db so orbital-period loading works without .in edit
 ierr = 0
 call read_inopt(r_ref_tmp, 'R_ref', db, err=ierr, min=0.)
 if (ierr == 0 .and. r_ref_tmp > 0.) r_orb = r_ref_tmp
end subroutine read_options_massloading_setup

subroutine write_headeropts_massloading(hdr, ierr)
 use dump_utils, only: dump_h, add_to_rheader
 type(dump_h), intent(inout) :: hdr
 integer,      intent(inout) :: ierr

 call add_to_rheader(dm_load, 'dm_load',      hdr, ierr)
 call add_to_rheader(r_orb,   'r_orb',        hdr, ierr)
 call add_to_rheader(m_p0,    'mload_mp0',    hdr, ierr)
 call add_to_rheader(t_init,  'mload_tinit',  hdr, ierr)
end subroutine write_headeropts_massloading

subroutine read_headeropts_massloading(hdr)
 use dump_utils, only: dump_h, extract
 type(dump_h), intent(in) :: hdr
 integer :: ierr

 ierr = 0;  call extract('dm_load',     dm_load, hdr, ierr)
 ierr = 0;  call extract('r_orb',       r_orb,   hdr, ierr)
 ierr = 0;  call extract('mload_mp0',   m_p0,    hdr, ierr)
 ierr = 0;  call extract('mload_tinit', t_init,  hdr, ierr)
end subroutine read_headeropts_massloading

subroutine set_massloading_r_ref(r)
 real, intent(in) :: r
 if (r > 0.) r_orb = r
end subroutine set_massloading_r_ref

!-----------------------------------------------------------------------
! reset_massloading
!   Resets all private state to module defaults.  Intended for unit
!   tests so that each test case starts from a known clean state.
!-----------------------------------------------------------------------
subroutine reset_massloading()
 n_p0        = 0
 m_p0        = 0.
 dofrac_load = .false.
 calc_torb   = .false.
 initialised = .false.
 t_init      = -1.
end subroutine reset_massloading

end module mass_loading
