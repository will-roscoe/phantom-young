!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module testpart
!
! Unit tests of the part module, checking basic functionality
!
! :References: None
!
! :Owner: Daniel Price
!
! :Runtime parameters: None
!
! :Dependencies: boundary, eos_stamatellos, io, kernel, mpidomain, part,
!   physcon, testutils, unifdis
!
 use testutils, only:update_test_scores,checkval
 implicit none

 public :: test_part

 private

contains
!----------------------------------------------------------
!+
!  unit tests of equation of state module
!+
!----------------------------------------------------------
subroutine test_part(ntests,npass)
 use io,        only:id,master,stdout
 integer, intent(inout) :: ntests,npass

 if (id==master) write(*,"(/,a,/)") '--> TESTING PART MODULE'

 call test_accrete_and_kill_routines(ntests, npass)
 call test_shuffle_moves_coolra_stores(ntests, npass)

 if (id==master) write(*,"(/,a)") '<-- PART MODULE TEST COMPLETE'

end subroutine test_part

!----------------------------------------------------------
!+
!  test that the initialisation of all eos works correctly
!+
!----------------------------------------------------------
subroutine test_accrete_and_kill_routines(ntests, npass)
 use io,        only:id,master
 use part,      only:xyzh,npartoftype,npart,periodic,init_part,shuffle_part,&
                     igas,isetphase,iphase,maxphase,maxp
 use part,      only:kill_particle,count_dead_particles,isdead_or_accreted, &
                     accrete_particles_outside_sphere,delete_dead_or_accreted_particles
 use boundary,  only:dxbound,dybound,dzbound,xmin,xmax,ymin,ymax,zmin,zmax
 use mpidomain, only:i_belong
 use kernel,    only:hfact_default
 use unifdis,   only:set_unifdis
 use physcon,   only:pi
 integer, intent(inout) :: ntests,npass
 integer :: nfailed(1)
 integer :: i,nkilled,ncount,npartold,nacc,nacc_check
 real :: rhozero,psep,totmass

 if (id==master) write(*,"(/,a)") '--> testing kill_particle and associated routines'

 !
 !--set up particles in a uniform distribution
 !
 call init_part()
 npartoftype(:) = 0
 npart = 0
 rhozero = 1.
 totmass = rhozero*dxbound*dybound*dzbound
 psep = dxbound/100.
 call set_unifdis('cubic',id,master,xmin,xmax,ymin,ymax,zmin,zmax,psep,&
                  hfact_default,npart,xyzh,periodic,mask=i_belong)
 nfailed = 0
 npartoftype(1) = npart
 if (maxphase==maxp) iphase(1:npart) = isetphase(igas,.true.)
 !
 ! accrete particles outside r=1
 !
 nacc = 0
 call accrete_particles_outside_sphere(xmax)
 do i=1,npart
    if (isdead_or_accreted(xyzh(4,i))) nacc = nacc + 1
 enddo
 !
 ! check number of accreted particles is approximately correct
 !
 nacc_check = int((1. - pi/6.)*npart)  ! ratio of volumes: [ (2 r)^3 - 4/3*pi*r^3 ] / (2r)^3
 call checkval(nacc,nacc_check,400,nfailed(1),'accrete_particles_outside_sphere')
 call update_test_scores(ntests,nfailed,npass)
 !
 ! kill every 10th particle, except those already accreted
 !
 nkilled = 0
 do i=1,npart
    if (mod(i,10)==0 .and. .not.isdead_or_accreted(xyzh(4,i))) then
       call kill_particle(i,npartoftype)
       nkilled = nkilled + 1
    endif
 enddo
 !
 ! check that the number killed matches the actual
 !
 ncount  = count_dead_particles()
 call checkval(ncount,nkilled,0,nfailed(1),'count_dead_particles matches n killed')
 call update_test_scores(ntests,nfailed,npass)
 !
 ! call shuffle_part and check revised particle number is correct
 !
 npartold = npart
 call shuffle_part(npart)
 call checkval(npart,npartold-nkilled,0,nfailed(1),'npart after call to shuffle_part')
 call update_test_scores(ntests,nfailed,npass)
 !
 ! check delete_dead_or_accreted_particles works
 !
 npartold = npart
 call delete_dead_or_accreted_particles(npart,npartoftype)
 call checkval(npart,npartold-nacc,0,nfailed(1),'delete_dead_or_accreted has right n')
 call update_test_scores(ntests,nfailed,npass)
 !
 ! check sum(npartoftype) = npart
 !
 call checkval(sum(npartoftype),npart,0,nfailed(1),'npart = sum(npartoftype)')
 call update_test_scores(ntests,nfailed,npass)

end subroutine test_accrete_and_kill_routines

!----------------------------------------------------------
!+
!  test that shuffle_part carries the per-particle stores of the
!  Stamatellos/Forgan cooling (eos_stamatellos) with the particle
!+
!----------------------------------------------------------
subroutine test_shuffle_moves_coolra_stores(ntests, npass)
 use io,              only:id,master
 use part,            only:xyzh,npartoftype,npart,init_part,shuffle_part,kill_particle,&
                           igas,isetphase,iphase,maxphase,maxp
 use eos_stamatellos, only:init_coolra,finish_coolra,ttherm_store,ueqi_store,tau_store,&
                           du_store,duSPH,Gpot_cool,duFLD,lambda_FLD,urad_FLD,gradP_cool
 integer, intent(inout) :: ntests,npass
 integer, parameter :: n = 10, ikill = 3
 integer :: nfailed(10),i

 if (id==master) write(*,"(/,a)") '--> testing shuffle_part moves the cooling stores'

 call init_part()
 npart = n
 npartoftype(:) = 0
 npartoftype(igas) = n
 do i=1,n
    xyzh(:,i) = (/real(i),0.,0.,1./)
 enddo
 if (maxphase==maxp) iphase(1:n) = isetphase(igas,.true.)
 call init_coolra()
 do i=1,n
    ttherm_store(i) = 1.*i; ueqi_store(i) = 2.*i; tau_store(i) = 3.*i; du_store(i) = 4.*i
    duSPH(i) = 5.*i; Gpot_cool(i) = 6.*i; duFLD(i) = 7.*i; lambda_FLD(i) = 8.*i
    urad_FLD(i) = 9.*i; gradP_cool(i) = 10.*i
 enddo

 call kill_particle(ikill,npartoftype)
 call shuffle_part(npart)   ! particle n moves into slot ikill

 nfailed = 0
 call checkval(ttherm_store(ikill),1.*n,0.,nfailed(1),'ttherm_store moved')
 call checkval(ueqi_store(ikill),2.*n,0.,nfailed(2),'ueqi_store moved')
 call checkval(tau_store(ikill),3.*n,0.,nfailed(3),'tau_store moved')
 call checkval(du_store(ikill),4.*n,0.,nfailed(4),'du_store moved')
 call checkval(duSPH(ikill),5.*n,0.,nfailed(5),'duSPH moved')
 call checkval(Gpot_cool(ikill),6.*n,0.,nfailed(6),'Gpot_cool moved')
 call checkval(duFLD(ikill),7.*n,0.,nfailed(7),'duFLD moved')
 call checkval(lambda_FLD(ikill),8.*n,0.,nfailed(8),'lambda_FLD moved')
 call checkval(urad_FLD(ikill),9.*n,0.,nfailed(9),'urad_FLD moved')
 call checkval(gradP_cool(ikill),10.*n,0.,nfailed(10),'gradP_cool moved')
 call update_test_scores(ntests,nfailed,npass)

 call finish_coolra()

end subroutine test_shuffle_moves_coolra_stores

end module testpart
