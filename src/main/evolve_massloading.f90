!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module mass_loading
   !
   ! Uniform mass loading of gas (and optionally sink) particles.
   !
   ! Particle scope (iload_scope):
   !    0  gas only
   !    8  gas + secondary sinks  (j >= 2; primary sink excluded)
   !   -1  gas + all sinks        (j >= 1)
   !
   ! Sinks receive the same fractional mass increment as gas (dm_frac).
   ! Sink updates are master-only and broadcast after each fine step.
   !
   ! Two loading modes (iload_type):
   !   -1  off
   !    0  constant    $\dot{m} = \texttt{iload} / t_{eff}$  [M/t];  per $\Delta t$: $\texttt{massoftype} += \dot{m} \cdot \Delta t$
   !    1  fractional  $\lambda = \ln{1+\texttt{iload}} / t_{eff}$  [1/t];  per $\Delta t$: $\texttt{massoftype} *= \exp{\lambda \Delta t}
   !
   ! $t_{eff}$ is set by `iload_dt`:
   !     >0 = fixed code-unit interval;
   !     <0 = orbital period: $t_{eff} = 2\pi R_{ref}^{3/2}/\sqrt{M_{primary}}$ from the first sink ($G=1$ assumed).
   !
   ! Step frequency (iload_step):
   !   0  binstep  apply every fine step with dt = dtsph
   !   1  sync     apply once per dtmax at the full sync point with dt = dtmax
   !
   ! Velocity models (iload_vel) -- momentum conservation for injected mass:
   !   0  comoving    no velocity change
   !   1  stationary  injected mass at rest;  Dv = -frac/(1+frac)*v
   !   2  wind        injected at vload;      Dv =  frac/(1+frac)*(vload-v)
   !
   ! Call sites in evolve.f90 evol_prestep (wired automatically):
   !   if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) &
   !      call calc_massloading_rate(npart, iphase, time, dtmax)
   !   select case (iload_step)
   !   case (0)
   !      call apply_mass_loading(npart,xyzh,vxyzu,iphase,dt,time, &
   !                              istepfrac,nbinmax,ind_timesteps)
   !   case (1)
   !      if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) &
   !         call apply_mass_loading(npart,xyzh,vxyzu,iphase,dtmax,time, &
   !                                 istepfrac,nbinmax,ind_timesteps)
   !   end select
   !
   ! :Owner: will-roscoe
   !
   ! :Runtime parameters:
   !   iload_type  -- -1=off, 0=constant, 1=fractional
   !   iload_scope -- particle scope: 0=gas only, 8=gas+secondary sinks, -1=gas+all sinks
   !   iload       -- amount per interval (M or fraction)
   !   iload_dt    -- interval [code units]; <0 = orbital period
   !   iload_step  -- 0=every fine step, 1=sync poinstt only
   !   iload_vel   -- 0=comoving, 1=stationary, 2=wind
   !   vload       -- wind velocity [code units] (iload_vel=2 only)
   !
   ! r_ref_load is NOT written to the .in file.  It is set automatically by
   ! the setup module via set_massloading_r_ref(r_ref).  An explicit
   ! r_ref_load key in the .in file acts as an override (silently ignored
   ! if absent).
   !
   ! :Dependencies: infile_utils, io, mpiutils, part
   !
   use part, only: igas
   implicit none
   public :: calc_massloading_rate, apply_mass_loading, &
             write_options_massloading, read_options_massloading, &
             set_massloading_r_ref

   integer, public :: iload_type  = -1    ! -1=off, 0=constant, 1=fractional
   integer, public :: iload_scope = 0     ! 0=gas only, 8=gas+secondary sinks, -1=gas+all sinks
   integer, public :: iload_step  = 0     ! 0=every fine step, 1=sync point only
   real,    public :: iload       = 0.0   ! amount per interval
   real,    public :: iload_dt    = 1.0   ! loading interval [code units]; <0 = orbital period
   real,    public :: r_ref_load  = 1.0   ! reference radius for T_orb (iload_dt<0 only)
   integer, public :: iload_vel   = 0     ! velocity model
   real,    public :: vload(3)    = 0.0   ! wind velocity for iload_vel=2

   ! computed each dtmax by calc_massloading_rate
   real, private :: mdot  = 0.  ! absolute rate for sim [M/t]   (mode 0)
   real, private :: mfrac = 0.  ! log-fractional rate [1/t]      (mode 1)

   ! cumulative product of (m_new/m_old) over all applied steps;
   ! used by checkconserved to remove the expected mass-loading contribution
   ! before checking conservation laws.  Persisted in dump headers.
   real, public  :: load_mass_factor = 1.0

   private

