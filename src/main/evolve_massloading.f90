!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module mass_loading
!
! Uniform mass loading: increase particle masses at sync points and
! optionally adjust velocities for momentum conservation.
!
! All loaded particles receive the same fractional mass increment frac,
! which preserves the equal-mass condition within each SPH type.
!
! Absolute rate (iload_rate=0):
!   frac = mdot_load * dt / M_loaded
!   where M_loaded = sum over loaded particles of m_i
!
! Fractional rate (iload_rate=1):
!   frac = mdot_load * dt
!   mdot_load is interpreted as a fractional rate [1/t], e.g.
!   mdot_load = 0.01 gives 1% mass increase per unit time
!
! In both cases: massoftype(k) -> massoftype(k) * (1 + frac) for each
! loaded SPH type k. Sink masses are updated analogously when iload_type=2.
!
! Velocity models (iload_vel):
!   0  comoving    no velocity update (injected mass arrives at v_i)
!   1  stationary  injected mass at rest; momentum drag: Dv = -frac/(1+frac) * v
!   2  wind        injected mass at vload(3); Dv = frac/(1+frac) * (vload - v)
!
! Particle scope (iload_type):
!   0  gas only
!   1  all non-boundary SPH (gas + dust species)
!   2  all non-boundary SPH + sink particles
!
! Integration point: called from evol_prestep (evolve.f90) after
! set_active_particles, guarded to fire only at full sync points.
!
! :Owner: will-roscoe
!
! :Runtime parameters:
!   mdot_load   -- mass loading rate; M/t for iload_rate=0, 1/t for iload_rate=1
!   iload_type  -- particle scope (0=gas, 1=all SPH, 2=+sinks)
!   iload_rate  -- rate mode (0=absolute, 1=fractional)
!   iload_vel   -- velocity model (0=comoving, 1=stationary, 2=wind)
!   vload       -- injected wind velocity for iload_vel=2 [code units]
!
! :Dependencies: infile_utils, io, mpiutils, part
!
 implicit none
 public :: apply_mass_loading, write_options_massloading, read_options_massloading

 real,    public :: mdot_load  = 0.0   ! rate value; units depend on iload_rate
 integer, public :: iload_type = 0     ! particle scope
 integer, public :: iload_rate = 0     ! 0=absolute [M/t], 1=fractional [1/t]
 integer, public :: iload_vel  = 0     ! velocity model
 real,    public :: vload(3)   = 0.0   ! wind velocity for iload_vel=2

 private

contains

!------------------------------------------------------------
!+
!  True if particle type itype should receive mass loading.
!  Boundary particles are always excluded.
!+
!------------------------------------------------------------
pure logical function type_loaded(itype)
 use part, only: igas, iamboundary
 integer, intent(in) :: itype
 select case (iload_type)
 case (0)
    type_loaded = (itype == igas)
 case default  ! 1 or 2: all non-boundary SPH (sinks handled separately)
    type_loaded = .not. iamboundary(itype)
 end select
end function type_loaded

