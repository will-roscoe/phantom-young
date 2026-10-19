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
!   beta  = < t_therm sqrt(G M_star / R^3) >         mean over the annulus (icooling = 9)
!
! An empty annulus reports Q = -1 and c_s = 0; beta is -1 wherever it is unavailable
! (empty annulus, no central sink, or not icooling = 9).
!
! R is cylindrical, about the central sink (the one nearest the origin) if
! there is one, else the origin. Particles outside [R_min, R_max] are ignored,
! including in M_enc, as in the analysis. Bins are logarithmic.
!
! Output is one block per dump, every line tagged so a log parser can match
! the block exactly and cannot run past its end:
!
!   >> QBETA begin  t = <time>  nbins = <n>  mstar = <M_star>  (code units)
!   >> QBETA  R_mid  Sigma  c_s  Omega  Q  beta  N
!   >> QBETA  <one row per bin>
!   >> QBETA end
!
! :References: Toomre (1964); Gammie (2001)
!
! :Owner: will-roscoe
!
! :Runtime parameters:
!   - nbins_qbeta : *number of radial bins for the Q/beta log profile (0=off)*
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

 public :: write_qbeta_profile,accumulate_qbeta,finish_qbeta
 public :: write_options_qbeta,read_options_qbeta

 private

contains

!-----------------------------------------------------------------------
!+
!  bin gas particles by cylindrical radius about (xc,yc) and accumulate
!  the per-bin sums the profile is built from
!+
!-----------------------------------------------------------------------
subroutine accumulate_qbeta(np,xyzh,iphase,vxyzu,temp,mu,ttherm,use_ttherm,xc,yc,mstar,edges, &
                            n,nin,sumT,summu,sumu,sumbeta,nbeta)
 use part, only:iamtype,igas,isdead_or_accreted
 integer,         intent(in)  :: np
 real,            intent(in)  :: xyzh(:,:),vxyzu(:,:),temp(:),mu(:),xc,yc,mstar,edges(:)
 real,            intent(in)  :: ttherm(:)
 integer(kind=1), intent(in)  :: iphase(:)
 logical,         intent(in)  :: use_ttherm
 integer,         intent(out) :: n(:),nin(:),nbeta(:)
 real,            intent(out) :: sumT(:),summu(:),sumu(:),sumbeta(:)
 integer :: i,b,nb
 real    :: r,rlog0,dlogr

 nb = size(edges) - 1
 n = 0; nin = 0; nbeta = 0
 sumT = 0.; summu = 0.; sumu = 0.; sumbeta = 0.
 rlog0 = log(edges(1))
 dlogr = (log(edges(nb+1)) - rlog0)/nb
 !$omp parallel do default(none) &
 !$omp shared(np,xyzh,iphase,vxyzu,temp,mu,ttherm,use_ttherm,xc,yc,mstar,edges,nb,rlog0,dlogr) &
 !$omp private(i,r,b) &
 !$omp reduction(+:n,nin,nbeta,sumT,summu,sumu,sumbeta)
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
    if (use_ttherm .and. mstar > 0.) then
       sumbeta(b) = sumbeta(b) + ttherm(i)*sqrt(mstar/r**3)
       nbeta(b)   = nbeta(b) + 1
    endif
 enddo
 !$omp end parallel do

end subroutine accumulate_qbeta

!-----------------------------------------------------------------------
!+
!  turn the per-bin sums into Sigma, c_s, Omega, Q and beta (G = 1)
!+
!-----------------------------------------------------------------------
pure subroutine finish_qbeta(edges,pmass,mstar,kb_on_mh_code,n,nin,sumT,summu,sumu,sumbeta,nbeta, &
                             rmid,sigma,cs,omega,q,beta)
 use physcon, only:pi
 real,    intent(in)  :: edges(:),pmass,mstar,kb_on_mh_code
 integer, intent(in)  :: n(:),nin(:),nbeta(:)
 real,    intent(in)  :: sumT(:),summu(:),sumu(:),sumbeta(:)
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
       beta(b) = sumbeta(b)/nbeta(b)
    else
       beta(b) = -1.
    endif
 enddo

end subroutine finish_qbeta

!-----------------------------------------------------------------------
!+
!  compute the profile for the current particle state and write it to
!  the log (called at every dump)
!+
!-----------------------------------------------------------------------
subroutine write_qbeta_profile(time)
 use dim,             only:maxp,maxphase
 use eos,             only:icooling,gmw
 use eos_stamatellos, only:ttherm_store
 use io,              only:iprint,id,master,warning
 use mpiutils,        only:reduceall_mpi
 use part,            only:npart,xyzh,iphase,vxyzu,eos_vars,itemp,imu,massoftype,igas, &
                           nptmass,xyzmh_ptmass
 use physcon,         only:kb_on_mh
 use units,           only:unit_ergg
 real, intent(in) :: time
 integer, allocatable :: n(:),nin(:),nbeta(:)
 real,    allocatable :: edges(:),sumT(:),summu(:),sumu(:),sumbeta(:)
 real,    allocatable :: rmid(:),sigma(:),cs(:),omega(:),q(:),beta(:),mu(:)
 real, allocatable :: nottherm(:)
 integer :: b,nb,j,icentre
 real    :: xc,yc,mstar,rj2,rbest2
 logical :: use_ttherm

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

 allocate(edges(nb+1),n(nb),nin(nb),nbeta(nb),sumT(nb),summu(nb),sumu(nb),sumbeta(nb))
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
 use_ttherm = (icooling == 9 .and. allocated(ttherm_store))
 if (use_ttherm) then
    call accumulate_qbeta(npart,xyzh,phase_or_gas(),vxyzu,eos_vars(itemp,1:npart),mu,ttherm_store, &
                          .true.,xc,yc,mstar,edges,n,nin,sumT,summu,sumu,sumbeta,nbeta)
 else
    allocate(nottherm(1))
    call accumulate_qbeta(npart,xyzh,phase_or_gas(),vxyzu,eos_vars(itemp,1:npart),mu,nottherm, &
                          .false.,xc,yc,mstar,edges,n,nin,sumT,summu,sumu,sumbeta,nbeta)
 endif

 do b=1,nb
    n(b)       = int(reduceall_mpi('+',n(b)))
    nin(b)     = int(reduceall_mpi('+',nin(b)))
    nbeta(b)   = int(reduceall_mpi('+',nbeta(b)))
    sumT(b)    = reduceall_mpi('+',sumT(b))
    summu(b)   = reduceall_mpi('+',summu(b))
    sumu(b)    = reduceall_mpi('+',sumu(b))
    sumbeta(b) = reduceall_mpi('+',sumbeta(b))
 enddo
 call finish_qbeta(edges,massoftype(igas),mstar,kb_on_mh/unit_ergg,n,nin,sumT,summu,sumu, &
                   sumbeta,nbeta,rmid,sigma,cs,omega,q,beta)

 if (id==master) then
    write(iprint,"(1x,a,es14.6,a,i4,a,es12.4,a)") '>> QBETA begin  t = ',time,'  nbins = ',nb, &
          '  mstar = ',mstar,'  (code units)'
    write(iprint,"(1x,a)") '>> QBETA        R_mid        Sigma          c_s        Omega'// &
                           '            Q         beta          N'
    do b=1,nb
       write(iprint,"(1x,a,6(1x,es12.4),1x,i10)") '>> QBETA ',rmid(b),sigma(b),cs(b),omega(b), &
             q(b),beta(b),n(b)
    enddo
    write(iprint,"(1x,a)") '>> QBETA end'
 endif

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

end subroutine read_options_qbeta

end module radial_stability
