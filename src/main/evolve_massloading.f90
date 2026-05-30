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
end subroutine init_massloading

subroutine step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)
 real,            intent(in) :: time, dt, dtmax
 integer,         intent(in) :: istepfrac
 integer(kind=1), intent(in) :: nbinmax
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
