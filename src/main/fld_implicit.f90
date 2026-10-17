!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module fld_implicit
!
! Implicit (backward-Euler) flux-limited diffusion for the Forgan et al.
! (2009) hybrid, do FLD = 2: an implicit diffusion solve produces duFLD,
! which the T_eq relaxation in cooling_radapprox uses unchanged.
!
! :References: Forgan et al. (2009), MNRAS 394, 882
!
! :Owner: Will Roscoe
!
! :Runtime parameters: None
!
! :Dependencies: boundary, dim, eos_stamatellos, io, kernel, part,
!   radiation_implicit, timestep, timestep_ind, units
!
 implicit none
 integer, public :: fld_sweep_cap = 200   ! Gauss-Seidel sweep limit
 integer, public :: fld_nsweeps   = 0     ! sweeps used by the last solve
 real,    public :: fld_maxchange = 0.    ! max |dT'/T'| in the last sweep
 real,    public :: fld_leak      = 0.    ! sum m du / sum m |du| over the particles solved, last solve
 real, parameter, public :: fld_tol = 1.e-6
 public :: do_fld_implicit

 private

 ! compacted neighbour list (as radiation_implicit), pair coefficients, per-particle state
 integer, allocatable, save :: ivar(:,:),ijvar(:)
 real,    allocatable, save :: Kij(:),Told(:),Tnew(:),kfld(:),acoef(:)
 logical, allocatable, save :: need(:),solve(:)

contains

