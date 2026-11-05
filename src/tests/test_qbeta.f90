!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module testqbeta
!
! Unit tests for the radially binned Toomre Q / cooling beta log profile
! and the azimuthal Fourier (spiral) profile written beside it
!
! :References: None
!
! :Owner: will-roscoe
!
! :Runtime parameters: None
!
! :Dependencies: io, physcon, radial_stability, testutils
!
 implicit none
 public :: test_qbeta

 private

 ! two logarithmic bins, [1,2) and [2,4)
 real, parameter :: edges(3) = (/1.,2.,4./)

contains

subroutine test_qbeta(ntests,npass)
 use io, only:id,master
 integer, intent(inout) :: ntests,npass

 if (id==master) write(*,"(/,a,/)") '--> TESTING RADIAL Q/BETA PROFILE'
 call test_binning(ntests,npass)
 call test_profile(ntests,npass)
 call test_cooling_time(ntests,npass)
 call test_spiral_pattern(ntests,npass)
 call test_spiral_noise(ntests,npass)

end subroutine test_qbeta

!-----------------------------------------------------------------------
! particles land in the right annulus, outside [R_min,R_max) and dead
! particles are ignored, and the R <= R_mid count is right
!-----------------------------------------------------------------------
subroutine test_binning(ntests,npass)
 use radial_stability, only:accumulate_qbeta
 use testutils,        only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer, parameter :: np = 8
 real    :: xyzh(4,np),vxyzu(4,np),temp(np),mu(np),tcool(np),sumT(2),summu(2),sumu(2),sumtcool(2)
 integer :: n(2),nin(2),nbeta(2),nfail(4)
 integer(kind=1) :: iphase(0)
 real    :: r(np)

 ! R: in bin 1 (two below R_mid = 1.5, one above), exactly on the inner and
 ! middle edges, one dead particle, and one each side of the range
 r = (/1.2, 1.5, 1.8, 1.0, 2.0, 3.0, 0.5, 4.0/)
 call place(r,xyzh)
 xyzh(4,6) = -1.            ! dead (accreted) particle in bin 2
 vxyzu = 1.; temp = 10.; mu = 2.; tcool = 1.

 call accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,tcool,.true.,0.,0.,1.,edges, &
                       n,nin,sumT,summu,sumu,sumtcool,nbeta)
 nfail(:) = 0
 call checkval(n(1),4,0,nfail(1),'bin 1 holds R = 1.0, 1.2, 1.5, 1.8')
 call checkval(n(2),1,0,nfail(2),'bin 2 holds R = 2.0; dead, 0.5 and 4.0 excluded')
 call checkval(nin(1),3,0,nfail(3),'R <= R_mid counted for M_enc (1.0, 1.2, 1.5)')
 call checkval(sumT(1),40.,0.,nfail(4),'sums accumulate per bin')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_binning

