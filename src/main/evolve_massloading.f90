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
   !   iload_total (modes 0 and 1 only) chooses what is held fixed when gas is
   !   accreted or killed:
   !       0 (default): the rate per particle. m_p(t) above; the total delivered
   !                    falls as dm_load/T * n_alive/n_p0.
   !       1          : the total rate dm_load/T, shared over the live gas:
   !                    m_p -> m_p + dm_load * (t - t_last) / (T * n_alive)
   !                    n_alive is recounted at each sync point. No closed form,
   !                    so t_last is carried in the dump header.
   !
   ! For modes 0 and 1, both dm_load (xi) and mloadfactor (chi) are always set:
   !   mode 0: mloadfactor = iload (user chi),  dm_load = iload * M_disc0
   !   mode 1: dm_load     = iload (user xi),   mloadfactor = iload / M_disc0
   !   mode 2: mloadfactor = iload (user beta), dm_load = 0.
   !
   ! Changing settings between restarts: iload_factor, iload, iload_dt, R_load
   ! and iload_total may be edited in the .in before a restart. The dump
   ! header records the settings in force; when the .in differs, the restart
   ! raises a warning naming each change and starts a new loading SEGMENT at
   ! the dump's particle mass m_seg and the time t_seg it was set (the header
   ! t_last, else the dump time). The closed forms above become
   !       m_p(t) = m_seg + dm_load * (t - t_seg) / (T * n_p0)
   !       m_p(t) = m_seg * exp( ln(1+beta) * (t - t_seg) / T )
   ! so the mass is continuous and the new setting applies from t_seg.
   ! m_p0 and n_p0 never change, so chi stays a fraction of the original
   ! M_disc0. The first segment is (m_p0, t_init). Headers written before
   ! the settings keys existed are compared through dm_load (chi or xi),
   ! mload_total and r_orb; beta and iload_dt are then taken as unchanged.
   !
   ! .in parameters:  iload_factor, iload, iload_dt, R_load, iload_total
   ! Dump header:     dm_load, r_orb, R_load, m_p0, t_init, n_p0, M_star0, t_last, iload_total,
   !                  mload_mode, mload_iload, mload_dt, mload_rref (R_ref), mload_mseg, mload_tseg
   ! Runtime-derived:          t_orb from r_orb + M_star0 (or the current M_star, see torb_mstar0)
   !
   ! n_p0, m_p0 and M_star0 are fixed when the setup dump is written and carried
   ! in every dump header, so each link of a chained run loads at the same rate.
   ! Two internal switches reproduce the behaviour before that fix:
   !   torb_mstar0 = .false. : T from the current host mass (T shrinks as it accretes)
   !   np0_initial = .false. : n_p0 recounted from the dump at each (re)start
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
   !   R_load       -- loading radius override [code units]; <0 = use disc R_ref
   !   iload_total  -- 0 = fixed rate per particle, 1 = fixed total rate over live gas
   !
   ! :Dependencies: dim, dump_utils, infile_utils, io, mpiutils, part, physcon, units
   !
   use part, only: igas
   implicit none

   public :: init_massloading, step_mass_loading,                   &
            log_massloading, loading_rate, rate_string,             &
            write_options_massloading, read_options_massloading,   &
            write_options_massloading_setup,                       &
            read_options_massloading_setup,                        &
            write_headeropts_massloading,                          &
            read_headeropts_massloading,                           &
            set_massloading_r_ref,                                 &
            reset_massloading

   ! .in parameters
   integer,            public   :: iload_factor   = -1        ! -1=off, 0=chi, 1=xi, 2=beta
   real,               public   :: iload          = 0.        ! chi / xi / beta
   real,               public   :: iload_dt       = -1.       ! interval; <=0 -> compute T_orb
   integer,            public   :: iload_total    = 0         ! 0=fixed rate per particle, 1=fixed total rate shared over live gas (modes 0/1)
   real,               public   :: t_last         = -1.       ! time of the last constant-mode update, persisted in dump header
   ! derived quantities (always set for modes 0 and 1)
   real,               public   :: mloadfactor    = 0.        ! chi (modes 0/1) or beta (mode 2)
   real,               public   :: dm_load        = 0.        ! xi (modes 0/1); 0 for mode 2
   real,               public   :: r_orb          = 1.        ! reference radius used to compute T_orb
   real,               public   :: t_orb          = 0.        ! current effective loading interval (updated at each sync point)
   real,               public   :: t_init         = -1.       ! simulation time of first loading step; -1 = not yet set (fresh start sentinel), persisted in dump header; also settable from tests or setup code
   real,               public   :: R_load         = -1.       ! explicit loading-radius override; <0 = use R_ref
   ! internal switches, never in .in
   logical,            public   :: torb_mstar0    = .true.    ! .true.: T from the host mass at the start; .false.: from the current host mass
   logical,            public   :: np0_initial    = .true.    ! .true.: n_p0 from the header (setup count); .false.: recounted at each (re)start
   integer,            public   :: nload_changes  = 0         ! settings found changed between the dump header and the .in at the last restart
   ! private state — set once at init, never in .in
   integer(kind=8),    private  :: n_p0           = 0         ! initial gas particle count
   integer(kind=8),    private  :: n_live         = 0         ! live gas count at the last sync point (iload_total = 1)
   real,               private  :: m_p0           = 0.        ! initial per-particle mass (M_disc0 / n_p0)
   real,               private  :: mstar0         = 0.        ! host mass at the start of loading
   integer,            private  :: id_mstar       = 1         ! sink index for host star (defaults to first sink)
   logical,            private  :: dofrac_load    = .false.   ! .true. for beta/exponential mode (iload_factor=2)
   logical,            private  :: calc_torb      = .false.   ! .true. when iload_dt<=0: compute T_orb from r_orb and M_star each sync point
   logical,            private  :: initialised    = .false.
   real,               private  :: m_seg          = 0.        ! particle mass at the start of the current loading segment
   real,               private  :: t_seg          = -1.       ! start time of the current loading segment; -1 = not yet set
   real,               private  :: r_ref          = -1.       ! disc R_ref, the loading radius when R_load < 0; -1 = unknown
   ! dump-header settings, compared with the .in when loading initialises after a restart
   logical,            private  :: hdr_loaded     = .false.   ! a header from a run that had started loading was read
   logical,            private  :: hdr_settings   = .false.   ! header carries mload_mode/mload_iload/mload_dt
   logical,            private  :: hdr_has_np0    = .false.
   integer,            private  :: hdr_mode       = -1
   integer,            private  :: hdr_total      = 0
   real,               private  :: hdr_iload      = 0.
   real,               private  :: hdr_dt         = 0.
   real,               private  :: hdr_dm_load    = 0.
   real,               private  :: hdr_r_orb      = 0.
   real,               private  :: hdr_time       = -1.
   private

