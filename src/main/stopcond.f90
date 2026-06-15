!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module stopcond
!
! Run stop condition: stop the simulation once more than max_created_sinks
! new sink particles have formed since t=0. On the dump that trips the
! condition the dump is promoted to a full dump and the run exits cleanly.
!
! :References: None
!
! :Owner: will-roscoe
!
! :Runtime parameters:
!   - max_created_sinks : *stop after this many sinks form since t=0 (-1=off)*
!
! :Dependencies: dump_utils, infile_utils, io
!
 implicit none

 public :: init_stopcond, check_stopcond
 public :: write_options_stopcond, read_options_stopcond
 public :: write_headeropts_stopcond, read_headeropts_stopcond

 ! runtime parameter (.in file)
 integer, public :: max_created_sinks = -1
 ! derived baseline sink count at t=0 (persisted in dump header)
 integer, public :: nptmass0 = -1
 ! set when the condition trips (read by evolve.f90)
 logical, public :: stopcond_triggered = .false.

 private

contains

subroutine init_stopcond(nptmass)
 integer, intent(in) :: nptmass
 ! STUB
end subroutine init_stopcond

subroutine check_stopcond(nptmass, fulldump)
 integer, intent(in)    :: nptmass
 logical, intent(inout) :: fulldump
 ! STUB
end subroutine check_stopcond

subroutine write_options_stopcond(iunit)
 integer, intent(in) :: iunit
 ! STUB
end subroutine write_options_stopcond

subroutine read_options_stopcond(db, nerr)
 use infile_utils, only:inopts
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr
 ! STUB
end subroutine read_options_stopcond

subroutine write_headeropts_stopcond(hdr, ierr)
 use dump_utils, only:dump_h
 type(dump_h), intent(inout) :: hdr
 integer,      intent(inout) :: ierr
 ! STUB
end subroutine write_headeropts_stopcond

subroutine read_headeropts_stopcond(hdr)
 use dump_utils, only:dump_h
 type(dump_h), intent(in) :: hdr
 ! STUB
end subroutine read_headeropts_stopcond

end module stopcond