!-----------------------------------------------------------------------
! Sigma, Omega, c_s, Q and beta from the per-bin sums
!-----------------------------------------------------------------------
subroutine test_profile(ntests,npass)
 use physcon,          only:pi
 use radial_stability, only:accumulate_qbeta,finish_qbeta
 use testutils,        only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer, parameter :: np = 10
 real, parameter :: pmass = 1.e-3, mstar = 1., kbmh = 2.
 real    :: xyzh(4,np),vxyzu(4,np),temp(np),mu(np),tcool(np),r(np)
 real    :: sumT(2),summu(2),sumu(2),sumtcool(2)
 real    :: rmid(2),sigma(2),cs(2),omega(2),q(2),beta(2),q1,menc,ponrho,gam
 integer :: n(2),nin(2),nbeta(2),nfail(9)
 integer(kind=1) :: iphase(0)

 ! every particle at R = 1.4, so bin 1 is exact and bin 2 is empty
 r = 1.4
 call place(r,xyzh)
 temp = 20.; mu = 2.5; vxyzu = 0.; vxyzu(4,:) = 30.; tcool = 0.7
 call accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,tcool,.true.,0.,0.,mstar,edges, &
                       n,nin,sumT,summu,sumu,sumtcool,nbeta)
 call finish_qbeta(edges,pmass,mstar,kbmh,n,nin,sumT,summu,sumu,sumtcool,nbeta, &
                   rmid,sigma,cs,omega,q,beta)

 nfail(:) = 0
 call checkval(sigma(1),np*pmass/(pi*(2.**2 - 1.**2)),1.e-14,nfail(1),'Sigma = N m / annulus area')
 menc   = np*pmass + mstar       ! all particles lie inside R_mid = 1.5
 ponrho = kbmh*20./2.5
 gam    = 1. + ponrho/30.
 call checkval(omega(1),sqrt(menc/1.5**3),1.e-14,nfail(2),'Omega from M_enc at R_mid')
 call checkval(cs(1),sqrt(gam*ponrho),1.e-14,nfail(3),'c_s = sqrt(gamma P/rho)')
 call checkval(q(1),cs(1)*omega(1)/(pi*sigma(1)),1.e-14,nfail(4),'Q = c_s Omega / (pi G Sigma)')
 call checkval(beta(1),0.7*omega(1),1.e-14,nfail(5),'beta_cool = <t_cool> Omega(M_enc)')
 call checkval(q(2) == -1. .and. cs(2) == 0. .and. beta(2) == -1.,.true.,nfail(6), &
               'empty bin: Q -1, c_s 0, beta -1')

 ! scaling rule: T and u both x4 leaves gamma alone, so c_s and Q double exactly
 q1 = q(1)
 temp = 4.*temp; vxyzu(4,:) = 4.*vxyzu(4,:)
 call accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,tcool,.true.,0.,0.,mstar,edges, &
                       n,nin,sumT,summu,sumu,sumtcool,nbeta)
 call finish_qbeta(edges,pmass,mstar,kbmh,n,nin,sumT,summu,sumu,sumtcool,nbeta, &
                   rmid,sigma,cs,omega,q,beta)
 call checkval(q(1)/q1,2.,1.e-12,nfail(7),'Q scales as sqrt(T) at fixed gamma')

 ! no central mass or no cooling time: beta is reported as unavailable, Q is not affected
 call accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,tcool,.false.,0.,0.,mstar,edges, &
                       n,nin,sumT,summu,sumu,sumtcool,nbeta)
 call finish_qbeta(edges,pmass,mstar,kbmh,n,nin,sumT,summu,sumu,sumtcool,nbeta, &
                   rmid,sigma,cs,omega,q,beta)
 call checkval(beta(1) == -1. .and. abs(q(1)/q1 - 2.) < 1.e-12,.true.,nfail(8), &
               'without t_cool: beta -1, Q unchanged')

 ! particles with no cooling time (t_cool <= 0) are left out of the mean only
 tcool(1:3) = -1.
 call accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,tcool,.true.,0.,0.,mstar,edges, &
                       n,nin,sumT,summu,sumu,sumtcool,nbeta)
 call finish_qbeta(edges,pmass,mstar,kbmh,n,nin,sumT,summu,sumu,sumtcool,nbeta, &
                   rmid,sigma,cs,omega,q,beta)
 call checkval(nbeta(1) == np-3 .and. n(1) == np .and. abs(beta(1) - 0.7*omega(1)) < 1.e-14,.true., &
               nfail(9),'t_cool <= 0 skipped in beta, counted in Q')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_profile

!-----------------------------------------------------------------------
! per-particle cooling time from the radiative loss rate alone
!-----------------------------------------------------------------------
subroutine test_cooling_time(ntests,npass)
 use radial_stability, only:cooling_time
 use testutils,        only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer :: nfail(3)

 nfail(:) = 0
 ! u / (radconst T^4 / opac) = 2 / (4e-3 * 1e4 / 5) = 0.25
 call checkval(cooling_time(2.,10.,5.,4.e-3),0.25,1.e-14,nfail(1),'t_cool = u opac / (radconst T^4)')
 call checkval(cooling_time(2.,0.,5.,4.e-3),-1.,0.,nfail(2),'T <= 0: t_cool unavailable (-1)')
 call checkval(cooling_time(2.,10.,0.,4.e-3),-1.,0.,nfail(3),'opacity <= 0: t_cool unavailable (-1)')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_cooling_time