!------------------------------------------------------------
!+
!  Apply one mass-loading increment over interval dt.
!  Must be called at full sync points only (see module header).
!+
!------------------------------------------------------------
subroutine apply_mass_loading(npart, xyzh, vxyzu, iphase, dt, time)
 use part,     only: massoftype, npartoftypetot, maxtypes, &
                     isdead_or_accreted, iamtype, &
                     igas, maxphase, maxp, iamboundary, &
                     nptmass, xyzmh_ptmass, vxyz_ptmass
 use mpiutils, only: bcast_mpi
 use io,       only: iprint, id, master
 integer,         intent(in)    :: npart
 real,            intent(in)    :: xyzh(:,:)
 real,            intent(inout) :: vxyzu(:,:)
 integer(kind=1), intent(in)    :: iphase(:)
 real,            intent(in)    :: dt, time
 integer :: i, j, k, itype
 real    :: frac, M_total, M_sinks, vinj(3)
 logical :: multi_type

 if (mdot_load <= 0. .or. dt <= 0.) return

 multi_type = (maxphase == maxp)

 !------------------------------------------------------------------
 ! Compute fractional mass increment frac = dm/m_old
 !------------------------------------------------------------------
 if (iload_rate == 1) then
    frac = mdot_load * dt
 else
    ! npartoftypetot is the global live count per type (already MPI-reduced)
    M_total = 0.
    do k = 1, maxtypes
       if (type_loaded(k)) M_total = M_total + real(npartoftypetot(k)) * massoftype(k)
    enddo

    if (iload_type >= 2) then
       ! Sinks exist only on master; broadcast their total mass
       M_sinks = 0.
       if (id == master) then
          do j = 1, nptmass
             M_sinks = M_sinks + xyzmh_ptmass(4,j)
          enddo
       endif
       call bcast_mpi(M_sinks)
       M_total = M_total + M_sinks
    endif

    if (M_total <= 0.) return
    frac = mdot_load * dt / M_total
 endif

 !------------------------------------------------------------------
 ! Update massoftype for each loaded SPH type
 !------------------------------------------------------------------
 do k = 1, maxtypes
    if (type_loaded(k)) massoftype(k) = massoftype(k) * (1. + frac)
 enddo

 !------------------------------------------------------------------
 ! Update sink masses (master only, then broadcast)
 !------------------------------------------------------------------
 if (iload_type >= 2) then
    if (id == master) then
       do j = 1, nptmass
          xyzmh_ptmass(4,j) = xyzmh_ptmass(4,j) * (1. + frac)
       enddo
    endif
    call bcast_mpi(xyzmh_ptmass(:,1:nptmass))
 endif

 if (id == master) then
    write(iprint,"(1x,a,es12.4,a,es12.4)") &
         '[mass_loading] t=', time, '  dm/m=', frac
 endif

 !------------------------------------------------------------------
 ! Velocity correction for loaded SPH particles
 ! v_new = v + frac/(1+frac) * (v_inj - v)
 !------------------------------------------------------------------
 if (iload_vel /= 0) then
    !$omp parallel do default(none) &
    !$omp shared(npart, xyzh, vxyzu, iphase, multi_type) &
    !$omp shared(frac, iload_vel, vload) &
    !$omp private(i, itype, vinj)
    do i = 1, npart
       if (.not. isdead_or_accreted(xyzh(4,i))) then
          itype = igas
          if (multi_type) itype = iamtype(iphase(i))
          if (type_loaded(itype)) then
             select case (iload_vel)
             case (1)
                vinj = 0.
             case (2)
                vinj = vload
             case default
                vinj = vxyzu(1:3,i)
             end select
             vxyzu(1:3,i) = vxyzu(1:3,i) + (frac / (1. + frac)) * (vinj - vxyzu(1:3,i))
          endif
       endif
    enddo
    !$omp end parallel do

    ! Velocity correction for sinks
    if (iload_type >= 2) then
       if (id == master) then
          do j = 1, nptmass
             select case (iload_vel)
             case (1)
                vinj = 0.
             case (2)
                vinj = vload
             case default
                vinj = vxyz_ptmass(1:3,j)
             end select
             vxyz_ptmass(1:3,j) = vxyz_ptmass(1:3,j) + (frac / (1. + frac)) * (vinj - vxyz_ptmass(1:3,j))
          enddo
       endif
       call bcast_mpi(vxyz_ptmass(:,1:nptmass))
    endif
 endif

end subroutine apply_mass_loading

!------------------------------------------------------------
!+
!  Write runtime options to .in file
!+
!------------------------------------------------------------
subroutine write_options_massloading(iunit)
 use infile_utils, only: write_inopt
 integer, intent(in) :: iunit

 write(iunit,"(/,a)") '# options for mass loading'
 call write_inopt(mdot_load, 'mdot_load', &
      'mass loading rate [M/t if iload_rate=0, 1/t if iload_rate=1]; 0 = disabled', iunit)
 call write_inopt(iload_type, 'iload_type', &
      'particle scope: 0=gas only, 1=all non-boundary SPH, 2=+sinks', iunit)
 call write_inopt(iload_rate, 'iload_rate', &
      'rate mode: 0=absolute [M/t], 1=fractional [1/t]', iunit)
 call write_inopt(iload_vel, 'iload_vel', &
      'velocity model: 0=comoving, 1=stationary background, 2=wind', iunit)
 if (iload_vel == 2) then
    call write_inopt(vload(1), 'vload_x', 'injected wind velocity x [code units]', iunit)
    call write_inopt(vload(2), 'vload_y', 'injected wind velocity y [code units]', iunit)
    call write_inopt(vload(3), 'vload_z', 'injected wind velocity z [code units]', iunit)
 endif

end subroutine write_options_massloading

!------------------------------------------------------------
!+
!  Read runtime options from .in file
!+
!------------------------------------------------------------
subroutine read_options_massloading(db, nerr)
 use infile_utils, only: inopts, read_inopt
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr

 call read_inopt(mdot_load,  'mdot_load',  db, errcount=nerr, min=0.)
 call read_inopt(iload_type, 'iload_type', db, errcount=nerr, min=0, max=2)
 call read_inopt(iload_rate, 'iload_rate', db, errcount=nerr, min=0, max=1)
 call read_inopt(iload_vel,  'iload_vel',  db, errcount=nerr, min=0, max=2)
 if (iload_vel == 2) then
    call read_inopt(vload(1), 'vload_x', db, errcount=nerr)
    call read_inopt(vload(2), 'vload_y', db, errcount=nerr)
    call read_inopt(vload(3), 'vload_z', db, errcount=nerr)
 endif

end subroutine read_options_massloading

end module mass_loading
