!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module radial_stability
!
! Radially binned Toomre Q and cooling parameter beta, written to the log
! at every dump, so a running disc can be read for why it is or is not
! fragmenting without reading a dump.
!
! Definitions follow the standard single-snapshot Toomre Q and cooling-time to
! orbital-time ratio, so post-processing of a dump can be compared directly:
!
!   Sigma = N m / (pi (R_out^2 - R_in^2))            per annulus
!   M_enc = m (particles in earlier bins + those at R <= R_mid) + M_star
!   Omega = sqrt(G M_enc / R_mid^3)
!   P/rho = (k_B/m_H) <T>/<mu>,  gamma = 1 + (P/rho)/<u>,  c_s = sqrt(gamma P/rho)
!   Q     = c_s Omega / (pi G Sigma)
!   beta_cool = < t_cool > Omega,   t_cool = u kappa / (4 sigma_SB T^4)   (icooling = 9)
!
! t_cool is the time the particle's radiative loss alone, with no irradiation or
! hydro heating, would take to remove its internal energy: the cooling time of the
! Gammie (2001) criterion. kappa is the effective opacity the radiative cooling uses
! (tau_store). It is not t_therm, the relaxation time towards the equilibrium energy,
! which is much shorter near equilibrium.
!
! An empty annulus reports Q = -1 and c_s = 0; beta_cool is -1 wherever it is
! unavailable (empty annulus, no central sink, or not icooling = 9). Particles with
! no cooling time yet (zero opacity or temperature) are left out of <t_cool> only.
!
! R is cylindrical, about the central sink (the one nearest the origin) if
! there is one, else the origin. Particles outside [R_min, R_max] are ignored,
! including in M_enc, as in the analysis. Bins are logarithmic.
!
! Output is one block per dump, every line tagged so a log parser can match
! the block exactly and cannot run past its end:
!
!   >> QBETA begin  t = <time>  nbins = <n>  mstar = <M_star>  (code units)
!   >> QBETA  R_mid  Sigma  c_s  Omega  Q  beta_cool  N
!   >> QBETA  <one row per bin>
!   >> QBETA end
!
! With nm_spiral > 0 a second block follows on the same rings and centre: the
! azimuthal Fourier modes m = 1..nm_spiral of the gas in each ring,
!
!   A_m   = | sum_i exp(i m phi_i) | / N      (gas particles share one mass)
!   phi_m = arg( sum_i exp(i m phi_i) ) / m,  in [0, 2 pi/m)
!   rms   = sqrt(2 sum_m A_m^2)               = rms of delta Sigma / Sigma over phi
!
! so a ring with Sigma ~ 1 + 2 A cos(m (phi - phi_0)) logs A_m = A, phi_m = phi_0:
! phi_m is the azimuth of one density maximum, anticlockwise from +x. Random
! azimuths give A_m ~ sqrt(pi/(4N)). An empty ring logs -1 for A_m, phi_m and rms.
!
!   >> SPIRAL begin  t = <time>  nbins = <n>  nm = <nm>  (code units, phi in radians)
!   >> SPIRAL  R_mid  N  A_1  phi_1 ... A_nm  phi_nm  rms
!   >> SPIRAL  <one row per bin>
!   >> SPIRAL end
!
! :References: Toomre (1964); Gammie (2001)
!
! :Owner: will-roscoe
!
! :Runtime parameters:
!   - nbins_qbeta : *number of radial bins for the Q/beta log profile (0=off)*
!   - nm_spiral   : *azimuthal modes m=1..nm_spiral logged on the Q/beta bins (0=off)*
!   - rmax_qbeta  : *outer radius of the Q/beta profile (code units)*
!   - rmin_qbeta  : *inner radius of the Q/beta profile (code units)*
!
! :Dependencies: dim, eos, eos_stamatellos, infile_utils, io, mpiutils,
!   part, physcon, units
!
 implicit none
 integer, public :: nbins_qbeta = 0
 real,    public :: rmin_qbeta  = -1.
 real,    public :: rmax_qbeta  = -1.
 integer, public :: nm_spiral   = 0
 integer, parameter :: nm_spiral_max = 4

 public :: write_qbeta_profile,accumulate_qbeta,finish_qbeta,cooling_time
 public :: accumulate_spiral,finish_spiral
 public :: write_options_qbeta,read_options_qbeta

 private

contains