!-----------------------------------------------------------------------
! an m-armed ring of known amplitude and phase gives them back, per ring,
! including a phase that winds with R; other modes and empty rings as stated
!-----------------------------------------------------------------------
subroutine test_spiral_pattern(ntests,npass)
 use physcon,          only:pi
 use radial_stability, only:accumulate_spiral,finish_spiral
 use testutils,        only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer, parameter :: nr = 1000, nm = 4, nb = 3
 real, parameter :: edges3(nb+1) = (/1.,2.,4.,8./)
 real    :: xyzh(4,nb*nr+2),sumc(nm,nb),sums(nm,nb),amp(nm,nb),phase(nm,nb),rms(nb)
 real    :: phi0(nb),amp0
 integer :: n(nb),nfail(10),b,np
 integer(kind=1) :: iphase(0)

 ! two-armed pattern, amplitude 0.2, phase winding as phi_0 = 0.3 + 0.9 ln(R/1.5)
 amp0 = 0.2
 do b=1,nb
    phi0(b) = 0.3 + 0.9*log(0.75*(edges3(b)+edges3(b+1))/1.5)
    call place_pattern(nr,0.5*(edges3(b)+edges3(b+1)),2,amp0,phi0(b),xyzh(:,(b-1)*nr+1:b*nr))
 enddo
 ! one dead particle in ring 1 and one beyond the outer edge: both ignored
 np = nb*nr + 2
 xyzh(:,np-1) = (/1.5,0.,0.,-1./)
 xyzh(:,np)   = (/9.,0.,0.,0.1/)
 call accumulate_spiral(np,xyzh,iphase,0.,0.,edges3,n,sumc,sums)
 call finish_spiral(n,sumc,sums,amp,phase,rms)

 nfail(:) = 0
 call checkval(all(n == nr),.true.,nfail(1),'dead and out-of-range particles are not counted')
 call checkval(nb,amp(2,:),amp0,1.e-10,nfail(2),'A_2 of a two-armed ring')
 call checkval(nb,phase(2,:)-phi0,0.,1.e-10,nfail(3),'phi_2 follows a winding phi_0(R)')
 call checkval(maxval(abs(amp((/1,3,4/),:))) < 1.e-10,.true.,nfail(4),'A_1, A_3, A_4 vanish')
 call checkval(nb,rms,sqrt(2.)*amp0,1.e-10,nfail(5),'rms contrast = sqrt(2 sum A_m^2)')

 ! one- and three-armed rings: m and phase in [0, 2 pi/m) come back
 call place_pattern(nr,1.5,1,0.1,4.0,xyzh(:,1:nr))
 call place_pattern(nr,3.0,3,0.3,1.0,xyzh(:,nr+1:2*nr))
 call accumulate_spiral(2*nr,xyzh,iphase,0.,0.,edges3,n,sumc,sums)
 call finish_spiral(n,sumc,sums,amp,phase,rms)
 call checkval(abs(amp(1,1)-0.1) < 1.e-10 .and. abs(phase(1,1)-4.0) < 1.e-10,.true.,nfail(6), &
               'one-armed ring: A_1 and phi_1')
 call checkval(abs(amp(3,2)-0.3) < 1.e-10 .and. abs(phase(3,2)-1.0) < 1.e-10,.true.,nfail(7), &
               'three-armed ring: A_3 and phi_3')
 call checkval(all(phase(:,1:2) >= 0.) .and. all(phase(1,1:2) < 2.*pi) .and. all(phase(4,1:2) < 0.5*pi), &
               .true.,nfail(8),'phi_m lies in [0, 2 pi/m)')
 call checkval(n(3) == 0 .and. all(amp(:,3) == -1.) .and. all(phase(:,3) == -1.) .and. rms(3) == -1., &
               .true.,nfail(9),'empty ring: A_m, phi_m and rms are -1')

 ! the pattern is measured about the centre given, not the origin
 xyzh(1,1:nr) = xyzh(1,1:nr) + 10.
 xyzh(2,1:nr) = xyzh(2,1:nr) - 5.
 call accumulate_spiral(nr,xyzh,iphase,10.,-5.,edges3,n,sumc,sums)
 call finish_spiral(n,sumc,sums,amp,phase,rms)
 call checkval(abs(amp(1,1)-0.1) < 1.e-10 .and. abs(phase(1,1)-4.0) < 1.e-10,.true.,nfail(10), &
               'measured about (xc,yc)')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_spiral_pattern