contains

   !------------------------------------------------------------
   !+
   !  First sink index to load, determined by iload_scope.
   !  Returns nptmass+1 when no sinks are in scope (safe upper bound).
   !+
   !------------------------------------------------------------
   pure integer function sink_jstart(nptmass)
      integer, intent(in) :: nptmass
      select case (iload_scope)
      case (-1)
         sink_jstart = 1              ! all sinks
      case (8)
         sink_jstart = 2              ! secondary sinks only
      case default
         sink_jstart = nptmass + 1    ! no sinks
      end select
   end function sink_jstart

   !------------------------------------------------------------
   !+
   !  Compute the per-step loading rates mdot / mfrac.
   !  Called once per dtmax at sync points (analogous to calc_iload).
   !+
   !------------------------------------------------------------
   subroutine calc_massloading_rate(npart, iphase, t, dtmax)
      use part,     only: massoftype, npartoftypetot, isdead_or_accreted, iamtype, &
                        maxphase, maxp, iamboundary, &
                        nptmass, xyzmh_ptmass
      use mpiutils, only: reduceall_mpi
      use io,       only: iprint, id, master, iverbose
      integer,         intent(in) :: npart
      integer(kind=1), intent(in) :: iphase(:)
      real,            intent(in) :: t, dtmax
      real    :: t_eff, M_primary
      integer :: ngasalive, i, itype
      logical :: multi_type

      if (iload_type < 0) return

      ! effective loading interval, go get it via orbital period at R_ref
      if (iload_dt < 0.) then
         ! orbital period: T = 2*pi * r_ref^(3/2) / sqrt(G*M); G=1 assumed
         M_primary = 0.
         if (id == master .and. nptmass > 0) M_primary = xyzmh_ptmass(4,1)
         call reduceall_mpi_wrapper(M_primary)
         if (M_primary > 0.) then
            t_eff = 2.*acos(-1.) * r_ref_load**1.5 / sqrt(M_primary)
         else
            t_eff = dtmax   ! fallback if no sink
         endif
      else
         t_eff = iload_dt
      endif

      if (t_eff <= 0.) t_eff = dtmax

      select case (iload_type)

         case (0) ! constant:  mdot = deltaM_tot per T_eff, distributed equally over gas.
            mdot  = iload / t_eff
            mfrac = 0.

         case (1) ! fractional:  mfrac such that m(t+T) = m(t)*(1+iload) exactly
            mfrac = log(1. + iload) / t_eff
            mdot  = 0.

      end select

      if (id == master .and. iverbose >= 2) then
         select case (iload_type)
            case (0)
               write(iprint,"(1x,a,es12.4,a,es12.4)") &
                  '[mass_loading] t=', t, '  mdot=', mdot
            case (1)
               write(iprint,"(1x,a,es12.4,a,es12.4)") &
                  '[mass_loading] t=', t, '  mfrac=', mfrac
         end select
      endif
   end subroutine calc_massloading_rate

   !------------------------------------------------------------
   !+
   !  Wrapper: broadcast a real scalar from master to all ranks.
   !+
   !------------------------------------------------------------
   subroutine reduceall_mpi_wrapper(x)
      use mpiutils, only: bcast_mpi
      real, intent(inout) :: x
      call bcast_mpi(x)
   end subroutine reduceall_mpi_wrapper

   !------------------------------------------------------------
   !+
   !  Apply one mass-loading increment over a fine step dtsph.
   !  Called every fine step (iload_step=0) or once per dtmax (iload_step=1).
   !
   !  istepfrac / nbinmax: current step-fraction counter and maximum bin depth
   !  from evolve.f90 — used to gate the velocity correction to only the
   !  particles that are active at this fine step.  Pass istepfrac=1,
   !  nbinmax=0 when ind_timesteps is false (all particles active).
   !+
   !------------------------------------------------------------
   subroutine apply_mass_loading(npart, xyzh, vxyzu, iphase, dtsph, time, &
                                  istepfrac, nbinmax, ind_timesteps)
      use part,     only: massoftype, npartoftypetot, isdead_or_accreted, iamtype, &
                           maxphase, maxp, iamboundary, ibin, &
                           nptmass, xyzmh_ptmass, vxyz_ptmass
      use mpiutils, only: bcast_mpi
      use io,       only: iprint, id, master, iverbose
      integer,         intent(in)    :: npart
      real,            intent(in)    :: xyzh(:,:)
      real,            intent(inout) :: vxyzu(:,:)
      integer(kind=1), intent(in)    :: iphase(:)
      real,            intent(in)    :: dtsph, time
      integer,         intent(in)    :: istepfrac, nbinmax
      logical,         intent(in)    :: ind_timesteps
      real    :: dm_frac, m_old, vinj(3)
      integer :: i, j, jstart, itype, istride
      logical :: multi_type

      if (iload_type < 0 .or. dtsph <= 0.) return

      m_old      = massoftype(igas)
      multi_type = (maxphase == maxp)
      jstart     = sink_jstart(nptmass)

      !------------------------------------------------------------------
      ! Update massoftype(gas)
      !------------------------------------------------------------------
      select case (iload_type)
         case (0) ! constant: net change = mdot*dtsph [total M], split equally per particle
            if (npartoftypetot(igas) > 0) then
               massoftype(igas) = m_old + mdot * dtsph / real(npartoftypetot(igas))
            endif
            dm_frac = (massoftype(igas) - m_old) / m_old

         case (1) ! fractional: exact exponential step
            massoftype(igas) = m_old * exp(mfrac * dtsph)
            dm_frac = massoftype(igas) / m_old - 1.

         case default
            return

      end select

      if (dm_frac <= 0.) return

      load_mass_factor = load_mass_factor * massoftype(igas) / m_old

      !------------------------------------------------------------------
      ! Update sink masses (same fractional increment as gas)
      ! master-only; broadcast after update.
      !------------------------------------------------------------------
      if (jstart <= nptmass) then
         if (id == master) then
            do j = jstart, nptmass
               xyzmh_ptmass(4,j) = xyzmh_ptmass(4,j) * (1. + dm_frac)
            enddo
         endif
         call bcast_mpi(xyzmh_ptmass(:,1:nptmass))
      endif

      !------------------------------------------------------------------
      ! Velocity correction for momentum conservation — active SPH particles only.
      !
      ! A particle at bin b is active when istepfrac is a multiple of
      ! 2^(nbinmax-b).  When ind_timesteps is false every particle is active.
      !
      ! v_new = v + [dm_frac/(1+dm_frac)] * (v_inj - v)
      !------------------------------------------------------------------
      if (iload_vel /= 0) then
         !$omp parallel do default(none) &
         !$omp shared(npart, xyzh, vxyzu, iphase, multi_type) &
         !$omp shared(dm_frac, iload_vel, vload) &
         !$omp shared(ind_timesteps, istepfrac, nbinmax) &
         !$omp private(i, itype, vinj, istride)
         do i = 1, npart
            if (isdead_or_accreted(xyzh(4,i))) cycle
            itype = igas
            if (multi_type) itype = iamtype(iphase(i))
            if (itype /= igas .or. iamboundary(itype)) cycle
            if (ind_timesteps) then
               istride = 2**(nbinmax - int(ibin(i)))
               if (mod(istepfrac, istride) /= 0) cycle
            endif
            select case (iload_vel)
            case (1); vinj = 0.
            case (2); vinj = vload
            case default; vinj = vxyzu(1:3,i)
            end select
            vxyzu(1:3,i) = vxyzu(1:3,i) + (dm_frac / (1. + dm_frac)) * (vinj - vxyzu(1:3,i))
         enddo
         !$omp end parallel do

         ! Sink velocity correction (master-only, then broadcast)
         if (jstart <= nptmass) then
            if (id == master) then
               do j = jstart, nptmass
                  select case (iload_vel)
                  case (1); vinj = 0.
                  case (2); vinj = vload
                  case default; vinj = vxyz_ptmass(1:3,j)
                  end select
                  vxyz_ptmass(1:3,j) = vxyz_ptmass(1:3,j) + &
                       (dm_frac / (1. + dm_frac)) * (vinj - vxyz_ptmass(1:3,j))
               enddo
            endif
            call bcast_mpi(vxyz_ptmass(:,1:nptmass))
         endif
      endif

   end subroutine apply_mass_loading

   !------------------------------------------------------------
   subroutine write_options_massloading(iunit)
      use infile_utils, only: write_inopt
      integer, intent(in) :: iunit

      write(iunit,"(/,a)") '# options for mass loading'
      call write_inopt(iload_type, 'iload_type', &
         'mass loading mode: -1=off, 0=constant [M/interval], 1=fractional [frac/interval]', iunit)
      if (iload_type >= 0) then
         call write_inopt(iload_scope, 'iload_scope', &
               'particle scope: 0=gas only, 8=gas+secondary sinks (j>=2), -1=gas+all sinks', iunit)
         call write_inopt(iload_step, 'iload_step', &
               'step frequency: 0=every fine step (binstep), 1=sync point only (per dtmax)', iunit)
         call write_inopt(iload,    'iload',    'loading amount per interval (M or fraction)', iunit)
         call write_inopt(iload_dt, 'iload_dt', 'loading interval [code units]; <0 = orbital period', iunit)
         call write_inopt(iload_vel, 'iload_vel', &
               'velocity model: 0=comoving, 1=stationary, 2=wind', iunit)
         if (iload_vel == 2) then
            call write_inopt(vload(1), 'vload_x', 'wind velocity x [code units]', iunit)
            call write_inopt(vload(2), 'vload_y', 'wind velocity y [code units]', iunit)
            call write_inopt(vload(3), 'vload_z', 'wind velocity z [code units]', iunit)
         endif
      endif
   end subroutine write_options_massloading

   !------------------------------------------------------------
   subroutine read_options_massloading(db, nerr)
      use infile_utils, only: inopts, read_inopt
      type(inopts), intent(inout) :: db(:)
      integer,      intent(inout) :: nerr
      integer :: ierr_rref

      call read_inopt(iload_type, 'iload_type', db, errcount=nerr, min=-1, max=1)
      if (iload_type >= 0) then
         call read_inopt(iload_scope, 'iload_scope', db, errcount=nerr)
         call read_inopt(iload_step,  'iload_step',  db, errcount=nerr, min=0, max=1)
         call read_inopt(iload,    'iload',    db, errcount=nerr)
         call read_inopt(iload_dt, 'iload_dt', db, errcount=nerr)
         ! r_ref_load is normally set by the setup module; read from .in only as override
         ierr_rref = 0
         call read_inopt(r_ref_load, 'r_ref_load', db, min=0., err=ierr_rref)
         call read_inopt(iload_vel, 'iload_vel', db, errcount=nerr, min=0, max=2)
         if (iload_vel == 2) then
            call read_inopt(vload(1), 'vload_x', db, errcount=nerr)
            call read_inopt(vload(2), 'vload_y', db, errcount=nerr)
            call read_inopt(vload(3), 'vload_z', db, errcount=nerr)
         endif
      endif
   end subroutine read_options_massloading

   !------------------------------------------------------------
   !+
   !  Set the reference radius used for orbital-period loading (iload_dt < 0).
   !  Call from setup modules after r_ref is known, e.g.:
   !    use mass_loading, only: set_massloading_r_ref
   !    call set_massloading_r_ref(r_ref)
   !+
   !------------------------------------------------------------
   subroutine set_massloading_r_ref(r)
      real, intent(in) :: r
      if (r > 0.) r_ref_load = r
   end subroutine set_massloading_r_ref

end module mass_loading
