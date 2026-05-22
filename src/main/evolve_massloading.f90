!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module mass_loading
   !
   ! Constant comoving mass loading of gas particles.
   !
   ! Each orbit the total disc mass increases by iload_dm [M], distributed
   ! equally among all gas particles.  Mass is added comoving — injected
   ! mass shares the receiving particle's velocity — so total momentum scales
   ! proportionally with the growing mass and no velocity correction is needed.
   !
   ! Loading amount — specify exactly one:
   !   iload    > 0 : χ (fraction of M_disc,0 per orbit).
   !                  init_massloading derives iload_dm = χ * M_disc,0 and
   !                  writes it to the .in file so restarts need no setup file.
   !   iload_dm > 0 : ξ (absolute mass per orbit [code units]).
   !                  Used directly; iload is not touched.
   !   iload    = -1: sentinel — "I will supply iload_dm directly in the .in file".
   !                  No derivation is attempted; loading is active if iload_dm > 0.
   !   iload_dm = -1: sentinel — "derive me from iload at init time".
   !
   ! Sentinel rules in init_massloading:
   !   iload_dm > 0 → use it directly; do not overwrite iload or iload_dm.
   !   iload    > 0 → compute iload_dm = iload * M_disc,0 and set iload_dm.
   !   iload    = -1 with iload_dm <= 0 → loading inactive.
   !
   ! Effective interval t_eff (iload_dt):
   !   iload_dt > 0 : fixed code-unit interval
   !   iload_dt < 0 : orbital period T_orb = 2pi * sqrt(R_ref^3 / (G * M_star))
   !                  with G=1, M_star from the first sink, R from r_ref_load.
   !
   ! Step frequency:
   !   Controlled by the compile-time IND_TIMESTEPS flag (dim::ind_timesteps).
   !   The rate t_eff is recalculated once per dtmax at the global sync point.
   !   apply_mass_loading is called every fine step with the individual dt.
   !
   ! High-level call site in evolve.f90 evol_prestep:
   !   if (iload > 0. .or. iload_dm > 0.) &
   !      call step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)
   !
   ! Setup integration (call order in setup_disc or equivalent):
   !   1. call read_options_massloading_setup(db, nerr)  ! sets r_ref_load, disc_m_setup
   !   2. ... build particles ...
   !   3. call init_massloading()  ! derives and sets iload_dm when iload > 0;
   !                               ! write_options_massloading then writes both
   !
   ! On restart phantom reads .in; iload_dm > 0 so init_massloading uses it
   ! directly — no dependency on disc_m or the .setup file.
   !
   ! r_ref_load is written to the .in file when iload_dt < 0 so phantom restarts
   ! without the .setup file. Set by setup via set_massloading_r_ref or
   ! read_options_massloading_setup.
   !
   ! :Owner: will-roscoe
   !
   ! :Runtime parameters:
   !   iload    -- chi: fraction of initial disc mass per orbit; -1 = use iload_dm
   !   iload_dm -- xi: absolute mass per orbit [code units]; -1 = derive from iload
   !   iload_dt -- interval [code units]; <0 = orbital period
   !
   ! :Dependencies: dim, infile_utils, io, mpiutils, part
   !
   use part, only: igas
   implicit none
   public :: init_massloading, step_mass_loading, &
             write_options_massloading, read_options_massloading, &
             write_options_massloading_setup, read_options_massloading_setup, &
             write_headeropts_massloading, read_headeropts_massloading, &
             set_massloading_r_ref

   real, public :: iload      =  0.0    ! chi: >0 = fraction/orbit, -1 = use iload_dm, 0 = off
   real, public :: iload_dm   = -1.0    ! xi:  >0 = absolute mass/orbit, -1 = derive from iload
   real, public :: iload_dt   = -1.0    ! interval [code units]; <0 = orbital period
   real, public :: r_ref_load =  1.0    ! reference radius for T_orb (iload_dt<0 only)

   ! set once at initialisation
   real,            private :: dm_pi      = 0.  ! per-particle loading rate [M / t_eff unit]
   real,            private :: dm_disci   = 0.  ! total disc loading rate   [M / t_eff unit]
   integer(kind=8), private :: n0_load    = 0   ! gas particle count at initialisation
   real,            private :: disc_m_setup = 0. ! M_disc,0 from read_options_massloading_setup

   ! updated each dtmax by calc_massloading_rate
   real, private :: t_eff_current = 1.

   ! cumulative product of all (m_new/m_old) steps; persisted in dump header
   real, public :: load_mass_factor = 1.0

   private

