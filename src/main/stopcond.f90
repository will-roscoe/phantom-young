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
   ! Optionally the run continues for a bounded window after the condition is
   ! met, so the fragment population can be measured rather than inferred from
   ! the single dump that created the first sink.  The window is bounded by wall
   ! time first and simulated time second: the timestep collapses by two orders
   ! of magnitude as a clump forms, so a window specified only in simulated time
   ! is an unbounded cost written in units that look physical.
   !
   ! :Runtime parameters:
   !   - max_created_sinks : *stop after this many sinks form since t=0 (-1=off)*
   !   - stop_extra_wall   : *wall hours to continue after the stop condition trips (<0=off)*
   !   - stop_extra_time   : *ceiling on the extra window in code time (<0=none)*
   !
   ! :Dependencies: dump_utils, infile_utils, io, timing
   !
   implicit none
   public :: init_stopcond, check_stopcond
   public :: write_options_stopcond, read_options_stopcond
   public :: write_headeropts_stopcond, read_headeropts_stopcond
   integer,    public      ::    max_created_sinks    = -1        ! runtime parameter (.in file)
   integer,    public      ::    nptmass0             = -1        ! derived baseline sink count at t=0 (persisted in dump header
   logical,    public      ::    stopcond_triggered   = .false.   ! set when the condition trips (read by evolve.f90)
   real,       public      ::    stop_extra_wall      = -1.       ! runtime parameter: wall hours of extra window (<0=off)
   real,       public      ::    stop_extra_time      = -1.       ! runtime parameter: code-time ceiling on the window (<0=none)
   real,       public      ::    t_trip               = -1.       ! code time the condition was first met (persisted)
   real,       public      ::    wall_in_window       = 0.        ! wall seconds already spent in the window (persisted)
   real(kind=4)            ::    wall_mark            = -1.       ! getused() at the previous check; job-local, not persisted
   private

contains

   !----------------------------------------------------------------
   !+
   !  capture the t=0 sink count baseline (once), reset trigger.
   !  On restart nptmass0 has already been restored from the dump
   !  header, so it is left untouched (only captured when < 0).
   !+
   !----------------------------------------------------------------
   subroutine init_stopcond(nptmass)
      integer, intent(in) :: nptmass

      if (nptmass0 < 0) nptmass0 = nptmass
      stopcond_triggered = .false.

   end subroutine init_stopcond

   !----------------------------------------------------------------
   !+
   !  evaluate the stop condition at a dump-write point.
   !  If tripped, promote the dump to a full dump and flag the run
   !  to stop. No-op when disabled (max_created_sinks < 0) or before
   !  the baseline has been captured.
   !+
   !----------------------------------------------------------------
   subroutine check_stopcond(nptmass, time, fulldump)
      use io,           only:iprint,id,master,iverbose
      use timing,        only:getused
      integer, intent(in)    :: nptmass
      real,    intent(in)    :: time
      logical, intent(inout) :: fulldump
      real(kind=4) :: wall_now
      real         :: elapsed

      if (max_created_sinks < 0) return     ! feature off
      if (nptmass0 < 0) return              ! baseline not yet captured

      if ((nptmass - nptmass0) >= max_created_sinks) then
         fulldump = .true.

         ! Opening the window. t_trip is persisted, so on a restart inside the
         ! window this branch is skipped and the window resumes where it was.
         if (t_trip < 0.) then
            t_trip = time
            if (id==master) then
               write(iprint,"(1x,a,i0,a)") &
                  '>> STOP CONDITION REACHED: MAX CREATED SINKS (',nptmass-nptmass0,' formed)'
            endif
         endif

         ! No window configured: stop on this dump, the original behaviour.
         if (stop_extra_wall < 0. .and. stop_extra_time < 0.) then
            if (.not.stopcond_triggered .and. id==master) then
               write(iprint,"(1x,a)") &
                  '>> PROMOTING DUMP TO FULL DUMP AND FINISHING...'
            endif
            stopcond_triggered = .true.
            return
         endif

         ! getused() counts from the start of THIS job, so the mark is
         ! re-established after a restart and only the delta is accumulated.
         call getused(wall_now)
         if (wall_mark < 0.) then
            wall_mark = wall_now
         else
            wall_in_window = wall_in_window + real(wall_now - wall_mark)
            wall_mark = wall_now
         endif
         elapsed = time - t_trip

         if (stop_extra_wall >= 0. .and. wall_in_window >= stop_extra_wall*3600.) then
            if (id==master) write(iprint,"(1x,a,f8.3,a,f8.3,a)") &
               '>> EXTRA WINDOW ENDED ON WALL TIME (',wall_in_window/3600., &
               ' h of ',stop_extra_wall,' h); FINISHING...'
            stopcond_triggered = .true.
         elseif (stop_extra_time >= 0. .and. elapsed >= stop_extra_time) then
            if (id==master) write(iprint,"(1x,a,es12.4,a,es12.4,a)") &
               '>> EXTRA WINDOW ENDED ON SIMULATED TIME (',elapsed, &
               ' of ',stop_extra_time,'); FINISHING...'
            stopcond_triggered = .true.
         elseif (id==master .and. iverbose >= 1) then
            write(iprint,"(1x,a,f8.3,a,es12.4,a)") &
               '[stopcond] in extra window: ',wall_in_window/3600.,' wall-h, ', &
               elapsed,' code time'
         endif
      else
         if (iverbose > 1 .and. id==master) then 
            write(iprint,"(a)") & 
               'max created sinks > current. stop condition not met.'
         endif
      endif

   end subroutine check_stopcond

   !----------------------------------------------------------------
   !+
   !  write stop-condition options to the .in file
   !+
   !----------------------------------------------------------------
   subroutine write_options_stopcond(iunit)
      use infile_utils, only:write_inopt
      integer, intent(in) :: iunit

      call write_inopt(max_created_sinks,'max_created_sinks', &
         'stop after this many sinks form since t=0 (-1=off)',iunit)
      call write_inopt(stop_extra_wall,'stop_extra_wall', &
         'wall hours to continue after the stop condition trips (<0=off)',iunit)
      call write_inopt(stop_extra_time,'stop_extra_time', &
         'ceiling on the extra window in code time (<0=none)',iunit)
   end subroutine write_options_stopcond

   !----------------------------------------------------------------
   !+
   !  read stop-condition options from the .in file
   !+
   !----------------------------------------------------------------
   subroutine read_options_stopcond(db, nerr)
      use infile_utils, only:inopts,read_inopt
      type(inopts), intent(inout) :: db(:)
      integer,      intent(inout) :: nerr

      call read_inopt(max_created_sinks,'max_created_sinks',db,errcount=nerr,min=-1)
      ! Absent from older .in files, so both default rather than erroring: a run
      ! that predates this feature keeps its original stop-on-first-sink behaviour.
      call read_inopt(stop_extra_wall,'stop_extra_wall',db,errcount=nerr,default=-1.)
      call read_inopt(stop_extra_time,'stop_extra_time',db,errcount=nerr,default=-1.)
   end subroutine read_options_stopcond

   !----------------------------------------------------------------
   !+
   !  persist the t=0 baseline in the dump header
   !+
   !----------------------------------------------------------------
   subroutine write_headeropts_stopcond(hdr, ierr)
      use dump_utils, only:dump_h,add_to_iheader,add_to_rheader
      type(dump_h), intent(inout) :: hdr
      integer,      intent(inout) :: ierr

      call add_to_iheader(nptmass0,'nptmass0',hdr,ierr)
      ! Both are needed for a restart inside the window to resume it rather than
      ! restart it: t_trip so the elapsed simulated time is measured from the
      ! original trip, wall_in_window because getused() counts from the start of
      ! each job and would otherwise hand every link a fresh wall budget.
      call add_to_rheader(t_trip,'t_trip',hdr,ierr)
      call add_to_rheader(wall_in_window,'wall_in_window',hdr,ierr)
   end subroutine write_headeropts_stopcond

   !----------------------------------------------------------------
   !+
   !  restore the t=0 baseline from the dump header; silently keeps
   !  the module default (-1) for dumps written before this feature
   !+
   !----------------------------------------------------------------
   subroutine read_headeropts_stopcond(hdr)
      use dump_utils, only:dump_h,extract
      type(dump_h), intent(in) :: hdr
      integer :: ival,ierr
      real    :: rval

      ierr = 0
      call extract('nptmass0',ival,hdr,ierr,default=-1)
      if (ierr == 0) nptmass0 = ival

      ierr = 0
      call extract('t_trip',rval,hdr,ierr,default=-1.)
      if (ierr == 0) t_trip = rval

      ierr = 0
      call extract('wall_in_window',rval,hdr,ierr,default=0.)
      if (ierr == 0) wall_in_window = rval

      ! getused() counts from the start of this job. Restarting inside the window,
      ! all of this job's wall time belongs to it, so mark from zero; otherwise
      ! the stretch up to the first dump would be dropped on every link.
      if (t_trip >= 0.) then
         wall_mark = 0.
      else
         wall_mark = -1.
      endif
   end subroutine read_headeropts_stopcond

end module stopcond
