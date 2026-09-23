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
! :Dependencies: dump_utils, infile_utils, io, stopcond, testutils, timing
! :Owner: will-roscoe
!
 use stopcond, only: max_created_sinks, nptmass0, stopcond_triggered, &
                     stop_extra_wall, stop_extra_time, t_trip,         &
                     wall_in_window,                                   &
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
 call test_extra_window(ntests, npass)
 call test_headeropts_io(ntests, npass)
 call test_options_io(ntests, npass)
end subroutine test_stopcond

! reset module state to a known starting point
subroutine reset_stopcond()
 max_created_sinks  = -1
 nptmass0           = -1
 stopcond_triggered = .false.
 stop_extra_wall    = -1.
 stop_extra_time    = -1.
 t_trip             = -1.
 wall_in_window     = 0.
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
 call check_stopcond(1000, 0., fulldump)   ! huge sink count
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
! '>=' threshold: max_created_sinks = k stops once k new sinks exist
!---------------------------------------------------------------------------
subroutine test_threshold(ntests, npass)
 use io,        only: id, master
 use testutils, only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 integer :: nfailed(4)
 logical :: fulldump

 if (id == master) write(*,"(a)") '  --> threshold / off-by-one tests'
 nfailed(:) = 0

 ! baseline = 2, threshold k = 3 -> stop once nptmass reaches 5
 call reset_stopcond()
 nptmass0 = 2;  max_created_sinks = 3

 fulldump = .false.;  stopcond_triggered = .false.
 call check_stopcond(4, 0., fulldump)            ! created = 2 < k -> NO stop
 call checkval(stopcond_triggered, .false., nfailed(1), 'created<k: no stop')
 call checkval(fulldump,           .false., nfailed(2), 'created<k: no promotion')

 fulldump = .false.;  stopcond_triggered = .false.
 call check_stopcond(5, 0., fulldump)            ! created = 3 == k -> stop
 call checkval(stopcond_triggered, .true.,  nfailed(3), 'created==k: stop')
 call checkval(fulldump,           .true.,  nfailed(4), 'created==k: promoted to full dump')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_threshold

!---------------------------------------------------------------------------
! k = 0 is met before any sink forms; k = 1 stops on the first new sink
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
 call check_stopcond(1, 0., fulldump)            ! created = 0 == k -> stop at once
 call checkval(stopcond_triggered, .true.,  nfailed(1), 'k=0, created=0: stop')

 call reset_stopcond()
 nptmass0 = 1;  max_created_sinks = 1
 fulldump = .false.
 call check_stopcond(2, 0., fulldump)            ! the first new sink -> stop
 call checkval(stopcond_triggered, .true.,  nfailed(2), 'k=1, created=1: stop')

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
 call check_stopcond(3, 0., fulldump)
 call checkval(fulldump, .false., nfailed(1), 'below threshold: small dump unchanged')

 ! above threshold: small dump promoted to full
 fulldump = .false.
 call check_stopcond(10, 0., fulldump)
 call checkval(fulldump, .true., nfailed(2), 'above threshold: small dump promoted')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_fulldump_promotion