!-----------------------------------------------------------------------
!+
!  bin gas particles by cylindrical radius about (xc,yc) and accumulate
!  the per-bin sums the profile is built from
!+
!-----------------------------------------------------------------------
subroutine accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,tcool,use_tcool,xc,yc,mstar,edges, &
                            n,nin,sumT,summu,sumu,sumtcool,nbeta)
 use part, only:iamtype,igas,isdead_or_accreted
 integer,         intent(in)  :: np
 real,            intent(in)  :: xyzh(:,:),vxyzu(:,:),temp(:),mu(:),xc,yc,mstar,edges(:)
 real,            intent(in)  :: tcool(:)
 integer(kind=1), intent(in)  :: iphase(:)
 logical,         intent(in)  :: use_tcool
 integer,         intent(out) :: n(:),nin(:),nbeta(:)
 real,            intent(out) :: sumT(:),summu(:),sumu(:),sumtcool(:)
 integer :: i,b,nb
 real    :: r,rlog0,dlogr

 nb = size(edges) - 1
 n = 0; nin = 0; nbeta = 0
 sumT = 0.; summu = 0.; sumu = 0.; sumtcool = 0.
 rlog0 = log(edges(1))
 dlogr = (log(edges(nb+1)) - rlog0)/nb
 !$omp parallel do default(none) &
 !$omp shared(np,xyzh,iphase,vxyzu,temp,mu,tcool,use_tcool,xc,yc,mstar,edges,nb,rlog0,dlogr) &
 !$omp private(i,r,b) &
 !$omp reduction(+:n,nin,nbeta,sumT,summu,sumu,sumtcool)
 do i=1,np
    if (isdead_or_accreted(xyzh(4,i))) cycle
    if (size(iphase) >= np) then
       if (iamtype(iphase(i)) /= igas) cycle
    endif
    r = sqrt((xyzh(1,i)-xc)**2 + (xyzh(2,i)-yc)**2)
    if (r < edges(1) .or. r >= edges(nb+1)) cycle
    b = min(nb,1 + int((log(r) - rlog0)/dlogr))
    ! the log index can land one bin off at an edge through rounding
    if (r < edges(b)) b = b - 1
    if (r >= edges(b+1)) b = b + 1
    n(b)     = n(b) + 1
    if (r <= 0.5*(edges(b) + edges(b+1))) nin(b) = nin(b) + 1
    sumT(b)  = sumT(b) + temp(i)
    summu(b) = summu(b) + mu(i)
    sumu(b)  = sumu(b) + vxyzu(4,i)
    if (use_tcool .and. mstar > 0.) then
       if (tcool(i) > 0.) then
          sumtcool(b) = sumtcool(b) + tcool(i)
          nbeta(b)    = nbeta(b) + 1
       endif
    endif
 enddo
 !$omp end parallel do

end subroutine accumulate_qbeta

!-----------------------------------------------------------------------
!+
!  turn the per-bin sums into Sigma, c_s, Omega, Q and beta_cool (G = 1)
!+
!-----------------------------------------------------------------------
pure subroutine finish_qbeta(edges,pmass,mstar,kb_on_mh_code,n,nin,sumT,summu,sumu,sumtcool,nbeta, &
                             rmid,sigma,cs,omega,q,beta)
 use physcon, only:pi
 real,    intent(in)  :: edges(:),pmass,mstar,kb_on_mh_code
 integer, intent(in)  :: n(:),nin(:),nbeta(:)
 real,    intent(in)  :: sumT(:),summu(:),sumu(:),sumtcool(:)
 real,    intent(out) :: rmid(:),sigma(:),cs(:),omega(:),q(:),beta(:)
 integer :: b,nb,ninside
 real    :: menc,ponrho,gam

 nb = size(edges) - 1
 ninside = 0
 do b=1,nb
    rmid(b)  = 0.5*(edges(b) + edges(b+1))
    sigma(b) = n(b)*pmass/(pi*(edges(b+1)**2 - edges(b)**2))
    menc     = (ninside + nin(b))*pmass + mstar
    omega(b) = sqrt(menc/rmid(b)**3)
    ninside  = ninside + n(b)
    if (n(b) > 0) then
       ponrho = kb_on_mh_code*(sumT(b)/n(b))/(summu(b)/n(b))
       gam    = 1. + ponrho/(sumu(b)/n(b))
       cs(b)  = sqrt(gam*ponrho)
       q(b)   = cs(b)*omega(b)/(pi*sigma(b))
    else
       ! -1, not huge(): es12.4 prints 1.8E+308 as '1.7977+308', which parsers reject
       cs(b) = 0.
       q(b)  = -1.
    endif
    if (nbeta(b) > 0) then
       beta(b) = sumtcool(b)/nbeta(b)*omega(b)
    else
       beta(b) = -1.
    endif
 enddo

end subroutine finish_qbeta

