!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module fld_options
!
! Start-up checks on the flux-limited diffusion options of the Forgan et
! al. (2009) hybrid (icooling = 9): do FLD = 1 (explicit) and RADIATION=yes
! with the radiation module's gas coupling on are refused unless the
! environment variable I_WILL_NOT_PUBLISH_CRAP is true, when they warn
!
! :References: Forgan et al. (2009), MNRAS 394, 882
!
! :Owner: Will Roscoe
!
! :Runtime parameters: None
!
! :Dependencies: dim, eos_stamatellos, io, radiation_utils
!
 implicit none
 integer, parameter, public :: ierr_fld_warn = 1, ierr_fld_fatal = 2
 character(len=*), parameter, public :: fld_bypass_env = 'I_WILL_NOT_PUBLISH_CRAP'
 public :: env_is_true,check_fld_options,check_fld_at_startup

 private

contains

!-----------------------------------------------------------------------
!+
!  true for 1, true, yes or on (any case, surrounding blanks ignored)
!+
!-----------------------------------------------------------------------
logical function env_is_true(value)
 character(len=*), intent(in) :: value
 character(len=len(value)) :: v
 integer :: i

 v = adjustl(value)
 do i=1,len(v)
    if (v(i:i) >= 'A' .and. v(i:i) <= 'Z') v(i:i) = achar(iachar(v(i:i)) + 32)
 enddo
 select case(trim(v))
 case('1','true','yes','on')
    env_is_true = .true.
 case default
    env_is_true = .false.
 end select

end function env_is_true

!-----------------------------------------------------------------------
!+
!  checks on the FLD options; ierr 0 fine, ierr_fld_warn, ierr_fld_fatal.
!  bypass (the environment variable is true) turns fatal into warn
!+
!-----------------------------------------------------------------------
subroutine check_fld_options(mode,radiation_on,exchange_on,implicit_on,bypass,ierr,msg)
 integer,          intent(in)  :: mode
 logical,          intent(in)  :: radiation_on,exchange_on,implicit_on,bypass
 integer,          intent(out) :: ierr
 character(len=*), intent(out) :: msg

 ierr = 0
 msg  = ''
 if (mode == 1) then
    msg = 'do FLD = 1 (explicit) overshoots where dt exceeds the diffusion time; use do FLD = 2 (implicit),'// &
          ' or set '//fld_bypass_env//'=1 to run it anyway'
    ierr = ierr_fld_fatal
 elseif (radiation_on .and. (exchange_on .or. implicit_on)) then
    msg = 'RADIATION=yes with icooling = 9: set gas-rad_exchange = F and implicit_radiation = F'// &
          ' (the radiation module would act on the gas as well), or set '//fld_bypass_env//'=1'
    ierr = ierr_fld_fatal
 endif
 if (ierr == ierr_fld_fatal .and. bypass) ierr = ierr_fld_warn

end subroutine check_fld_options

!-----------------------------------------------------------------------
!+
!  apply check_fld_options to the options read from the .in file:
!  calls fatal (stops the run) or warning. Call after the radiation
!  options have been read
!+
!-----------------------------------------------------------------------
subroutine check_fld_at_startup()
 use dim,             only:do_radiation
 use eos_stamatellos, only:fld_mode
 use io,              only:fatal,warning
 use radiation_utils, only:exchange_radiation_energy,implicit_radiation
 character(len=64)  :: envval
 character(len=200) :: msg
 integer :: ierr,istat

 call get_environment_variable(fld_bypass_env,envval,status=istat)
 if (istat /= 0) envval = ''
 call check_fld_options(fld_mode,do_radiation,exchange_radiation_energy,implicit_radiation, &
                        env_is_true(envval),ierr,msg)
 if (ierr == ierr_fld_fatal) call fatal('read_infile',trim(msg))
 if (ierr == ierr_fld_warn)  call warning('read_infile',trim(msg))

end subroutine check_fld_at_startup

end module fld_options
