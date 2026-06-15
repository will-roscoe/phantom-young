!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module teststopcond
!
! Unit tests for the stopcond module (stopcond.f90).
!
! :Dependencies: dump_utils, infile_utils, io, stopcond, testutils
! :Owner: will-roscoe
!
 use stopcond, only: max_created_sinks, nptmass0, stopcond_triggered, &
                     init_stopcond, check_stopcond,                   &
                     write_options_stopcond, read_options_stopcond,   &
                     write_headeropts_stopcond, read_headeropts_stopcond
 implicit none
 public :: test_stopcond
 private

contains

subroutine test_stopcond(ntests, npass)
 use io, only: id, master
 integer, intent(inout) :: ntests, npass
 if (id == master) write(*,"(/,a,/)") '--> TESTING STOP CONDITION MODULE'
 call test_disabled_default(ntests, npass)
 call test_baseline_capture(ntests, npass)
 call test_threshold(ntests, npass)
 call test_zero_threshold(ntests, npass)
 call test_fulldump_promotion(ntests, npass)
 call test_headeropts_io(ntests, npass)
 call test_options_io(ntests, npass)
end subroutine test_stopcond

! reset module state to a known starting point
subroutine reset_stopcond()
 max_created_sinks  = -1
 nptmass0           = -1
 stopcond_triggered = .false.
end subroutine reset_stopcond

