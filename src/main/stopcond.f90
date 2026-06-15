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
   integer,    public      ::    max_created_sinks    = -1        ! runtime parameter (.in file)
   integer,    public      ::    nptmass0             = -1        ! derived baseline sink count at t=0 (persisted in dump header
   logical,    public      ::    stopcond_triggered   = .false.   ! set when the condition trips (read by evolve.f90)
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
   subroutine check_stopcond(nptmass, fulldump)
      use io, only:iprint,id,master
      integer, intent(in)    :: nptmass
      logical, intent(inout) :: fulldump

      if (max_created_sinks < 0) return     ! feature off
      if (nptmass0 < 0) return              ! baseline not yet captured

      if ((nptmass - nptmass0) > max_created_sinks) then
         if (.not.stopcond_triggered .and. id==master) then
            write(iprint,"(1x,a,i0,a)") &
               '>> STOP CONDITION REACHED: MAX CREATED SINKS (',nptmass-nptmass0, &
               ' formed); PROMOTING DUMP TO FULL DUMP AND FINISHING...'
         endif
         fulldump = .true.
         stopcond_triggered = .true.
      else
         if (iverbose > 1 .and. id==master) then 
            write("max created sinks > current. stop condition not met.")
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
   end subroutine read_options_stopcond

   !----------------------------------------------------------------
   !+
   !  persist the t=0 baseline in the dump header
   !+
   !----------------------------------------------------------------
   subroutine write_headeropts_stopcond(hdr, ierr)
      use dump_utils, only:dump_h,add_to_iheader
      type(dump_h), intent(inout) :: hdr
      integer,      intent(inout) :: ierr

      call add_to_iheader(nptmass0,'nptmass0',hdr,ierr)
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

      ierr = 0
      call extract('nptmass0',ival,hdr,ierr,default=-1)
      if (ierr == 0) nptmass0 = ival
   end subroutine read_headeropts_stopcond

end module stopcond
