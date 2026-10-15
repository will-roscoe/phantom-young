!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module test_eos_stam
!
! Unit tests of the Stamatellos/Lombardi equation of state
!
! :References: None
!
! :Owner: Daniel Price
!
! :Runtime parameters: None
!
! :Dependencies: eos, eos_stamatellos, physcon, testutils, units
!

 use testutils,     only:checkval,update_test_scores,checkvalbuf,checkvalbuf_end,checkvalbuf_start
 use eos_stamatellos, only:read_optab,getintenerg_opdep,getopac_opdep,eos_file
 use eos_stamatellos, only:optable
 implicit none
 public :: run_test_stam

 integer, parameter :: nrho = 100, nT = 100

 private

contains

subroutine run_test_stam(ntests,npass)
 integer, intent(inout) :: ntests,npass
 integer :: ierr,nfail(2)
 logical :: got_phantom_dir
 character(len=20) :: pdir

 call test_planck_column(ntests,npass)

 call get_environment_variable('PHANTOM_DIR',pdir)
 got_phantom_dir = (len_trim(pdir) > 0)
 if (.not. got_phantom_dir) return
 call read_optab(eos_file,ierr)
 nfail(:) = 0
 if (ierr  /=  0) then
    nfail(1) = 1
 else
    call test_interp_optab(nfail(1),npass)
 endif
 ntests = ntests + 1
 call update_test_scores(ntests,nfail(:),npass)
 call finish_test_stam
end subroutine run_test_stam

subroutine test_interp_optab(nfail,npass)
 use units,  only:unit_density,unit_ergg,unit_velocity
 use eos, only:equationofstate
 use physcon, only:kb_on_mh
 integer, intent(out) :: nfail,npass
 real :: logrhomin,logrhomax,logtmin,logtmax,tol,errmax
 real :: dlogtemp,dlogrho,rhoi,Ti,ui,Tref,spsoundi
 integer  :: irho,itemp,ndiff,ncheck
 real :: ponrhoi,xi,yi,zi,spsoundrefi,gammai
 real :: kappaBar,kappaPart,mui
 real :: rhoi_cgs, ui_cgs
 character(len=30) :: label
 label = 'eos_stamatellos interpolation'
 xi = 0.; yi = 0.; zi = 0. !These aren't used but needed for eos call
 ndiff = 0; ncheck = 0; nfail = 0
 tol = 0.001 !tolerance
 call checkvalbuf_start(label)
 ! create temperature array and rho array
 !1e-24 to 1 g cm^-3
 logtmin = log10(4.); logtmax = 4. !K to 10^4 K
 logrhomax = -0.045; logrhomin = -24.
 dlogtemp = (logtmax-logtmin)/nT
 dlogrho = (logrhomax - logrhomin)/nrho
 do irho=1,nrho
    rhoi = 10.**(logrhomin+(irho*dlogrho))
    do itemp=1,nT
       Ti = 10**(logtmin+(itemp*dlogtemp))
       !print *, irho,itemp, rhoi, Ti
       call getintenerg_opdep(Ti,rhoi,ui)
       Tref = Ti
       rhoi_cgs = rhoi/real(unit_density) ! to prevent compiler errors in equationofstate
       ui_cgs = ui/real(unit_ergg)
       call equationofstate(24,ponrhoi,spsoundi,rhoi_cgs,xi,yi,zi,Ti,ui_cgs) !this calls getopac...
       call getopac_opdep(ui,rhoi,kappaBar,kappaPart,Ti,mui)
       gammai = 1. + (ponrhoi/(ui/unit_ergg))
       spsoundrefi = sqrt(gammai*kb_on_mh*Tref/mui)
       spsoundi = spsoundi * unit_velocity
       call checkvalbuf(spsoundi,spsoundrefi,tol,label,ndiff,ncheck,errmax,use_rel_tol=.true.)
    enddo
 enddo
 call checkvalbuf_end(label,ncheck,ndiff,errmax,tol)
 if (ndiff >0) then
    nfail = nfail + 1
 else
    npass = npass + 1
 endif
end subroutine test_interp_optab

!
! a 7-column table gives the Planck mean through kappaPl; a 6-column table
! falls back to the Rosseland mean, so older tables still load
!
subroutine test_planck_column(ntests,npass)
 integer, intent(inout) :: ntests,npass
 integer :: nfail(5),ierr,iunit
 real :: kappaBar,kappaPart,kappaPl,Ti,mui
 character(len=*), parameter :: f7 = 'test_optab7.tmp', f6 = 'test_optab6.tmp'

 nfail(:) = 0
 call write_table(f7,.true.)
 call finish_test_stam
 call read_optab(f7,ierr)
 call checkval(ierr,0,0,nfail(1),'7-column table reads')
 call getopac_opdep(1.5e10,5.e-10,kappaBar,kappaPart,Ti,mui,kappaPl=kappaPl)
 call checkval(kappaPart,2.,1.e-6,nfail(2),'Rosseland from column 6')
 call checkval(kappaPl,4.,1.e-6,nfail(3),'Planck from column 7')

 call write_table(f6,.false.)
 call finish_test_stam
 call read_optab(f6,ierr)
 call checkval(ierr,0,0,nfail(4),'6-column table reads')
 call getopac_opdep(1.5e10,5.e-10,kappaBar,kappaPart,Ti,mui,kappaPl=kappaPl)
 call checkval(kappaPl,kappaPart,1.e-6,nfail(5),'6-column Planck falls back to Rosseland')
 call finish_test_stam
 open(newunit=iunit,file=f7)
 close(iunit,status='delete')
 open(newunit=iunit,file=f6)
 close(iunit,status='delete')

 call update_test_scores(ntests,nfail,npass)

end subroutine test_planck_column

subroutine write_table(filename,planck)
 character(len=*), intent(in) :: filename
 logical, intent(in) :: planck
 integer :: iunit,i
 real :: rho(2)

 rho = (/1.e-10,1.e-9/)
 open(newunit=iunit,file=filename,status='replace',form='formatted')
 write(iunit,'(a)') ' :: synthetic table for test_planck_column'
 write(iunit,'(a)') ' 2 2'
 do i=1,2
    if (planck) then
       write(iunit,*) rho(i),10.,1.e10,2.3,1.,1.,2.
       write(iunit,*) rho(i),20.,2.e10,2.3,2.,3.,6.
    else
       write(iunit,*) rho(i),10.,1.e10,2.3,1.,1.
       write(iunit,*) rho(i),20.,2.e10,2.3,2.,3.
    endif
 enddo
 close(iunit,status='keep')

end subroutine write_table

subroutine finish_test_stam
 if (allocated(optable)) deallocate(optable)
end subroutine finish_test_stam

end module test_eos_stam