contains

   !-----------------------------------------------------------------------
   !+
   !   Reads initial particle state from the part module, then delegates
   !   to parse_massloading to set dm_load / mloadfactor / flags.
   !   Called lazily on first step_mass_loading call, or explicitly from
   !   phantomsetup.
   !+
   !-----------------------------------------------------------------------
   subroutine init_massloading()
      use part, only: massoftype, npartoftypetot
      use io,   only: iprint, id, master
      real :: m_disc0

      if (  n_p0 <= 0 .or. .not. np0_initial  ) then
         n_p0 = npartoftypetot(igas)
      endif
      if (  n_p0 <= 0  ) then
         return
      endif
      if (  m_p0 == 0.  ) then
         m_p0 = massoftype(igas)   ! fresh start; on restart m_p0 is read from dump header
      endif
      m_disc0 = m_p0 * real(n_p0)

      if (  hdr_loaded  ) then
         call detect_changes(m_disc0)
         hdr_loaded = .false.
         if (  nload_changes > 0  ) then
            call parse_massloading(m_disc0)
            call start_segment()
            return
         endif
      endif

      ! restart path: dm_load already set from dump header — back-derive mloadfactor
      if (  dm_load /= 0.  ) then
         if (  iload_factor == 0 .or. iload_factor == 1  ) then
            ! back-derive chi (chi is not directly used in massloading routine.)
            if (  m_disc0 > 0.  ) then
               mloadfactor = dm_load / m_disc0
            endif
         endif
         dofrac_load = (  iload_factor == 2  )
         calc_torb   = (  iload_dt <= 0.  )
         initialised = .true.
         if (  id == master  ) then
            write(iprint,"(1x,a,i0,a,es12.4,a,es12.4,a,i0,a,es12.4,a)") &
               '[mass_loading] restart: type=', iload_factor, &
               '  dm_load=', dm_load, '  r_orb=', r_orb, '  n_p0=', n_p0, '  M_star0=', mstar0, &
               trim(rate_string(real(n_p0), m_p0, 'Mdot_nom'))
         endif
         return
      endif

      call parse_massloading(m_disc0)
   end subroutine init_massloading

   !-----------------------------------------------------------------------
   !+
   !   Derives dm_load, mloadfactor, dofrac_load, and calc_torb from the
   !   module-level .in parameters.  Called on a fresh run, on a restart in
   !   beta mode, and on a restart whose loading settings changed.
   !+
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
         if (  m_disc0 > 0.  ) then
            mloadfactor = iload / m_disc0
         endif
         dofrac_load = .false.
      case(2)   ! beta mode: no xi equivalent
         mloadfactor = iload
         dm_load     = 0.
         dofrac_load = .true.
      case default  ! -1 or any invalid value: loading off
         initialised = .true.   ! prevents lazy-init on every step when loading is off
         return
      end select

      calc_torb   = (  iload_dt <= 0.  )
      initialised = .true.

      if (  id == master  ) then
         write(iprint,"(1x,a,i0,a,es12.4,a,es12.4,a,es12.4,a,i0,a)") &
            '[mass_loading] init: type=', iload_factor, &
            '  iload=',       iload,       &
            '  mloadfactor=', mloadfactor, &
            '  dm_load=',     dm_load,     &
            '  n_p0=',        n_p0,        &
            trim(rate_string(real(n_p0), m_p0, 'Mdot_nom'))
      endif
   end subroutine parse_massloading

   !-----------------------------------------------------------------------
   !+
   !   Compares the loading settings in the dump header with the .in and sets
   !   nload_changes to the number that differ: mode, chi/xi/beta, iload_total,
   !   iload_dt and the loading radius r_orb. Master raises one warning naming
   !   each change old -> new and the restart time.
   !   Headers without mload_mode: a non-zero dm_load means a constant mode
   !   (taken as the .in's when that is 0 or 1) and zero means beta; beta and
   !   iload_dt are then taken as unchanged, as is chi without mload_np0.
   !+
   !-----------------------------------------------------------------------
   subroutine detect_changes(m_disc0)
      use io, only: id, master, warning
      real, intent(in) :: m_disc0
      integer :: mode_old
      real    :: dt_old, dm_new, val_old, t_restart
      character(len=512) :: msg
      character(len=80)  :: item

      nload_changes = 0
      msg = ''
      if (  hdr_settings  ) then
         mode_old = hdr_mode
      else if (  hdr_dm_load /= 0.  ) then
         mode_old = 0
         if (  iload_factor == 1  ) mode_old = 1
      else
         mode_old = 2
      endif

      if (  mode_old /= iload_factor  ) then
         write(item,"(a,i0,3a,i0,3a)") 'iload_factor ', mode_old, ' (', trim(mode_name(mode_old)), ') -> ', &
            iload_factor, ' (', trim(mode_name(iload_factor)), ')'
         call add_change(item)
      else if (  hdr_settings  ) then
         if (  differs(hdr_iload, iload)  ) then
            call add_change(trim(mode_name(iload_factor))//' '//trim(num(hdr_iload))//' -> '//trim(num(iload)))
         endif
      else if (  iload_factor /= 2  ) then
         dm_new = iload
         if (  iload_factor == 0  ) dm_new = iload * m_disc0
         if (  (iload_factor == 1 .or. (hdr_has_np0 .and. np0_initial)) .and. differs(hdr_dm_load, dm_new)  ) then
            val_old = hdr_dm_load
            if (  iload_factor == 0  ) val_old = hdr_dm_load / m_disc0
            call add_change(trim(mode_name(iload_factor))//' '//trim(num(val_old))//' -> '//trim(num(iload)))
         endif
      endif

      if (  mode_old /= 2 .and. iload_factor /= 2 .and. hdr_total /= iload_total  ) then
         write(item,"(a,i0,a,i0)") 'iload_total ', hdr_total, ' -> ', iload_total
         call add_change(item)
      endif

      dt_old = iload_dt
      if (  hdr_settings  ) dt_old = hdr_dt
      if (  ((dt_old > 0.) .neqv. (iload_dt > 0.)) .or. (iload_dt > 0. .and. differs(dt_old, iload_dt))  ) then
         call add_change('iload_dt '//trim(num(dt_old))//' -> '//trim(num(iload_dt)))
      else if (  iload_dt <= 0. .and. differs(hdr_r_orb, r_orb)  ) then
         call add_change('loading radius (R_load/R_ref) '//trim(num(hdr_r_orb))//' -> '//trim(num(r_orb)))
      endif

      if (  nload_changes > 0 .and. id == master  ) then
         t_restart = hdr_time
         if (  t_restart < 0.  ) t_restart = t_last
         call warning('mass_loading','loading settings changed at restart (t = '//trim(num(t_restart))//'): '//trim(msg))
      endif

   contains

      subroutine add_change(str)
         character(len=*), intent(in) :: str
         nload_changes = nload_changes + 1
         if (  len_trim(msg) > 0  ) msg = trim(msg)//'; '
         msg = trim(msg)//' '//trim(str)
         msg = adjustl(msg)
      end subroutine add_change

   end subroutine detect_changes

   character(len=4) function mode_name(mode)
      integer, intent(in) :: mode
      select case(mode)
      case(0)
         mode_name = 'chi'
      case(1)
         mode_name = 'xi'
      case(2)
         mode_name = 'beta'
      case default
         mode_name = 'off'
      end select
   end function mode_name

   character(len=16) function num(x)
      real, intent(in) :: x
      if (  x /= 0. .and. (abs(x) < 1.e-3 .or. abs(x) >= 1.e5)  ) then
         write(num,"(es11.4)") x
      else
         write(num,"(f14.4)") x
      endif
      num = adjustl(num)
   end function num

   logical function differs(a, b)
      real, intent(in) :: a, b
      differs = abs(a - b) > 1.e-8 * max(abs(a), abs(b))
   end function differs

   !-----------------------------------------------------------------------
   !+
   !   Starts a loading segment after a restart with changed settings:
   !   m_seg = the dump's particle mass, t_seg = the time it was set (the
   !   header t_last, else the dump time). t_last moves there too, so
   !   fixed-total loading continues from the same point.
   !   Fatal if the header has neither t_last nor the dump time.
   !+
   !-----------------------------------------------------------------------
   subroutine start_segment()
      use part, only: massoftype
      use io,   only: iprint, id, master, fatal

      m_seg = massoftype(igas)
      if (  t_last >= 0.  ) then
         t_seg = t_last
      else if (  hdr_time >= 0.  ) then
         t_seg = hdr_time
      else
         call fatal('mass_loading','loading settings changed at restart, but the dump header has no mload_tlast or time')
      endif
      t_last = t_seg
      if (  id == master  ) then
         write(iprint,"(1x,a,es13.6,a,es13.6)") &
            '[mass_loading] new loading segment from t =', t_seg, '  at m_p =', m_seg
      endif
   end subroutine start_segment

   !-----------------------------------------------------------------------
   !+
   !   Currently a no-op: r_orb is set from setup via set_massloading_r_ref
   !   or restored from the dump header on restart.
   !   Extension point: could evolve to recompute r_orb from particle
   !   distributions (e.g. disc centre-of-mass radius) in future.
   !+
   !-----------------------------------------------------------------------
   subroutine update_r_orb()
   end subroutine update_r_orb

   !-----------------------------------------------------------------------
   !+
   !   Recomputes the loading interval at each sync point.
   !   If calc_torb: derives T_orb = 2*pi * r_orb^1.5 / sqrt(M_star) [G=1].
   !   Otherwise: uses the fixed iload_dt.
   !+
   !-----------------------------------------------------------------------
   subroutine update_t_orb(t, dtmax)
      use part,     only: nptmass, xyzmh_ptmass
      use mpiutils, only: bcast_mpi
      use io,       only: iprint, id, master, iverbose
      real, intent(in) :: t, dtmax
      real :: M_primary

      if (  calc_torb  ) then
         M_primary = 0.
         if (  id == master .and. nptmass > 0  ) then
            if (  mstar0 <= 0.  ) then
               mstar0 = xyzmh_ptmass(4, id_mstar)
            endif
            M_primary = xyzmh_ptmass(4, id_mstar)
            if (  torb_mstar0  ) then
               M_primary = mstar0
            endif
         endif
         call bcast_mpi(M_primary)
         if (  M_primary > 0.  ) then
            t_orb = 2. * acos(-1.) * r_orb**1.5 / sqrt(M_primary)
         else
            t_orb = dtmax
         endif
      else
         t_orb = iload_dt
      endif

      if (  t_orb <= 0.  ) then
         t_orb = dtmax
      endif

      if (  id == master .and. iverbose >= 1  ) then
         write(iprint,"(1x,a,es12.4,a,es12.4)") &
            '[mass_loading] t=', t, '  t_orb=', t_orb
      endif
   end subroutine update_t_orb

   !-----------------------------------------------------------------------
   !+
   !   Constant loading (modes 0 and 1):
   !       m_p(t) = m_seg + dm_load * (t - t_seg) / (T * n_p0)
   !   Computed directly from the segment start (m_seg, t_seg) to avoid
   !   accumulating floating-point error over many binsteps.  The first
   !   segment is (m_p0, t_init); t_init is set on first call.
   !   Exact when T is constant (torb_mstar0 or a fixed iload_dt). With
   !   torb_mstar0 = .false. the current T is applied to the whole elapsed
   !   time, so the loaded mass is re-rated whenever the host mass changes.
   !+
   !-----------------------------------------------------------------------
   subroutine apply_partmass_const(dt, time)
      use part, only: massoftype
      use io,   only: iprint, id, master, iverbose, log_splitstep, steplog_extra
      real, intent(in)  ::    dt, time
      real              ::    m_old
      character(len=24) ::    dmstr

      if (  dm_load == 0. .or. n_p0 <= 0 .or. t_orb <= 0. .or. dt <= 0.  ) then
         return
      endif
      if (  t_init < 0.  ) then
         t_init = time
      endif
      if (  t_last < 0.  ) then
         t_last = time
      endif
      if (  t_seg < 0.  ) then
         t_seg = t_init
         m_seg = m_p0
      endif

      m_old            = massoftype(igas)
      if (  iload_total == 1  ) then
         if (  n_live > 0 .and. time > t_last  ) then
            massoftype(igas) = m_old + dm_load * (time - t_last) / (t_orb * real(n_live))
         endif
      else
         massoftype(igas) = m_seg + dm_load * (time - t_seg) / (t_orb * real(n_p0))
      endif
      t_last = time

      if (  id == master .and. iverbose >= 1  ) then
         if (  iverbose >= 2 .or. log_splitstep  ) then
            write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4)") &
               '[mass_loading] t=', time, &
               '  dm/m=', (massoftype(igas) - m_old) / m_old, &
               '  m_gas=', massoftype(igas)
         else
            write(dmstr,"(a,es10.3)") ' dm/m = ', (massoftype(igas) - m_old) / m_old
            steplog_extra = trim(steplog_extra)//dmstr
         endif
      endif

   end subroutine apply_partmass_const

   !-----------------------------------------------------------------------
   !+
   !   Exponential/beta loading (mode 2):
   !       m_p(t) = m_seg * exp( ln(1+beta) * (t - t_seg) / T )
   !   Computed directly from the segment start (m_seg, t_seg) to avoid
   !   accumulating floating-point error over many binsteps.  The first
   !   segment is (m_p0, t_init); t_init is set on first call.
   !   Exact when T is constant (torb_mstar0 or a fixed iload_dt). With
   !   torb_mstar0 = .false. the current T is applied to the whole elapsed
   !   time, so the loaded mass is re-rated whenever the host mass changes.
   !+
   !-----------------------------------------------------------------------
   subroutine apply_partmass_exp(dt, time)
      use part, only: massoftype
      use io,   only: iprint, id, master, iverbose, log_splitstep, steplog_extra
      real, intent(in)  ::    dt, time
      real              ::    m_old
      character(len=24) ::    dmstr

      if (  mloadfactor == 0. .or. t_orb <= 0. .or. dt <= 0.  ) then 
         return
      endif
      if (  t_init < 0.  ) then
         t_init = time
      endif
      if (  t_seg < 0.  ) then
         t_seg = t_init
         m_seg = m_p0
      endif

      m_old            = massoftype(igas)
      massoftype(igas) = m_seg * exp(log(1. + mloadfactor) * (time - t_seg) / t_orb)
      t_last           = time

      if (  id == master .and. iverbose >= 1  ) then
         if (  iverbose >= 2 .or. log_splitstep  ) then
            write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4)") &
               '[mass_loading] t=', time, &
               '  dm/m=', (massoftype(igas) - m_old) / m_old, &
               '  m_gas=', massoftype(igas)
         else
            write(dmstr,"(a,es10.3)") ' dm/m = ', (massoftype(igas) - m_old) / m_old
            steplog_extra = trim(steplog_extra)//dmstr
         endif
      endif

   end subroutine apply_partmass_exp

   !-----------------------------------------------------------------------
   !+
   !   Public entry point called from evol_prestep each substep.
   !   Lazy-initialises on first call, then refreshes r_orb and t_orb before
   !   applying the per-particle mass increment.  The refresh fires at each
   !   sync point and, in addition, on any call where t_orb has not yet been
   !   derived (t_orb<=0).  That extra condition covers the first dtmax
   !   interval of a fresh or restarted run: no sync point has occurred yet,
   !   but loading must already be active.  Without it the first interval
   !   (and each restart's first interval, since t_orb is not persisted in the
   !   dump header) would silently apply no loading at all.
   !+
   !-----------------------------------------------------------------------
   subroutine step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)
      use dim, only: ind_timesteps
      real,             intent(in)  :: time, dt, dtmax
      integer,          intent(in)  :: istepfrac
      integer(kind=1),  intent(in)  :: nbinmax

      if (  .not. initialised  ) then 
         call init_massloading()
      endif
      if ( (  iload_factor < 0  ) .or. (  .not. dofrac_load .and. dm_load == 0.  ) .or. &
           (  dofrac_load .and. mloadfactor == 0.  )  ) return
  
      if (  .not. ind_timesteps .or. istepfrac == 2**nbinmax .or. t_orb <= 0.  ) then
         call update_r_orb()
         call update_t_orb(time, dtmax)
         if (  iload_total == 1 .and. .not. dofrac_load  ) n_live = count_live_gas()
      endif

      if (  dofrac_load  ) then
         call apply_partmass_exp(dt, time)
      else
         call apply_partmass_const(dt, time)
      endif
   end subroutine step_mass_loading

   !-----------------------------------------------------------------------
   !+
   !   Print a one-line summary of disc mass evolution at each dump point.
   !   M_disc_now = massoftype(igas) * n_alive   (gas not accreted or killed)
   !   M_disc_0   = m_p0 * n_p0
   !   f_alive    = n_alive / n_p0, the fraction of the nominal loading the
   !                disc still receives (iload_total = 0; with 1 it receives all of it)
   !   No-op when iload_factor < 0 (mass loading off) or not yet initialised.
   !+
   !-----------------------------------------------------------------------
   subroutine log_massloading(time)
      use part,     only: massoftype
      use io,       only: iprint, id, master
      real, intent(in) :: time
      real             :: m_disc_now, m_disc_0, dm_p, ratio, f_alive
      integer(kind=8)  :: n_alive

      if (  iload_factor < 0 .or. n_p0 <= 0 .or. m_p0 <= 0.  ) then
         return
      endif

      n_alive = count_live_gas()

      m_disc_now = massoftype(igas) * real(n_alive)
      m_disc_0   = m_p0 * real(n_p0)
      ratio      = m_disc_now / m_disc_0
      f_alive    = real(n_alive) / real(n_p0)
      dm_p       = massoftype(igas) - m_p0

      if (  id == master  ) then
         write(iprint, &
         "('[mass_loading] dump: t=',es10.3,'  M_disc/M_disc0=',es10.3,'  dm_p=',es10.3,'  f_alive=',f8.5,a,a)") &
         time, ratio, dm_p, f_alive, &
         trim(rate_string(real(n_p0), massoftype(igas), 'Mdot_nom')), &
         trim(rate_string(real(n_alive), massoftype(igas), 'Mdot_del'))
      endif

   end subroutine log_massloading

   !-----------------------------------------------------------------------
   !+
   !   Total mass-loading rate in code units (mass per time) delivered to a
   !   disc of n_gas gas particles of mass mp.  0 if t_orb is not yet known.
   !   Constant loading (modes 0/1): dm_load/t_orb; scaled by n_gas/n_p0 for
   !   iload_total = 0 (rate is per particle), unscaled for iload_total = 1.
   !   Exponential loading (mode 2): n_gas*mp*ln(1+mloadfactor)/t_orb.
   !   Nominal rate: call with n_gas = n_p0.
   !+
   !-----------------------------------------------------------------------
   real function loading_rate(n_gas, mp) result(rate)
      real, intent(in) :: n_gas, mp

      rate = 0.
      if (  iload_factor < 0 .or. t_orb <= 0.  ) return
      if (  iload_factor == 2  ) then
         rate = n_gas * mp * log(1. + mloadfactor) / t_orb
      else
         rate = dm_load / t_orb
         if (  iload_total == 0 .and. n_p0 > 0  ) rate = rate * n_gas / real(n_p0)
      endif
   end function loading_rate

   !-----------------------------------------------------------------------
   !+
   !   Formatted '  <label>=<code>  <label>_Msun/yr=..  <label>_MJup/yr=..'
   !   for loading_rate(n_gas, mp); empty string if the rate is unknown.
   !+
   !-----------------------------------------------------------------------
   function rate_string(n_gas, mp, label) result(str)
      use units,   only: umass, utime
      use physcon, only: solarm, jupiterm, years
      real,             intent(in) :: n_gas, mp
      character(len=*), intent(in) :: label
      character(len=120)           :: str
      real             :: rate
      real(kind=8)     :: gps

      str  = ''
      if (  iload_factor < 0 .or. t_orb <= 0.  ) return
      rate = loading_rate(n_gas, mp)
      gps  = real(rate,kind=8) * umass / utime
      write(str,"('  ',a,'=',es10.3,'  ',a,'_Msun/yr=',es10.3,'  ',a,'_MJup/yr=',es10.3)") &
         label, rate, label, gps*years/solarm, label, gps*years/jupiterm
   end function rate_string

   !-----------------------------------------------------------------------
   !+
   !   Number of gas particles neither accreted nor killed, over all MPI
   !   ranks. npartoftype is not decremented on sink accretion, so count.
   !+
   !-----------------------------------------------------------------------
   integer(kind=8) function count_live_gas() result(n)
      use part,     only: npart, xyzh, iphase, iamtype, isdead_or_accreted
      use dim,      only: maxphase, maxp
      use mpiutils, only: reduceall_mpi
      integer :: i

      n = 0
      do i = 1, npart
         if (  isdead_or_accreted(xyzh(4,i))  ) cycle
         if (  maxphase == maxp  ) then
            if (  iamtype(iphase(i)) /= igas  ) cycle
         endif
         n = n + 1
      enddo
      n = reduceall_mpi('+', n)
   end function count_live_gas

!-----------------------------------------------------------------------
! I/O routines
!-----------------------------------------------------------------------

   subroutine write_options_massloading(iunit)
      use infile_utils, only: write_inopt
      integer, intent(in) :: iunit

      write(iunit,"(/,a)") '# options for mass loading (may be changed between restarts: loading continues from the current particle mass)'
      call write_inopt(iload_factor, 'iload_factor', &
         'loading mode: -1=off, 0=chi (fraction/orbit), 1=xi (absolute/orbit), 2=beta (exponential)', iunit)
      call write_inopt(iload,   'iload',   &
         'loading factor: chi (mode 0), xi [code units] (mode 1), or beta (mode 2)', iunit)
      call write_inopt(iload_dt,'iload_dt', &
         'loading interval [code units]; <=0 = orbital period at r_orb', iunit)
      call write_inopt(R_load,'R_load', &
         'radius for orbital-period loading [code units]; <0 = use disc R_ref', iunit)
      call write_inopt(iload_total,'iload_total', &
         'modes 0/1: 0=fixed rate per particle (total falls as gas is accreted), 1=fixed total rate over live gas', iunit)
      end subroutine write_options_massloading

      subroutine read_options_massloading(db, nerr)
      use infile_utils, only: inopts, read_inopt
      use io,           only: iprint, id, master, fatal
      type(inopts), intent(inout) :: db(:)
      integer,      intent(inout) :: nerr
      integer :: ierr_v1, ierr
      real    :: dummy_v1

      ! >>> COMPAT_CHECK_V1: remove when all configs migrated to v2 params <<<
      ierr_v1 = 0
      call read_inopt(dummy_v1, 'iload_dm', db, err=ierr_v1)
      if (  ierr_v1 == 0  ) then
         if (  id == master  ) then
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

      ! R_load: explicit loading-radius override (optional, backward compatible).
      ! R_ref is deliberately NOT read here: it lives in the .setup/.discparams,
      ! never in the .in. It reaches r_orb via the dump header (seeded at
      ! phantomsetup by set_massloading_r_ref); when R_load<0 the precedence in
      ! read_headeropts falls back to that header r_orb.
      ierr = 0
      call read_inopt(R_load, 'R_load', db, err=ierr)

      ! iload_total: absent from .in files written before it existed (-> 0); out of range is an error
      call read_inopt(iload_total, 'iload_total', db, errcount=nerr, min=0, max=1, default=0)
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
      call write_inopt(R_load,'R_load', &
         'radius for orbital-period loading [code units]; <0 = use disc R_ref', iunit)
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
      if (  ierr_v1 == 0  ) then
         if (  id == master  ) then
            write(iprint,"(a)") '[mass_loading] FATAL: deprecated param "iload_dm" found in .setup file.'
            write(iprint,"(a)") '  Migrate: set  iload_factor = 1,  iload = <xi value>,  iload_dt = <interval>'
         endif
         call fatal('mass_loading','deprecated v1 parameter "iload_dm" in .setup file')
      endif
      ! >>> END COMPAT_CHECK_V1 <<<

      call read_inopt(iload_factor, 'iload_factor', db, errcount=nerr, min=-1)
      call read_inopt(iload,        'iload',        db, errcount=nerr)
      call read_inopt(iload_dt,     'iload_dt',     db, errcount=nerr)

      ! R_load: explicit loading-radius override (optional)
      ierr = 0
      call read_inopt(R_load, 'R_load', db, err=ierr)

      ! pick up R_ref from setup db so orbital-period loading works without .in edit
      ierr = 0
      call read_inopt(r_ref_tmp, 'R_ref', db, err=ierr, min=0.)
      ! resolve r_orb by precedence: R_load (>=0) wins, else R_ref
      if (  R_load >= 0.  ) then
         r_orb = R_load
      else if (  ierr == 0 .and. r_ref_tmp > 0.  ) then
         r_orb = r_ref_tmp
      endif
      if (  ierr == 0 .and. r_ref_tmp > 0.  ) r_ref = r_ref_tmp
   end subroutine read_options_massloading_setup

   !-----------------------------------------------------------------------
   !+
   !   Writes the loading state to the dump header. n_p0, m_p0 and M_star0
   !   are taken from the current particles when loading has not initialised
   !   yet, so the setup dump already fixes them. The active .in settings
   !   (mload_mode, mload_iload, mload_dt, R_load, mload_total, mload_rref)
   !   let a restart detect a change; mload_mseg and mload_tseg anchor the
   !   current loading segment. A header read but not yet compared with the
   !   .in is compared first (init_massloading), so a dump written before
   !   the first step after a restart records the new segment.
   !+
   !-----------------------------------------------------------------------
   subroutine write_headeropts_massloading(hdr, ierr)
      use dump_utils, only: dump_h, add_to_rheader
      use part,       only: massoftype, npartoftypetot, nptmass, xyzmh_ptmass
      type(dump_h), intent(inout) :: hdr
      integer,      intent(inout) :: ierr
      real :: np0_hdr, mp0_hdr, mstar0_hdr, mseg_hdr, tseg_hdr

      if (  hdr_loaded  ) call init_massloading()
      np0_hdr = real(n_p0)
      if (  n_p0 <= 0  ) np0_hdr = real(npartoftypetot(igas))
      mp0_hdr = m_p0
      if (  m_p0 <= 0.  ) mp0_hdr = massoftype(igas)
      mstar0_hdr = mstar0
      if (  mstar0 <= 0. .and. nptmass > 0  ) mstar0_hdr = xyzmh_ptmass(4, id_mstar)
      mseg_hdr = m_seg
      tseg_hdr = t_seg
      if (  t_seg < 0.  ) then
         mseg_hdr = mp0_hdr
         tseg_hdr = -1.
      endif

      call add_to_rheader(dm_load,    'dm_load',      hdr, ierr)
      call add_to_rheader(r_orb,      'r_orb',        hdr, ierr)
      call add_to_rheader(R_load,     'R_load',       hdr, ierr)
      call add_to_rheader(mp0_hdr,    'mload_mp0',    hdr, ierr)
      call add_to_rheader(t_init,     'mload_tinit',  hdr, ierr)
      call add_to_rheader(np0_hdr,    'mload_np0',    hdr, ierr)
      call add_to_rheader(mstar0_hdr, 'mload_mstar0', hdr, ierr)
      call add_to_rheader(t_last,     'mload_tlast',  hdr, ierr)
      call add_to_rheader(real(iload_total), 'mload_total', hdr, ierr)
      call add_to_rheader(real(iload_factor), 'mload_mode', hdr, ierr)
      call add_to_rheader(iload,      'mload_iload',  hdr, ierr)
      call add_to_rheader(iload_dt,   'mload_dt',     hdr, ierr)
      call add_to_rheader(r_ref,      'mload_rref',   hdr, ierr)
      call add_to_rheader(mseg_hdr,   'mload_mseg',   hdr, ierr)
      call add_to_rheader(tseg_hdr,   'mload_tseg',   hdr, ierr)
   end subroutine write_headeropts_massloading

   !-----------------------------------------------------------------------
   !+
   !   Restores the loading state from the dump header (after the .in has
   !   been read) and resolves r_orb: the .in R_load if >= 0, else R_ref,
   !   else the header r_orb. If loading had started (mload_tinit >= 0) the
   !   header settings are kept for init_massloading to compare with the .in.
   !   Keys added later are optional; missing ones fall back as noted below.
   !   Fatal if the .in sets R_load < 0 but the header only knows an earlier
   !   R_load (no mload_rref), so R_ref cannot be recovered.
   !+
   !-----------------------------------------------------------------------
   subroutine read_headeropts_massloading(hdr)
      use dump_utils, only: dump_h, extract
      use io,         only: fatal
      type(dump_h), intent(in) :: hdr
      integer :: ierr
      real    :: np0_hdr, tlast_hdr, total_hdr, val, rload_hdr

      if (iload_factor < 0) return
      ierr = 0;  call extract('dm_load',     dm_load, hdr, ierr)
      ierr = 0;  call extract('r_orb',       r_orb,   hdr, ierr)
      ierr = 0;  call extract('mload_mp0',   m_p0,    hdr, ierr)
      ierr = 0;  call extract('mload_tinit', t_init,  hdr, ierr)
      ! dumps written before n_p0/M_star0 were persisted lack these keys; both
      ! then stay unset and are taken from the particles at (re)start
      ierr = 0;  call extract('mload_np0',    np0_hdr, hdr, ierr)
      hdr_has_np0 = (  ierr == 0 .and. np0_hdr > 0.  )
      if (  hdr_has_np0  ) then
         n_p0 = nint(np0_hdr, kind=8)
      else
         call warn_legacy_header('mload_np0')
      endif
      ierr = 0;  call extract('mload_mstar0', mstar0,  hdr, ierr)
      if (  ierr /= 0 .or. mstar0 <= 0.  ) then
         mstar0 = 0.
         call warn_legacy_header('mload_mstar0')
      endif
      ! t_last: absent before iload_total existed; the first update then starts from the restart time
      ierr = 0;  call extract('mload_tlast', tlast_hdr, hdr, ierr)
      t_last = -1.
      if (  ierr == 0  ) t_last = tlast_hdr
      ierr = 0;  call extract('mload_total', total_hdr, hdr, ierr)
      hdr_total = 0
      if (  ierr == 0  ) hdr_total = nint(total_hdr)

      hdr_settings = in_header('mload_mode', hdr)
      if (  hdr_settings  ) then
         ierr = 0;  call extract('mload_mode',  val,       hdr, ierr)
         hdr_mode = nint(val)
         ierr = 0;  call extract('mload_iload', hdr_iload, hdr, ierr)
         ierr = 0;  call extract('mload_dt',    hdr_dt,    hdr, ierr)
      endif
      ! segment anchor; without it the first segment (m_p0, t_init) is set at the first step
      m_seg = 0.
      t_seg = -1.
      if (  in_header('mload_tseg', hdr)  ) then
         ierr = 0;  call extract('mload_tseg', val, hdr, ierr)
         if (  val >= 0.  ) then
            t_seg = val
            ierr = 0;  call extract('mload_mseg', m_seg, hdr, ierr)
         endif
      endif
      hdr_time = -1.
      if (  in_header('time', hdr)  ) then
         ierr = 0;  call extract('time', hdr_time, hdr, ierr)
      endif

      ! R_ref: from mload_rref; before that key existed the header r_orb is
      ! R_ref unless the header R_load was set
      rload_hdr = -1.
      if (  in_header('R_load', hdr)  ) then
         ierr = 0;  call extract('R_load', rload_hdr, hdr, ierr)
      endif
      val = -1.
      if (  in_header('mload_rref', hdr)  ) then
         ierr = 0;  call extract('mload_rref', val, hdr, ierr)
      endif
      if (  val > 0.  ) then
         r_ref = val
      else if (  rload_hdr < 0.  ) then
         r_ref = r_orb
      endif

      hdr_dm_load = dm_load
      hdr_r_orb   = r_orb
      hdr_loaded  = (  t_init >= 0.  )

      if (  R_load >= 0.  ) then
         r_orb = R_load
      else if (  r_ref > 0.  ) then
         r_orb = r_ref
      else if (  iload_dt <= 0.  ) then
         call fatal('mass_loading','the dump header has R_load >= 0 and no mload_rref, so R_ref is unknown '// &
                    'and the .in R_load < 0 cannot fall back to it. Set R_load explicitly in the .in.')
      endif
   end subroutine read_headeropts_massloading

   logical function in_header(tag, hdr) result(found)
      use dump_utils, only: dump_h, i_real, i_real4, i_real8
      character(len=*), intent(in) :: tag
      type(dump_h),     intent(in) :: hdr

      found = .false.
      if (  allocated(hdr%realtags)  ) found = any(hdr%realtags(1:hdr%nums(i_real)) == tag)
      if (  allocated(hdr%real4tags) ) found = found .or. any(hdr%real4tags(1:hdr%nums(i_real4)) == tag)
      if (  allocated(hdr%real8tags) ) found = found .or. any(hdr%real8tags(1:hdr%nums(i_real8)) == tag)
   end function in_header

   subroutine warn_legacy_header(tag)
      use io, only: iprint, id, master
      character(len=*), intent(in) :: tag

      if (  id == master  ) then
         write(iprint,"(1x,a)") '[mass_loading] WARNING: no '//tag// &
            ' in the dump header; taking it from the particles at this (re)start'
      endif
   end subroutine warn_legacy_header

   subroutine set_massloading_r_ref(r)
      real, intent(in) :: r
      if (  r > 0.  ) then
         r_orb = r
         r_ref = r
      endif
   end subroutine set_massloading_r_ref

   !-----------------------------------------------------------------------
   !+
   !   Resets all private state to module defaults.  Intended for unit
   !   tests so that each test case starts from a known clean state.
   !+
   !-----------------------------------------------------------------------
   subroutine reset_massloading()
      n_p0        = 0
      m_p0        = 0.
      mstar0      = 0.
      dofrac_load = .false.
      calc_torb   = .false.
      initialised = .false.
      t_init      = -1.
      R_load             = -1.
      iload_total = 0
      t_last      = -1.
      n_live      = 0
      m_seg       = 0.
      t_seg       = -1.
      r_ref       = -1.
      hdr_loaded  = .false.
      hdr_settings = .false.
      hdr_has_np0 = .false.
      hdr_mode    = -1
      hdr_total   = 0
      hdr_time    = -1.
      nload_changes = 0
   end subroutine reset_massloading

end module mass_loading