!---------------------------------------------------------------------------
! disabled by default (max_created_sinks = -1): never triggers
!---------------------------------------------------------------------------
subroutine test_disabled_default(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(2)
 logical :: fulldump

 if (id == master) write(*,"(a)") '  --> disabled-by-default tests'
 nfailed(:) = 0

 call reset_stopcond()
 nptmass0 = 1                 ! baseline captured, but feature off
 fulldump = .false.
 call check_stopcond(1000, fulldump)   ! huge sink count
 call checkval(fulldump,           .false., nfailed(1), 'off: fulldump not promoted')
 call checkval(stopcond_triggered, .false., nfailed(2), 'off: not triggered')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_disabled_default

!---------------------------------------------------------------------------
! init captures baseline once; does not overwrite a restored baseline
!---------------------------------------------------------------------------
subroutine test_baseline_capture(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(3)

 if (id == master) write(*,"(a)") '  --> baseline capture tests'
 nfailed(:) = 0

 ! fresh run: baseline unset (-1) -> captured from current nptmass
 call reset_stopcond()
 call init_stopcond(4)
 call checkval(nptmass0, 4, 0, nfailed(1), 'fresh: baseline captured = 4')

 ! restart: baseline already restored from header -> NOT overwritten
 call reset_stopcond()
 nptmass0 = 7                 ! simulate value restored from dump header
 call init_stopcond(99)       ! current count differs
 call checkval(nptmass0, 7, 0, nfailed(2), 'restart: baseline preserved = 7')

 ! init always clears the trigger flag
 stopcond_triggered = .true.
 call init_stopcond(7)
 call checkval(stopcond_triggered, .false., nfailed(3), 'init clears trigger flag')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_baseline_capture

!---------------------------------------------------------------------------
! strict '>' threshold and off-by-one
!---------------------------------------------------------------------------
subroutine test_threshold(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(4)
 logical :: fulldump

 if (id == master) write(*,"(a)") '  --> threshold / off-by-one tests'
 nfailed(:) = 0

 ! baseline = 2, threshold k = 3 -> stop when nptmass > 5
 call reset_stopcond()
 nptmass0 = 2;  max_created_sinks = 3

 fulldump = .false.;  stopcond_triggered = .false.
 call check_stopcond(5, fulldump)            ! created = 3 == k -> NO stop
 call checkval(stopcond_triggered, .false., nfailed(1), 'created==k: no stop')
 call checkval(fulldump,           .false., nfailed(2), 'created==k: no promotion')

 fulldump = .false.;  stopcond_triggered = .false.
 call check_stopcond(6, fulldump)            ! created = 4 > k -> stop
 call checkval(stopcond_triggered, .true.,  nfailed(3), 'created>k: stop')
 call checkval(fulldump,           .true.,  nfailed(4), 'created>k: promoted to full dump')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_threshold

!---------------------------------------------------------------------------
! max_created_sinks = 0 -> stop as soon as the first new sink forms
!---------------------------------------------------------------------------
subroutine test_zero_threshold(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(2)
 logical :: fulldump

 if (id == master) write(*,"(a)") '  --> zero-threshold tests'
 nfailed(:) = 0

 call reset_stopcond()
 nptmass0 = 1;  max_created_sinks = 0

 fulldump = .false.;  stopcond_triggered = .false.
 call check_stopcond(1, fulldump)            ! created = 0 -> NO stop
 call checkval(stopcond_triggered, .false., nfailed(1), 'k=0, created=0: no stop')

 fulldump = .false.;  stopcond_triggered = .false.
 call check_stopcond(2, fulldump)            ! created = 1 > 0 -> stop
 call checkval(stopcond_triggered, .true.,  nfailed(2), 'k=0, created=1: stop')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_zero_threshold

!---------------------------------------------------------------------------
! a small dump (fulldump=.false.) is promoted on trigger, left alone otherwise
!---------------------------------------------------------------------------
subroutine test_fulldump_promotion(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(2)
 logical :: fulldump

 if (id == master) write(*,"(a)") '  --> full-dump promotion tests'
 nfailed(:) = 0

 ! below threshold: a small dump stays a small dump
 call reset_stopcond()
 nptmass0 = 0;  max_created_sinks = 5
 fulldump = .false.
 call check_stopcond(3, fulldump)
 call checkval(fulldump, .false., nfailed(1), 'below threshold: small dump unchanged')

 ! above threshold: small dump promoted to full
 fulldump = .false.
 call check_stopcond(10, fulldump)
 call checkval(fulldump, .true., nfailed(2), 'above threshold: small dump promoted')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_fulldump_promotion

!---------------------------------------------------------------------------
! dump-header round-trip for nptmass0; old dumps (no key) keep the default
!---------------------------------------------------------------------------
subroutine test_headeropts_io(ntests, npass)
 use dump_utils, only: dump_h, allocate_header, free_header
 use io,         only: id, master
 use testutils,  only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 type(dump_h) :: hdr, hdr_empty
 integer :: nfailed(3), ierr

 if (id == master) write(*,"(a)") '  --> dump-header I/O round-trip tests'
 nfailed(:) = 0

 ! write then read back
 call reset_stopcond()
 nptmass0 = 6
 hdr  = allocate_header(nint=10)
 ierr = 0
 call write_headeropts_stopcond(hdr, ierr)
 call checkval(ierr, 0, 0, nfailed(1), 'header write: no error')

 nptmass0 = -1                       ! clobber before reading back
 call read_headeropts_stopcond(hdr)
 call checkval(nptmass0, 6, 0, nfailed(2), 'header round-trip: nptmass0 = 6')

 ! header lacking the key (old dump): nptmass0 left at its default sentinel
 hdr_empty = allocate_header(nint=10)
 nptmass0  = -1
 call read_headeropts_stopcond(hdr_empty)
 call checkval(nptmass0, -1, 0, nfailed(3), 'header missing key: nptmass0 stays -1')

 call free_header(hdr)
 call free_header(hdr_empty)
 call update_test_scores(ntests, nfailed, npass)
end subroutine test_headeropts_io

!---------------------------------------------------------------------------
! .in-file options round-trip for max_created_sinks
!---------------------------------------------------------------------------
subroutine test_options_io(ntests, npass)
 use infile_utils, only: inopts, open_db_from_file, close_db
 use io,           only: id, master
 use testutils,    only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 type(inopts), allocatable :: db(:)
 integer :: nfailed(3), ierr, nerr, lu
 character(len=*), parameter :: fname = 'test_stopcond_opts.tmp'

 if (id == master) write(*,"(a)") '  --> options I/O round-trip tests'
 nfailed(:) = 0

 call reset_stopcond()
 max_created_sinks = 12
 open(newunit=lu, file=fname, status='replace', form='formatted')
 call write_options_stopcond(lu)
 close(lu)

 max_created_sinks = -99             ! clobber before reading back
 nerr = 0
 call open_db_from_file(db, fname, 78, ierr)
 call checkval(ierr, 0, 0, nfailed(1), 'options: db opened from written .in file')
 call read_options_stopcond(db, nerr)
 call close_db(db)
 call checkval(max_created_sinks, 12, 0, nfailed(2), 'options: max_created_sinks round-trips')
 call checkval(nerr, 0, 0, nfailed(3), 'options: no read errors reported')

 ! clean up temp file
 open(newunit=lu, file=fname, status='old', form='formatted')
 close(lu, status='delete')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_options_io

end module teststopcond