!-----------------------------------------------------------------------
! evenly spaced particles have no modes; random azimuths give the noise
! floor <A_m> = sqrt(pi/(4N)) of a sum of N random unit vectors
!-----------------------------------------------------------------------
subroutine test_spiral_noise(ntests,npass)
 use physcon,          only:pi
 use radial_stability, only:accumulate_spiral,finish_spiral
 use testutils,        only:checkval,update_test_scores
 integer, intent(inout) :: ntests,npass
 integer, parameter :: nr = 1000, nm = 4, ntrial = 400
 real    :: xyzh(4,nr),sumc(nm,2),sums(nm,2),amp(nm,2),phase(nm,2),rms(2),phi,amean
 integer :: n(2),nfail(2),i,k
 integer(kind=8) :: seed
 integer(kind=1) :: iphase(0)

 do i=1,nr
    phi = 8.*atan(1.)*(i-1)/nr     ! exact 2 pi: physcon's pi has 11 digits
    xyzh(:,i) = (/1.5*cos(phi),1.5*sin(phi),0.,0.1/)
 enddo
 call accumulate_spiral(nr,xyzh,iphase,0.,0.,edges,n,sumc,sums)
 call finish_spiral(n,sumc,sums,amp,phase,rms)
 nfail(:) = 0
 call checkval(maxval(amp(:,1)) < 1.e-12,.true.,nfail(1),'evenly spaced ring: every A_m vanishes')

 seed = 20261101_8
 amean = 0.
 do k=1,ntrial
    do i=1,nr
       seed = mod(16807_8*seed,2147483647_8)
       phi  = 2.*pi*real(seed)/2147483647.
       xyzh(1,i) = 1.5*cos(phi)
       xyzh(2,i) = 1.5*sin(phi)
    enddo
    call accumulate_spiral(nr,xyzh,iphase,0.,0.,edges,n,sumc,sums)
    call finish_spiral(n,sumc,sums,amp,phase,rms)
    amean = amean + sum(amp(:,1))
 enddo
 amean = amean/(nm*ntrial)
 ! 1600 Rayleigh samples: the mean is known to 1.3%, so 5% is ~4 sigma
 call checkval(amean,sqrt(pi/(4.*nr)),0.05,nfail(2),'random ring: <A_m> = sqrt(pi/4N)')
 call update_test_scores(ntests,nfail,npass)

end subroutine test_spiral_noise

! put n particles on a ring of radius r with azimuthal density proportional
! to 1 + 2 a cos(m (phi - phi0)), at the midpoint quantiles of its CDF
subroutine place_pattern(n,r,m,a,phi0,xyzh)
 use physcon, only:pi
 integer, intent(in)  :: n,m
 real,    intent(in)  :: r,a,phi0
 real,    intent(out) :: xyzh(:,:)
 integer :: j,it
 real    :: target,phi,g

 do j=1,n
    target = 2.*pi*(j-0.5)/n
    phi = target
    do it=1,100
       g = phi + (2.*a/m)*(sin(m*(phi-phi0)) - sin(-m*phi0)) - target
       phi = phi - g/(1. + 2.*a*cos(m*(phi-phi0)))
       if (abs(g) < 1.e-15) exit
    enddo
    xyzh(1,j) = r*cos(phi)
    xyzh(2,j) = r*sin(phi)
    xyzh(3,j) = 0.01*(-1)**j
    xyzh(4,j) = 0.1
 enddo

end subroutine place_pattern

! put particles at cylindrical radius r(i) on the x axis, so R = r exactly and
! the edge cases are not decided by rounding in the test itself
subroutine place(r,xyzh)
 real, intent(in)  :: r(:)
 real, intent(out) :: xyzh(:,:)
 integer :: i

 do i=1,size(r)
    xyzh(1,i) = r(i)
    xyzh(2,i) = 0.
    xyzh(3,i) = 0.01*(-1)**i
    xyzh(4,i) = 0.1
 enddo

end subroutine place

end module testqbeta