!-----------------------------------------------------------------------
!+
!  bin gas particles by cylindrical radius about (xc,yc) and sum
!  cos(m phi) and sin(m phi), m = 1..size(sumc,1), per bin; powers of
!  (x + i y)/R give them without an atan2 per particle
!+
!-----------------------------------------------------------------------
subroutine accumulate_spiral(np,xyzh,iphase,xc,yc,edges,n,sumc,sums)
 use part, only:iamtype,igas,isdead_or_accreted
 integer,         intent(in)  :: np
 real,            intent(in)  :: xyzh(:,:),xc,yc,edges(:)
 integer(kind=1), intent(in)  :: iphase(:)
 integer,         intent(out) :: n(:)
 real,            intent(out) :: sumc(:,:),sums(:,:)
 integer :: i,b,nb,m,nm
 real    :: dx,dy,r,c1,s1,cm,sm,tmp,rlog0,dlogr

 nb = size(edges) - 1
 nm = size(sumc,1)
 n = 0; sumc = 0.; sums = 0.
 rlog0 = log(edges(1))
 dlogr = (log(edges(nb+1)) - rlog0)/nb
 !$omp parallel do default(none) &
 !$omp shared(np,xyzh,iphase,xc,yc,edges,nb,nm,rlog0,dlogr) &
 !$omp private(i,b,m,dx,dy,r,c1,s1,cm,sm,tmp) &
 !$omp reduction(+:n,sumc,sums)
 do i=1,np
    if (isdead_or_accreted(xyzh(4,i))) cycle
    if (size(iphase) >= np) then
       if (iamtype(iphase(i)) /= igas) cycle
    endif
    dx = xyzh(1,i) - xc
    dy = xyzh(2,i) - yc
    r  = sqrt(dx**2 + dy**2)
    if (r < edges(1) .or. r >= edges(nb+1)) cycle
    b = min(nb,1 + int((log(r) - rlog0)/dlogr))
    if (r < edges(b)) b = b - 1
    if (r >= edges(b+1)) b = b + 1
    n(b) = n(b) + 1
    c1 = dx/r
    s1 = dy/r
    cm = c1
    sm = s1
    do m=1,nm
       sumc(m,b) = sumc(m,b) + cm
       sums(m,b) = sums(m,b) + sm
       tmp = cm*c1 - sm*s1
       sm  = sm*c1 + cm*s1
       cm  = tmp
    enddo
 enddo
 !$omp end parallel do

end subroutine accumulate_spiral

!-----------------------------------------------------------------------
!+
!  turn the per-bin sums into A_m, phi_m in [0, 2 pi/m) and the rms
!  contrast sqrt(2 sum A_m^2); all -1 in an empty bin
!+
!-----------------------------------------------------------------------
pure subroutine finish_spiral(n,sumc,sums,amp,phase,rms)
 use physcon, only:pi
 integer, intent(in)  :: n(:)
 real,    intent(in)  :: sumc(:,:),sums(:,:)
 real,    intent(out) :: amp(:,:),phase(:,:),rms(:)
 integer :: b,m

 do b=1,size(n)
    if (n(b) > 0) then
       do m=1,size(sumc,1)
          amp(m,b)   = sqrt(sumc(m,b)**2 + sums(m,b)**2)/n(b)
          phase(m,b) = modulo(atan2(sums(m,b),sumc(m,b)),2.*pi)/m
       enddo
       rms(b) = sqrt(2.*sum(amp(:,b)**2))
    else
       amp(:,b) = -1.; phase(:,b) = -1.; rms(b) = -1.
    endif
 enddo

end subroutine finish_spiral