contains

   !----------------------------------------------------------------------
   !+
   !  Initialise dm_pi and, when in fractional mode (iload > 0), derive
   !  and set iload_dm from iload * M_disc,0.
   !
   !  Sentinel rules:
   !    iload_dm > 0 : absolute mode — use directly, leave iload untouched.
   !    iload    > 0 : fractional mode — compute iload_dm and set it.
   !    iload    = -1 with iload_dm <= 0 : loading inactive; return silently.
   !
   !  During phantomsetup: call explicitly after read_options_massloading_setup
   !  and particle creation so that write_options_massloading writes the derived
   !  iload_dm to the .in file alongside iload.
   !
   !  During phantom: called lazily on the first step_mass_loading call.
   !  On restarts iload_dm is already > 0 from the .in file so the fractional
   !  branch is never taken and M_disc,0 is not needed.
   !
   !  M_disc,0 is taken from disc_m_setup if set by read_options_massloading_setup;
   !  otherwise computed as massoftype(igas) * npartoftypetot(igas).
   !+
   !----------------------------------------------------------------------
   subroutine init_massloading()
      use part, only: massoftype, npartoftypetot
      use io,   only: iprint, id, master, error
      real :: m_disc0

      n0_load = npartoftypetot(igas)
      if (n0_load <= 0) return

      ! always need M_disc,0 for derive/display; compute once
      if (disc_m_setup > 0.) then
         m_disc0 = disc_m_setup
      else
         m_disc0 = massoftype(igas) * real(n0_load)
      endif

      if (iload_dm > 0.) then
         ! absolute mode: iload_dm specified in .in; use directly
         dm_pi    = iload_dm / real(n0_load)
         dm_disci = iload_dm
         ! back-derive iload for display (only when iload is >= 0, i.e. not the -1 sentinel)
         if (iload >= 0. .and. m_disc0 > 0.) iload = iload_dm / m_disc0

      elseif (iload > 0.) then
         ! fractional mode: derive and set iload_dm from chi * M_disc,0
         iload_dm = iload * m_disc0
         dm_disci = iload_dm
         dm_pi    = iload_dm / real(n0_load)

      elseif (iload == 0.) then
         ! loading explicitly off: ensure iload_dm = 0 for clean .in output
         iload_dm = 0.
         return

      else
         ! iload = -1 sentinel with no iload_dm yet: user will specify iload_dm in .in file
         ! write a clean zero placeholder so phantomsetup produces an editable .in entry
         iload_dm = 0.
         return
      endif

      if (id == master) &
         write(iprint,"(1x,a,es12.4,a,i0,a,es12.4,a,es12.4)") &
            '[mass_loading] init: iload_dm=', iload_dm, &
            '  n0=', n0_load, '  dm_pi=', dm_pi, &
            '  iload=', iload
   end subroutine init_massloading

   !----------------------------------------------------------------------
   !+
   !  Update t_eff_current (the effective loading interval).
   !  Called once per dtmax at the global sync point.
   !+
   !----------------------------------------------------------------------
   subroutine calc_massloading_rate(t, dtmax)
      use part,     only: nptmass, xyzmh_ptmass
      use mpiutils, only: bcast_mpi
      use io,       only: iprint, id, master, iverbose
      real, intent(in) :: t, dtmax
      real :: M_primary

      if (iload_dt < 0.) then
         ! orbital period: T = 2*pi * r_ref^(3/2) / sqrt(G*M_star); G=1
         M_primary = 0.
         if (id == master .and. nptmass > 0) M_primary = xyzmh_ptmass(4,1)
         call bcast_mpi(M_primary)
         if (M_primary > 0.) then
            t_eff_current = 2.*acos(-1.) * r_ref_load**1.5 / sqrt(M_primary)
         else
            t_eff_current = dtmax   ! fallback: no sink present
         endif
      else
         t_eff_current = iload_dt
      endif

      if (t_eff_current <= 0.) t_eff_current = dtmax

      if (id == master .and. iverbose >= 1) &
         write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4)") &
            '[mass_loading] t=', t, '  t_eff=', t_eff_current, &
            '  mdot_p=', dm_pi / t_eff_current
   end subroutine calc_massloading_rate

   !----------------------------------------------------------------------
   !+
   !  Apply one mass-loading step: massoftype(igas) += dm_pi * dtsph / t_eff.
   !  Mass is added comoving; no velocity correction is applied.
   !+
   !----------------------------------------------------------------------
   subroutine apply_mass_loading(dtsph, time)
      use part, only: massoftype
      use io,   only: iprint, id, master, iverbose
      real, intent(in) :: dtsph, time
      real :: m_old, dm_p

      if (dm_pi <= 0. .or. dtsph <= 0.) return

      m_old            = massoftype(igas)
      dm_p             = dm_pi * dtsph / t_eff_current
      massoftype(igas) = m_old + dm_p

      load_mass_factor = load_mass_factor * massoftype(igas) / m_old

      if (id == master .and. iverbose >= 2) &
         write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4,a,es12.4)") &
            '[mass_loading] t=', time, '  dm/m=', dm_p/m_old, &
            '  m_gas=', massoftype(igas), &
            '  cumulative factor=', load_mass_factor
   end subroutine apply_mass_loading

   !----------------------------------------------------------------------
   !+
   !  High-level entry point called from evol_prestep once per fine step.
   !  Recalculates t_eff at the global sync point (controlled by the
   !  compile-time IND_TIMESTEPS flag via dim::ind_timesteps); applies
   !  loading every fine step with the individual dt.
   !+
   !----------------------------------------------------------------------
   subroutine step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)
      use dim, only: ind_timesteps
      real,            intent(in) :: time, dt, dtmax
      integer,         intent(in) :: istepfrac
      integer(kind=1), intent(in) :: nbinmax

      if (n0_load == 0) call init_massloading()
      if (dm_pi <= 0. .or. iload_dt == 0.) return

      ! recalculate t_eff once per dtmax at the global sync point
      if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) &
         call calc_massloading_rate(time, dtmax)

      call apply_mass_loading(dt, time)

   end subroutine step_mass_loading

   !----------------------------------------------------------------------
   !+
   !  Read R_ref and disc_m from an already-open setup file database.
   !  Call from the setup module after it opens its .setup DB:
   !    call read_options_massloading_setup(db, nerr)
   !  Sets r_ref_load and disc_m_setup if the keys are present.
   !  If iload = -1 in the setup DB, no derivation is attempted here.
   !+
   !----------------------------------------------------------------------
   !----------------------------------------------------------------------
   !+
   !  Write mass loading options that belong in the .setup file.
   !  Call from setup_disc (or equivalent) when writing the setup file.
   !  Only iload and iload_dt go here; iload_dm is a .in-only derived value.
   !+
   !----------------------------------------------------------------------
   subroutine write_options_massloading_setup(iunit)
      use infile_utils, only: write_inopt
      integer, intent(in) :: iunit

      write(iunit,"(/,a)") '# options for mass loading'
      call write_inopt(iload,   'iload',   &
         'chi: fraction of initial disc mass per orbit (>0); -1 = specify iload_dm in .in; 0 = off', iunit)
      call write_inopt(iload_dt, 'iload_dt', &
         'loading interval [code units]; <0 = orbital period; 0 = off', iunit)
   end subroutine write_options_massloading_setup

   !----------------------------------------------------------------------
   !+
   !  Read mass loading options from an already-open setup file database.
   !  Reads iload and iload_dt (user-facing setup parameters) plus r_ref_load
   !  and disc_m_setup (derived from disc geometry, used to compute iload_dm).
   !+
   !----------------------------------------------------------------------
   subroutine read_options_massloading_setup(db, nerr)
      use infile_utils, only: inopts, read_inopt
      type(inopts), intent(inout) :: db(:)
      integer,      intent(inout) :: nerr
      real    :: r_ref_tmp, disc_m_tmp
      integer :: ierr

      ! user-facing loading parameters from setup
      call read_inopt(iload,    'iload',    db, errcount=nerr, min=-1.)
      call read_inopt(iload_dt, 'iload_dt', db, errcount=nerr)

      ! disc geometry — used to derive iload_dm when iload > 0
      ierr = 0
      call read_inopt(r_ref_tmp, 'R_ref', db, err=ierr, min=0.)
      if (ierr == 0 .and. r_ref_tmp > 0.) r_ref_load = r_ref_tmp

      ierr = 0
      call read_inopt(disc_m_tmp, 'disc_m', db, err=ierr, min=0.)
      if (ierr == 0 .and. disc_m_tmp > 0.) disc_m_setup = disc_m_tmp
   end subroutine read_options_massloading_setup

   !----------------------------------------------------------------------
   subroutine write_options_massloading(iunit)
      use infile_utils, only: write_inopt
      integer, intent(in) :: iunit

      write(iunit,"(/,a)") '# options for mass loading'
      call write_inopt(iload,    'iload',    &
         'chi: fraction of initial disc mass per orbit (>0); -1 = specify iload_dm directly', iunit)
      call write_inopt(iload_dm, 'iload_dm', &
         'xi: absolute mass per orbit [code units] (>0); -1 = derive from iload', iunit)
      call write_inopt(iload_dt, 'iload_dt', &
         'loading interval [code units]; <0 = orbital period at r_ref_load', iunit)
      ! persist r_ref_load to .in so phantom restarts without the .setup file
      if (iload_dt < 0.) &
         call write_inopt(r_ref_load, 'r_ref_load', &
            'reference radius for orbital period [code units] (set by setup)', iunit)
   end subroutine write_options_massloading

   !----------------------------------------------------------------------
   subroutine read_options_massloading(db, nerr)
      use infile_utils, only: inopts, read_inopt
      type(inopts), intent(inout) :: db(:)
      integer,      intent(inout) :: nerr
      integer :: ierr

      ! min=-1. allows the sentinel value -1 for both parameters
      call read_inopt(iload,    'iload',    db, errcount=nerr, min=-1.)
      call read_inopt(iload_dm, 'iload_dm', db, errcount=nerr, min=-1.)
      call read_inopt(iload_dt, 'iload_dt', db, errcount=nerr)
      ierr = 0
      call read_inopt(r_ref_load, 'r_ref_load', db, err=ierr, min=0.)
   end subroutine read_options_massloading

   !----------------------------------------------------------------------
   !+
   !  Set the reference radius for orbital-period loading (iload_dt < 0).
   !  Call from setup modules after r_ref is known.
   !+
   !----------------------------------------------------------------------
   subroutine set_massloading_r_ref(r)
      real, intent(in) :: r
      if (r > 0.) r_ref_load = r
   end subroutine set_massloading_r_ref

   !----------------------------------------------------------------------
   !+
   !  Write mass loading parameters to a dump file header.
   !  Persists the effective (computed) values of iload, iload_dm, iload_dt,
   !  r_ref_load, and load_mass_factor so restarts recover the full state.
   !  Call from fill_header in readwrite_dumps_common.f90.
   !+
   !----------------------------------------------------------------------
   subroutine write_headeropts_massloading(hdr, ierr)
      use dump_utils, only: dump_h, add_to_rheader
      type(dump_h), intent(inout) :: hdr
      integer,      intent(inout) :: ierr

      call add_to_rheader(iload,           'iload',           hdr, ierr)
      call add_to_rheader(iload_dm,        'iload_dm',        hdr, ierr)
      call add_to_rheader(iload_dt,        'iload_dt',        hdr, ierr)
      call add_to_rheader(r_ref_load,      'r_ref_load',      hdr, ierr)
      call add_to_rheader(load_mass_factor,'load_mass_factor', hdr, ierr)
   end subroutine write_headeropts_massloading

   !----------------------------------------------------------------------
   !+
   !  Read mass loading parameters from a dump file header.
   !  Restores iload, iload_dm, iload_dt, r_ref_load, and load_mass_factor.
   !  Missing keys are silently ignored (fallback to module defaults).
   !  Call from unfill_header in readwrite_dumps_common.f90.
   !+
   !----------------------------------------------------------------------
   subroutine read_headeropts_massloading(hdr)
      use dump_utils, only: dump_h, extract
      type(dump_h), intent(in) :: hdr
      integer :: ierr

      ierr = 0; call extract('iload',            iload,            hdr, ierr)
      ierr = 0; call extract('iload_dm',         iload_dm,         hdr, ierr)
      ierr = 0; call extract('iload_dt',         iload_dt,         hdr, ierr)
      ierr = 0; call extract('r_ref_load',       r_ref_load,       hdr, ierr)
      ierr = 0; call extract('load_mass_factor', load_mass_factor, hdr, ierr)
   end subroutine read_headeropts_massloading

end module mass_loading