!-----------------------------------------------------------------------
!+
!  Backward-Euler diffusion step for the active gas particles: solves
!  c_v,i (T'_i - T_i)/dt_i = sum_j K_ij (T'_j - T'_i) by Gauss-Seidel,
!  with inactive neighbours fixed at T_j and dt_i from the particle's own
!  bin (dt with global timesteps), and writes
!  duFLD(i) = c_v,i (T'_i - T_i)/dt_i. Other particles' duFLD is left as
!  it was. Sets fld_nsweeps, fld_maxchange and fld_leak; warns if the
!  sweep cap is reached (the last iterate is kept). Needs the tree and
!  lambda_FLD from the density pass of the same step.
!+
!-----------------------------------------------------------------------
subroutine do_fld_implicit(dt,npart,xyzh,vxyzu)
 use boundary,           only:dxbound,dybound,dzbound
 use dim,                only:ind_timesteps,periodic
 use eos_stamatellos,    only:duFLD
 use io,                 only:warning,iverbose,id,master
 use kernel,             only:grkern,cnormk,radkern2
 use part,               only:gradh,massoftype,igas,rhoh,ibin
 use radiation_implicit, only:get_compacted_neighbour_list
 use timestep,           only:dtmax
 use timestep_ind,       only:get_dt
 use units,              only:unit_ergg,unit_density
 real,    intent(in) :: dt
 integer, intent(in) :: npart
 real,    intent(in) :: xyzh(:,:),vxyzu(:,:)
 integer :: n,i,j,k,ncompact,ncompactlocal,istart,nneigh,isweep
 real    :: pmass,hi,hj,rhoi,rhoj,dx,dy,dz,rij,q2i,q2j,Fi,Fj,num,den,Tp,change,dti
 real    :: dsum,dabs,mdu

 fld_nsweeps = 0; fld_maxchange = 0.; fld_leak = 0.
 if (dt <= 0.) return
 call ensure_size(npart)
 call get_compacted_neighbour_list(xyzh,ivar,ijvar,ncompact,ncompactlocal)
 pmass = massoftype(igas)

 ! the particles solved for (gas among the active list) and every gas neighbour they reach
 need(1:npart) = .false.
 do n=1,ncompact
    i = ivar(3,n)
    solve(n) = is_live_gas(i,xyzh)
    if (.not.solve(n)) cycle
    need(i) = .true.
    do k=1,ivar(1,n)
       j = ijvar(ivar(2,n)+k)
       if (is_live_gas(j,xyzh)) need(j) = .true.
    enddo
 enddo

 ! T and k, one table lookup per particle
 !$omp parallel do default(none) shared(npart,need,xyzh,vxyzu,pmass,Told,kfld) private(i)
 do i=1,npart
    if (need(i)) call particle_state(i,rhoh(xyzh(4,i),pmass),vxyzu(4,i),Told(i),kfld(i))
 enddo
 !$omp end parallel do

 ! a_i = c_v,i/dt_i and the pair coefficients K_ij of the explicit force-pass term
 !$omp parallel do default(none) &
 !$omp shared(ncompact,ivar,ijvar,solve,need,xyzh,pmass,Told,kfld,acoef,Kij,gradh,dt,dtmax,ibin) &
 !$omp shared(unit_ergg,unit_density,dxbound,dybound,dzbound) &
 !$omp private(n,i,j,k,istart,nneigh,hi,hj,rhoi,rhoj,dx,dy,dz,rij,q2i,q2j,Fi,Fj,dti)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
    hi = xyzh(4,i); rhoi = rhoh(hi,pmass)
    dti = dt
    if (ind_timesteps) dti = get_dt(dtmax,ibin(i))
    acoef(i) = heat_capacity(Told(i),rhoi*unit_density)/unit_ergg/dti
    do k=1,nneigh
       Kij(istart+k) = 0.
       j = ijvar(istart+k)
       if (.not.need(j)) cycle
       if (kfld(i) + kfld(j) <= 0.) cycle
       dx = xyzh(1,i) - xyzh(1,j); dy = xyzh(2,i) - xyzh(2,j); dz = xyzh(3,i) - xyzh(3,j)
       if (periodic) then
          if (abs(dx) > 0.5*dxbound) dx = dx - dxbound*sign(1.0,dx)
          if (abs(dy) > 0.5*dybound) dy = dy - dybound*sign(1.0,dy)
          if (abs(dz) > 0.5*dzbound) dz = dz - dzbound*sign(1.0,dz)
       endif
       rij = sqrt(dx*dx + dy*dy + dz*dz)
       hj  = xyzh(4,j)
       q2i = (rij/hi)**2; q2j = (rij/hj)**2
       if (q2i >= radkern2 .or. q2j >= radkern2 .or. rij <= 0.) cycle
       rhoj = rhoh(hj,pmass)
       Fi = grkern(q2i,sqrt(q2i))*cnormk/hi**4*gradh(1,i)
       Fj = grkern(q2j,sqrt(q2j))*cnormk/hj**4*gradh(1,j)
       Kij(istart+k) = max(-4.*pmass*kfld(i)*kfld(j)/((kfld(i) + kfld(j))*rhoi*rhoj)*0.5*(Fi + Fj)/rij,0.)
    enddo
 enddo
 !$omp end parallel do

 ! Gauss-Seidel sweeps in place: each update is a convex combination, so bounded
 where (need(1:npart)) Tnew(1:npart) = Told(1:npart)
 do isweep=1,fld_sweep_cap
    change = 0.
    !$omp parallel do default(none) shared(ncompact,ivar,ijvar,solve,Kij,acoef,Told,Tnew) &
    !$omp private(n,i,k,istart,nneigh,num,den,Tp) reduction(max:change)
    do n=1,ncompact
       if (.not.solve(n)) cycle
       i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
       num = acoef(i)*Told(i); den = acoef(i)
       do k=1,nneigh
          num = num + Kij(istart+k)*Tnew(ijvar(istart+k))
          den = den + Kij(istart+k)
       enddo
       if (den > 0.) then
          Tp = num/den
          change = max(change,abs(Tp - Tnew(i))/Tp)
          Tnew(i) = Tp
       endif
    enddo
    !$omp end parallel do
    fld_nsweeps = isweep; fld_maxchange = change
    if (change < fld_tol) exit
 enddo
 if (fld_maxchange >= fld_tol) call warning('fld_implicit','not converged; keeping the last iterate', &
                                            var='max dT/T',val=fld_maxchange)

 ! du_FLD and the leak: sum m du / sum m |du|
 dsum = 0.; dabs = 0.
 !$omp parallel do default(none) shared(ncompact,ivar,solve,acoef,Tnew,Told,duFLD,pmass) &
 !$omp private(n,i,mdu) reduction(+:dsum,dabs)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n)
    duFLD(i) = acoef(i)*(Tnew(i) - Told(i))
    mdu = pmass*duFLD(i)
    dsum = dsum + mdu; dabs = dabs + abs(mdu)
 enddo
 !$omp end parallel do
 if (dabs > 0.) fld_leak = dsum/dabs
 if (iverbose > 2 .and. id == master) write(*,"(a,i4,a,es10.3,a,es10.3)") &
    ' fld_implicit: sweeps ',fld_nsweeps,'  max dT/T ',fld_maxchange,'  leak ',fld_leak

end subroutine do_fld_implicit

!-----------------------------------------------------------------------
!+
!  true for a gas particle that is not dead or accreted
!+
!-----------------------------------------------------------------------
logical function is_live_gas(i,xyzh)
 use dim,  only:maxphase,maxp
 use part, only:iphase,iamtype,igas,isdead_or_accreted
 integer, intent(in) :: i
 real,    intent(in) :: xyzh(:,:)

 is_live_gas = .not.isdead_or_accreted(xyzh(4,i))
 if (maxphase==maxp) is_live_gas = is_live_gas .and. iamtype(iphase(i))==igas

end function is_live_gas

!-----------------------------------------------------------------------
!+
!  temperature T (K) and FLD conductivity k (code units) of particle i;
!  k = 0 where lambda = 0, with T then from the table directly
!+
!-----------------------------------------------------------------------
subroutine particle_state(i,rho,u,T,k)
 use eos_stamatellos, only:get_k_fld,getopac_opdep
 use units,           only:unit_ergg,unit_density
 integer, intent(in)  :: i
 real,    intent(in)  :: rho,u
 real,    intent(out) :: T,k
 real :: kb,kp,mu

 call get_k_fld(rho,u,i,k,T)
 if (k == 0.) call getopac_opdep(u*unit_ergg,rho*unit_density,kb,kp,T,mu)   ! get_k_fld leaves T unset

end subroutine particle_state

!-----------------------------------------------------------------------
!+
!  c_v = du/dT at fixed density (cgs, erg/g/K): the slope of the table
!  interpolation getintenerg_opdep, centred on T (K), rho_cgs in g/cm^3
!+
!-----------------------------------------------------------------------
real function heat_capacity(T,rho_cgs)
 use eos_stamatellos, only:getintenerg_opdep
 real, intent(in) :: T,rho_cgs
 real, parameter  :: d = 1.e-3
 real :: up,um

 call getintenerg_opdep(T*(1.+d),rho_cgs,up)
 call getintenerg_opdep(T*(1.-d),rho_cgs,um)
 heat_capacity = (up - um)/(2.*d*T)

end function heat_capacity

!-----------------------------------------------------------------------
!+
!  work arrays for n particles, grown (with 10% headroom) as npart grows;
!  the neighbour list is sized as radiation_implicit sizes its own
!+
!-----------------------------------------------------------------------
subroutine ensure_size(n)
 use kernel,  only:radkern
 use part,    only:hfact
 use physcon, only:pi
 integer, intent(in) :: n
 integer :: nalloc,nneigh_average,icompactmax

 if (allocated(ivar)) then
    if (size(ivar,2) >= n) return
    deallocate(ivar,ijvar,Kij,Told,Tnew,kfld,acoef,need,solve)
 endif
 nalloc = n + n/10
 nneigh_average = int(4./3.*pi*(radkern*hfact)**3) + 1
 icompactmax = int(min(1.2*10.*nneigh_average*real(nalloc),real(huge(0))))
 allocate(ivar(3,nalloc),ijvar(icompactmax),Kij(icompactmax))
 allocate(Told(nalloc),Tnew(nalloc),kfld(nalloc),acoef(nalloc),need(nalloc),solve(nalloc))

end subroutine ensure_size

end module fld_implicit