!-----------------------------------------------------------------------
!+
!  compute the azimuthal mode profile on the Q/beta bins and write it to
!  the log, after the Q/beta block
!+
!-----------------------------------------------------------------------
subroutine write_spiral_profile(time,edges,xc,yc,iphase)
 use io,       only:iprint,id,master
 use mpiutils, only:reduceall_mpi
 use part,     only:npart,xyzh
 real,            intent(in) :: time,edges(:),xc,yc
 integer(kind=1), intent(in) :: iphase(:)
 integer, allocatable :: n(:)
 real,    allocatable :: sumc(:,:),sums(:,:),amp(:,:),phase(:,:),rms(:)
 integer :: b,m,nb,nm
 character(len=64) :: fmt

 nb = size(edges) - 1
 nm = min(nm_spiral,nm_spiral_max)
 allocate(n(nb),sumc(nm,nb),sums(nm,nb),amp(nm,nb),phase(nm,nb),rms(nb))
 call accumulate_spiral(npart,xyzh,iphase,xc,yc,edges,n,sumc,sums)
 do b=1,nb
    n(b) = int(reduceall_mpi('+',n(b)))
    do m=1,nm
       sumc(m,b) = reduceall_mpi('+',sumc(m,b))
       sums(m,b) = reduceall_mpi('+',sums(m,b))
    enddo
 enddo
 call finish_spiral(n,sumc,sums,amp,phase,rms)

 if (id==master) then
    write(iprint,"(1x,a,es14.6,a,i4,a,i2,a)") '>> SPIRAL begin  t = ',time,'  nbins = ',nb, &
          '  nm = ',nm,'  (code units, phi in radians)'
    write(iprint,"(1x,a,9a)") '>> SPIRAL       R_mid          N', &
          ('        A_'//achar(48+m)//'      phi_'//achar(48+m),m=1,nm),'        rms'
    write(fmt,"(a,i0,a)") '(1x,a,es12.4,1x,i10,',2*nm+1,'(1x,es10.3))'
    do b=1,nb
       write(iprint,fmt) '>> SPIRAL ',0.5*(edges(b)+edges(b+1)),n(b),(amp(m,b),phase(m,b),m=1,nm),rms(b)
    enddo
    write(iprint,"(1x,a)") '>> SPIRAL end'
 endif

end subroutine write_spiral_profile

!-----------------------------------------------------------------------
!+
!  time for the radiative loss alone, radconst T^4 / opac, to remove the
!  internal energy u; -1 if T or opac is not positive. radconst converts
!  4 sigma_SB T^4 / opac to code units of du/dt.
!+
!-----------------------------------------------------------------------
pure real function cooling_time(u,temp,opac,radconst)
 real, intent(in) :: u,temp,opac,radconst

 if (temp > 0. .and. opac > 0.) then
    cooling_time = u*opac/(radconst*temp**4)
 else
    cooling_time = -1.
 endif

end function cooling_time

!-----------------------------------------------------------------------
!+
!  compute the profile for the current particle state and write it to
!  the log (called at every dump)
!+
!-----------------------------------------------------------------------
subroutine write_qbeta_profile(time)
 use dim,             only:maxp,maxphase
 use eos,             only:icooling,gmw
 use eos_stamatellos, only:tau_store
 use io,              only:iprint,id,master,warning
 use mpiutils,        only:reduceall_mpi
 use part,            only:npart,xyzh,iphase,vxyzu,eos_vars,itemp,imu,massoftype,igas, &
                           nptmass,xyzmh_ptmass
 use physcon,         only:kb_on_mh,steboltz
 use units,           only:unit_ergg,utime
 real, intent(in) :: time
 integer, allocatable :: n(:),nin(:),nbeta(:)
 real,    allocatable :: edges(:),sumT(:),summu(:),sumu(:),sumtcool(:)
 real,    allocatable :: rmid(:),sigma(:),cs(:),omega(:),q(:),beta(:),mu(:)
 real, allocatable :: tcool(:)
 integer :: b,nb,j,icentre,i
 real    :: xc,yc,mstar,rj2,rbest2,radconst
 logical :: use_tcool

 nb = nbins_qbeta
 if (nb <= 0) return
 if (rmin_qbeta <= 0. .or. rmax_qbeta <= rmin_qbeta) then
    call warning('radial_stability','rmin_qbeta/rmax_qbeta not set: no Q/beta profile written')
    return
 endif

 ! centre on the sink nearest the origin, as the radiative cooling does for its star
 xc = 0.; yc = 0.; mstar = 0.; icentre = 0; rbest2 = huge(rbest2)
 do j=1,nptmass
    rj2 = xyzmh_ptmass(1,j)**2 + xyzmh_ptmass(2,j)**2 + xyzmh_ptmass(3,j)**2
    if (xyzmh_ptmass(4,j) > 0. .and. rj2 < rbest2) then
       rbest2 = rj2; icentre = j
    endif
 enddo
 if (icentre > 0) then
    xc = xyzmh_ptmass(1,icentre); yc = xyzmh_ptmass(2,icentre); mstar = xyzmh_ptmass(4,icentre)
 endif

 allocate(edges(nb+1),n(nb),nin(nb),nbeta(nb),sumT(nb),summu(nb),sumu(nb),sumtcool(nb))
 allocate(rmid(nb),sigma(nb),cs(nb),omega(nb),q(nb),beta(nb))
 do b=1,nb+1
    edges(b) = rmin_qbeta*(rmax_qbeta/rmin_qbeta)**(real(b-1)/nb)
 enddo

 ! mu per particle where the eos records it, the fixed mean molecular weight otherwise
 allocate(mu(npart))
 mu(:) = gmw
 if (size(eos_vars,2) >= npart) then
    where (eos_vars(imu,1:npart) > 0.) mu = eos_vars(imu,1:npart)
 endif
 ! radiative loss alone, as the cooling's dudti_rad without its Tmin heating term
 use_tcool = (icooling == 9 .and. allocated(tau_store))
 if (use_tcool) then
    radconst = 4.*steboltz/unit_ergg*utime
    allocate(tcool(npart))
    !$omp parallel do default(none) shared(npart,vxyzu,eos_vars,tau_store,radconst,tcool) private(i)
    do i=1,npart
       tcool(i) = cooling_time(vxyzu(4,i),eos_vars(itemp,i),tau_store(i),radconst)
    enddo
    !$omp end parallel do
 else
    allocate(tcool(1))
 endif
 call accumulate_qbeta(npart,xyzh,phase_or_gas(),vxyzu,eos_vars(itemp,1:npart),mu,tcool, &
                       use_tcool,xc,yc,mstar,edges,n,nin,sumT,summu,sumu,sumtcool,nbeta)

 do b=1,nb
    n(b)       = int(reduceall_mpi('+',n(b)))
    nin(b)     = int(reduceall_mpi('+',nin(b)))
    nbeta(b)   = int(reduceall_mpi('+',nbeta(b)))
    sumT(b)    = reduceall_mpi('+',sumT(b))
    summu(b)   = reduceall_mpi('+',summu(b))
    sumu(b)    = reduceall_mpi('+',sumu(b))
    sumtcool(b) = reduceall_mpi('+',sumtcool(b))
 enddo
 call finish_qbeta(edges,massoftype(igas),mstar,kb_on_mh/unit_ergg,n,nin,sumT,summu,sumu, &
                   sumtcool,nbeta,rmid,sigma,cs,omega,q,beta)

 if (id==master) then
    write(iprint,"(1x,a,es14.6,a,i4,a,es12.4,a)") '>> QBETA begin  t = ',time,'  nbins = ',nb, &
          '  mstar = ',mstar,'  (code units)'
    write(iprint,"(1x,a)") '>> QBETA        R_mid        Sigma          c_s        Omega'// &
                           '            Q    beta_cool          N'
    do b=1,nb
       write(iprint,"(1x,a,6(1x,es12.4),1x,i10)") '>> QBETA ',rmid(b),sigma(b),cs(b),omega(b), &
             q(b),beta(b),n(b)
    enddo
    write(iprint,"(1x,a)") '>> QBETA end'
 endif
 if (nm_spiral > 0) call write_spiral_profile(time,edges,xc,yc,phase_or_gas())

contains

 ! iphase is only allocated when particle types are tracked; otherwise all are gas
 function phase_or_gas() result(ph)
  integer(kind=1), allocatable :: ph(:)
  if (maxphase==maxp) then
     ph = iphase(1:npart)
  else
     allocate(ph(0))
  endif
 end function phase_or_gas

end subroutine write_qbeta_profile

subroutine write_options_qbeta(iunit)
 use infile_utils, only:write_inopt
 integer, intent(in) :: iunit

 call write_inopt(nbins_qbeta,'nbins_qbeta','number of radial bins for the Q/beta log profile (0=off)',iunit)
 if (nbins_qbeta > 0) then
    call write_inopt(rmin_qbeta,'rmin_qbeta','inner radius of the Q/beta profile (code units)',iunit)
    call write_inopt(rmax_qbeta,'rmax_qbeta','outer radius of the Q/beta profile (code units)',iunit)
    call write_inopt(nm_spiral,'nm_spiral','azimuthal modes m=1..nm_spiral logged on the Q/beta bins (0=off)',iunit)
 endif

end subroutine write_options_qbeta

subroutine read_options_qbeta(db,nerr)
 use infile_utils, only:inopts,read_inopt
 type(inopts), intent(inout) :: db(:)
 integer,      intent(inout) :: nerr

 ! absent from older .in files, so default rather than erroring: the profile stays off
 call read_inopt(nbins_qbeta,'nbins_qbeta',db,errcount=nerr,min=0,default=0)
 call read_inopt(rmin_qbeta,'rmin_qbeta',db,errcount=nerr,default=-1.)
 call read_inopt(rmax_qbeta,'rmax_qbeta',db,errcount=nerr,default=-1.)
 call read_inopt(nm_spiral,'nm_spiral',db,errcount=nerr,min=0,max=nm_spiral_max,default=0)

end subroutine read_options_qbeta

end module radial_stability