!---------------------------------------------------------------------------
! extra window after the condition trips: bounded by code time and wall time,
! and resumed rather than restarted after a restart inside it
!---------------------------------------------------------------------------
subroutine test_extra_window(ntests, npass)
 use dump_utils, only: dump_h, allocate_header, free_header
 use io,         only: id, master
 use testutils,  only: checkval, update_test_scores
 use timing,     only: getused
 integer, intent(inout) :: ntests, npass
 type(dump_h) :: hdr
 integer :: nfailed(9), ierr
 logical :: fulldump
 real(kind=4) :: tnow

 if (id == master) write(*,"(a)") '  --> extra-window tests'
 nfailed(:) = 0

 ! code-time ceiling of 10, condition met at t = 100
 call reset_stopcond()
 nptmass0 = 0;  max_created_sinks = 1;  stop_extra_time = 10.
 fulldump = .false.
 call check_stopcond(1, 100., fulldump)
 call checkval(stopcond_triggered, .false., nfailed(1), 'window: not stopped at trip')
 call checkval(fulldump,           .true.,  nfailed(2), 'window: trip dump is full')
 call checkval(t_trip,             100., 0., nfailed(3), 'window: t_trip recorded')
 call check_stopcond(2, 109., fulldump)
 call checkval(stopcond_triggered, .false., nfailed(4), 'window: open inside the ceiling')
 call check_stopcond(2, 110., fulldump)
 call checkval(stopcond_triggered, .true.,  nfailed(5), 'window: closes at the ceiling')

 ! restart inside the window: t_trip comes from the header, not the restart time
 call reset_stopcond()
 nptmass0 = 0;  max_created_sinks = 1;  stop_extra_time = 10.;  t_trip = 100.
 call check_stopcond(1, 105., fulldump)
 call checkval(t_trip, 100., 0., nfailed(6), 'restart: t_trip not re-set')
 call check_stopcond(1, 110., fulldump)
 call checkval(stopcond_triggered, .true., nfailed(7), 'restart: closes at the original ceiling')

 ! wall budget already spent before this job: closes on the first check
 call reset_stopcond()
 nptmass0 = 0;  max_created_sinks = 1;  stop_extra_wall = 1.;  t_trip = 100.
 wall_in_window = 3600.
 call check_stopcond(1, 101., fulldump)
 call checkval(stopcond_triggered, .true., nfailed(8), 'restart: spent wall budget closes window')

 ! restart read from a header: this job's wall time up to the first check counts
 call reset_stopcond()
 nptmass0 = 0;  max_created_sinks = 1;  stop_extra_wall = 1.e6;  t_trip = 100.
 hdr = allocate_header(nint=10,nreal=10)
 ierr = 0
 call write_headeropts_stopcond(hdr, ierr)
 call read_headeropts_stopcond(hdr)
 call free_header(hdr)
 tnow = 0.
 do while (tnow < 0.05)                 ! getused has ms resolution
    call getused(tnow)
 enddo
 call check_stopcond(1, 101., fulldump)
 call checkval(wall_in_window >= 0.05, .true., nfailed(9), 'restart: job wall time before first check counts')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_extra_window

!---------------------------------------------------------------------------
! dump-header round-trip for nptmass0; old dumps (no key) keep the default
!---------------------------------------------------------------------------
subroutine test_headeropts_io(ntests, npass)
 use dump_utils, only: dump_h, allocate_header, free_header
 use io,         only: id, master
 use testutils,  only: checkval, update_test_scores
 integer, intent(inout) :: ntests, npass
 type(dump_h) :: hdr, hdr_empty
 integer :: nfailed(5), ierr

 if (id == master) write(*,"(a)") '  --> dump-header I/O round-trip tests'
 nfailed(:) = 0

 ! write then read back
 call reset_stopcond()
 nptmass0 = 6;  t_trip = 42.;  wall_in_window = 1800.
 hdr  = allocate_header(nint=10,nreal=10)
 ierr = 0
 call write_headeropts_stopcond(hdr, ierr)
 call checkval(ierr, 0, 0, nfailed(1), 'header write: no error')

 nptmass0 = -1;  t_trip = -1.;  wall_in_window = 0.   ! clobber before reading back
 call read_headeropts_stopcond(hdr)
 call checkval(nptmass0, 6, 0, nfailed(2), 'header round-trip: nptmass0 = 6')
 call checkval(t_trip, 42., 0., nfailed(4), 'header round-trip: t_trip')
 call checkval(wall_in_window, 1800., 0., nfailed(5), 'header round-trip: wall_in_window')

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
 integer :: nfailed(5), ierr, nerr, lu
 character(len=*), parameter :: fname = 'test_stopcond_opts.tmp'

 if (id == master) write(*,"(a)") '  --> options I/O round-trip tests'
 nfailed(:) = 0

 call reset_stopcond()
 max_created_sinks = 12;  stop_extra_wall = 6.;  stop_extra_time = 250.
 open(newunit=lu, file=fname, status='replace', form='formatted')
 call write_options_stopcond(lu)
 close(lu)

 max_created_sinks = -99;  stop_extra_wall = -99.;  stop_extra_time = -99.
 nerr = 0
 call open_db_from_file(db, fname, 78, ierr)
 call checkval(ierr, 0, 0, nfailed(1), 'options: db opened from written .in file')
 call read_options_stopcond(db, nerr)
 call close_db(db)
 call checkval(max_created_sinks, 12, 0, nfailed(2), 'options: max_created_sinks round-trips')
 call checkval(nerr, 0, 0, nfailed(3), 'options: no read errors reported')
 call checkval(stop_extra_wall, 6., 0., nfailed(4), 'options: stop_extra_wall round-trips')
 call checkval(stop_extra_time, 250., 0., nfailed(5), 'options: stop_extra_time round-trips')

 ! clean up temp file
 open(newunit=lu, file=fname, status='old', form='formatted')
 close(lu, status='delete')

 call update_test_scores(ntests, nfailed, npass)
end subroutine test_options_io

end module teststopcond
