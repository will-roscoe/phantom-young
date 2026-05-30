!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module mass_loading
!
! Comoving mass loading of gas particles.
!
! Three loading modes selected by iload_factor:
!   -1 : off
!    0 : constant chi — disc mass increases by chi * M_disc0 per interval T
!    1 : constant xi  — disc mass increases by xi per interval T (absolute)
!    2 : exponential beta — disc mass scales by (1+beta) per interval T
!
! For modes 0 and 1, both dm_load (xi) and mloadfactor (chi) are always set:
!   mode 0: mloadfactor = iload (user chi),  dm_load = iload * M_disc0
!   mode 1: dm_load     = iload (user xi),   mloadfactor = iload / M_disc0
!   mode 2: mloadfactor = iload (user beta), dm_load = 0.
!
! .in parameters (3 only): iload_factor, iload, iload_dt
! Dump header:              dm_load, r_orb (restart safety)
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
           write_options_massloading, read_options_massloading,   &
           write_options_massloading_setup,                       &
           read_options_massloading_setup,                        &
           write_headeropts_massloading,                          &
           read_headeropts_massloading,                           &
           set_massloading_r_ref

 ! .in parameters
 integer, public :: iload_factor =  -1   ! -1=off, 0=chi, 1=xi, 2=beta
 real,    public :: iload        =   0.  ! chi / xi / beta
 real,    public :: iload_dt     =  -1.  ! interval; <=0 -> compute T_orb

 ! derived quantities (always set for modes 0 and 1)
 real, public :: mloadfactor  = 0.   ! chi (modes 0/1) or beta (mode 2)
 real, public :: dm_load      = 0.   ! xi  (modes 0/1); 0 for mode 2
 real, public :: r_orb        = 1.   ! reference radius for T_orb
 real, public :: t_orb        = 0.   ! current effective interval

 ! private state - set once at init
 integer(kind=8), private :: n_p0       = 0
 real,            private :: m_p0       = 0.
 integer,         private :: id_mstar   = 1
 logical,         private :: calc_torb  = .false.
 logical,         private :: initialised = .false.

 private

contains

subroutine init_massloading()
 use part, only: massoftype, npartoftypetot
 use io,   only: iprint, id, master
 real :: m_disc0

 n_p0 = npartoftypetot(igas)
 if (n_p0 <= 0) return
 m_p0    = massoftype(igas)
 m_disc0 = m_p0 * real(n_p0)

 ! restart path: dm_load already set from dump header — back-derive mloadfactor
 if (dm_load > 0.) then
    if (iload_factor == 0 .or. iload_factor == 1) then
       ! back-derive chi for display only; m_disc0 here is evolved not initial
       if (m_disc0 > 0.) mloadfactor = dm_load / m_disc0
    endif
    calc_torb   = (iload_dt <= 0.)
    initialised = .true.
    if (id == master) &
       write(iprint,"(1x,a,i0,a,es12.4,a,es12.4)") &
          '[mass_loading] restart: type=', iload_factor, &
          '  dm_load=', dm_load, '  r_orb=', r_orb
    return
 endif

 select case(iload_factor)
 case(0)   ! chi mode: user gives chi, derive xi
    mloadfactor = iload
    dm_load     = iload * m_disc0
 case(1)   ! xi mode: user gives xi, back-derive chi
    dm_load     = iload
    if (m_disc0 > 0.) mloadfactor = iload / m_disc0
 case(2)   ! beta mode: no xi equivalent
    mloadfactor = iload
    dm_load     = 0.
 case default  ! -1 or any invalid value: loading off
    initialised = .true.
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
end subroutine init_massloading

subroutine calc_massloading_rate(t, dtmax)
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
end subroutine calc_massloading_rate

subroutine apply_mass_loading(dt, time)
 use part, only: massoftype
 use io,   only: iprint, id, master, iverbose
 real, intent(in) :: dt, time
 real :: m_old, dm_p

 if (t_orb <= 0. .or. dt <= 0.) return

 m_old = massoftype(igas)

 select case(iload_factor)
 case(0, 1)   ! constant: increment massoftype by dm_load * dt / (T * n_p0)
    if (dm_load <= 0. .or. n_p0 <= 0) return
    dm_p             = dm_load * dt / (t_orb * real(n_p0))
    massoftype(igas) = m_old + dm_p
 case(2)      ! exponential: scale massoftype by exp(ln(1+beta) * dt/T)
    if (mloadfactor <= 0.) return
    massoftype(igas) = m_old * exp(log(1. + mloadfactor) * dt / t_orb)
 case default
    return
 end select

 if (id == master .and. iverbose >= 2) &
    write(iprint,"(1x,a,es12.4,a,es12.4,a,es12.4)") &
       '[mass_loading] t=', time, &
       '  dm/m=', (massoftype(igas) - m_old) / m_old, &
       '  m_gas=', massoftype(igas)
end subroutine apply_mass_loading

subroutine step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)
 use dim, only: ind_timesteps
 real,            intent(in) :: time, dt, dtmax
 integer,         intent(in) :: istepfrac
 integer(kind=1), intent(in) :: nbinmax

 if (.not. initialised) call init_massloading()
 if (iload_factor < 0) return
 if (iload_factor /= 2 .and. dm_load <= 0.) return
 if (iload_factor == 2 .and. mloadfactor <= 0.) return

 if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) &
    call calc_massloading_rate(time, dtmax)

 call apply_mass_loading(dt, time)
end subroutine step_mass_loading

subroutine write_options_massloading(iunit)
 integer, intent(in) :: iunit
end subroutine write_options_massloading

subroutine read_options_massloading(db, nerr)
 use infile_utils, only: inopts
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr
end subroutine read_options_massloading

subroutine write_options_massloading_setup(iunit)
 integer, intent(in) :: iunit
end subroutine write_options_massloading_setup

subroutine read_options_massloading_setup(db, nerr)
 use infile_utils, only: inopts
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr
end subroutine read_options_massloading_setup

subroutine write_headeropts_massloading(hdr, ierr)
 use dump_utils, only: dump_h
 type(dump_h), intent(inout) :: hdr
 integer,      intent(inout) :: ierr
end subroutine write_headeropts_massloading

subroutine read_headeropts_massloading(hdr)
 use dump_utils, only: dump_h
 type(dump_h), intent(in) :: hdr
end subroutine read_headeropts_massloading

subroutine set_massloading_r_ref(r)
 real, intent(in) :: r
end subroutine set_massloading_r_ref

end module mass_loading
