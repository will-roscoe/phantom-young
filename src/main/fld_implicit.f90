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
 integer, public :: fld_sweep_cap   = 20000   ! Gauss-Seidel sweeps allowed per (sub-)step before it is split
 integer, public :: fld_split_depth = 10    ! maximum number of times a step may be halved
 integer, public :: fld_nsweeps = 0     ! sweeps used by the last solve, all sub-steps together
 integer, public :: fld_nsplits = 0     ! step splits in the last solve
 real,    public :: fld_resid   = 0.    ! max_i |r_i|/(c_v,i T'_i) of the last solve (largest over its sub-steps)
 real,    public :: fld_leak    = 0.    ! (Delta U + Delta owed)/(sum of |energy moved|), last solve
 real,    public :: fld_tcell   = 0.    ! min over solved particles of c_v,i / sum_j K_ij (code time)
 real,    public :: fld_stiff   = 0.    ! max over solved particles of sum_j K_ij dt_ij / c_v,i (dt_ij as solved)
 integer, public :: fld_nsolves_run  = 0  ! solves since the start of this run
 integer, public :: fld_nlimited_run = 0  ! of those, solves that reached the flux limiter
 real,    public :: fld_resid_limited = 0. ! largest residual of a limited solve this run
 real, parameter, public :: fld_tol = 1.e-6
 public :: do_fld_implicit,fld_pair_asymmetry,fld_summary

 private

 ! compacted neighbour list (as radiation_implicit), pair coefficients K_ij dt_ij, per-particle state
 integer, allocatable, save :: ivar(:,:),ijvar(:),irow(:)
 real,    allocatable, save :: Kij(:),Told(:),Tstar(:),Tnew(:),kfld(:),cv(:),dtp(:),Ein(:),owapp(:),Rp(:),Rm(:),u0(:),rhoc(:)
 logical, allocatable, save :: need(:),solve(:),isol(:)
 real,    save :: edep,edep_abs    ! energy per unit mass put into owed_FLD (sum, sum of moduli)
 logical, save :: unconverged
 integer, save :: ncompact_last = 0

contains

!-----------------------------------------------------------------------
!+
!  Backward-Euler flux-limited diffusion for the active gas particles.
!  Each pair exchanges over dt_ij = min(dt_i,dt_j), dt_i from the
!  particle's own bin (dt with global timesteps); per solved particle
!
!    c_v,i (T'_i - T*_i) = sum_j K_ij dt_ij (T'_j - T'_i),
!
!  with inactive neighbours fixed at T'_j = T_j and T*_i = T_i +
!  owed_FLD(i)/c_v,i (owed_FLD(i) is then zeroed). The exchange is applied
!  pairwise, E_ij = K_ij dt_ij (T'_j - T'_i) to i and -E_ij to j (to
!  owed_FLD(j) when j is not solved), so it conserves energy to round-off
!  whatever the residual. If the sweep cap is reached the step is halved
!  and solved twice, recursively, up to fld_split_depth; beyond that it
!  warns and applies the last iterate's exchange, flux-limited so that
!  every T stays within the range of start temperatures. Writes
!  duFLD(i) = (owed applied + sum_j E_ij)/dt_i for the solved particles
!  (others' duFLD is left as it was), and sets fld_nsweeps, fld_nsplits,
!  fld_resid, fld_leak, fld_tcell and fld_stiff. owed_FLD of particles no longer
!  live gas is dropped and counted in fld_leak. Needs the tree and
!  lambda_FLD from the density pass of the same step; all gas particles
!  must have the same mass.
!+
!-----------------------------------------------------------------------
subroutine do_fld_implicit(dt,npart,xyzh,vxyzu)
 use dim,                only:ind_timesteps
 use eos_stamatellos,    only:duFLD,owed_FLD
 use io,                 only:warning,iverbose,id,master
 use part,               only:massoftype,igas,rhoh,ibin
 use radiation_implicit, only:get_compacted_neighbour_list
 use timestep,           only:dtmax
 use timestep_ind,       only:get_dt
 use units,              only:unit_ergg,unit_density
 real,    intent(in) :: dt
 integer, intent(in) :: npart
 real,    intent(in) :: xyzh(:,:),vxyzu(:,:)
 integer :: n,i,j,k,ncompact,ncompactlocal,istart,nneigh
 real    :: pmass,rhoi,dtij,rate,srate,sk,stiff,tcell,elost,dsum,dabs,ei

 fld_nsweeps = 0; fld_nsplits = 0; fld_resid = 0.; fld_leak = 0.; fld_tcell = 0.; fld_stiff = 0.
 if (dt <= 0.) return
 call ensure_size(npart)
 call get_compacted_neighbour_list(xyzh,ivar,ijvar,ncompact,ncompactlocal)
 ncompact_last = ncompact
 pmass = massoftype(igas)

 ! owed to particles that are no longer live gas is lost
 elost = 0.
 !$omp parallel do default(none) shared(npart,need,isol,owed_FLD,xyzh) private(i) reduction(+:elost)
 do i=1,npart
    need(i) = .false.; isol(i) = .false.
    if (owed_FLD(i) /= 0.) then
       if (.not.is_live_gas(i,xyzh)) then
          elost = elost + owed_FLD(i)
          owed_FLD(i) = 0.
       endif
    endif
 enddo
 !$omp end parallel do

 ! the particles solved for (gas among the active list) and every gas neighbour they reach
 do n=1,ncompact
    i = ivar(3,n)
    solve(n) = is_live_gas(i,xyzh)
    if (.not.solve(n)) cycle
    need(i) = .true.; isol(i) = .true.; irow(i) = n
    do k=1,ivar(1,n)
       j = ijvar(ivar(2,n)+k)
       if (is_live_gas(j,xyzh)) need(j) = .true.
    enddo
 enddo

 ! T and k (one table lookup per particle); for the solved ones c_v, dt_i and the owed energy
 !$omp parallel do default(none) &
 !$omp shared(npart,need,isol,xyzh,vxyzu,pmass,Told,Tstar,Tnew,kfld,cv,dtp,owapp,Ein,owed_FLD,u0,rhoc) &
 !$omp shared(dt,dtmax,ibin,unit_ergg,unit_density) private(i,rhoi)
 do i=1,npart
    if (.not.need(i)) cycle
    rhoi = rhoh(xyzh(4,i),pmass)
    call particle_state(i,rhoi,vxyzu(4,i),Told(i),kfld(i))
    Tstar(i) = Told(i)
    if (isol(i)) then
       rhoc(i) = rhoi*unit_density
       u0(i)   = vxyzu(4,i)
       cv(i)   = heat_capacity(Told(i),rhoc(i))/unit_ergg
       dtp(i) = dt
       if (ind_timesteps) dtp(i) = get_dt(dtmax,ibin(i))
       owapp(i) = owed_FLD(i)
       owed_FLD(i) = 0.
       Tstar(i) = Told(i) + owapp(i)/cv(i)
       Ein(i) = 0.
    endif
    Tnew(i) = Tstar(i)
 enddo
 !$omp end parallel do

 ! pair coefficients K_ij dt_ij, and the shortest cell diffusion time c_v,i/sum_j K_ij
 tcell = huge(0.); stiff = 0.
 !$omp parallel do default(none) &
 !$omp shared(ncompact,ivar,ijvar,solve,need,isol,xyzh,pmass,Kij,dtp,cv) &
 !$omp private(n,i,j,k,istart,nneigh,dtij,rate,srate,sk) reduction(min:tcell) reduction(max:stiff)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
    srate = 0.; sk = 0.
    do k=1,nneigh
       Kij(istart+k) = 0.
       j = ijvar(istart+k)
       if (.not.need(j)) cycle
       rate = pair_rate(min(i,j),max(i,j),xyzh,pmass)
       dtij = dtp(i)
       if (isol(j)) dtij = min(dtp(i),dtp(j))   ! an inactive neighbour always has the longer step
       Kij(istart+k) = rate*dtij
       srate = srate + rate
       sk = sk + Kij(istart+k)
    enddo
    if (srate > 0.) tcell = min(tcell,cv(i)/srate)
    stiff = max(stiff,sk/cv(i))
 enddo
 !$omp end parallel do
 fld_tcell = tcell; fld_stiff = stiff

 edep = 0.; edep_abs = 0.; unconverged = .false.
 call solve_step(1.,0,ncompact)
 fld_nsolves_run = fld_nsolves_run + 1
 if (unconverged) then
    fld_nlimited_run = fld_nlimited_run + 1
    fld_resid_limited = max(fld_resid_limited,fld_resid)
 endif
 if (unconverged) call warning('fld_implicit','not converged at the maximum split depth; exchange from '// &
                               'the last iterate, flux-limited to keep T bounded',var='residual',val=fld_resid)

 ! du_FLD, and the leak (Delta U + Delta owed)/(energy moved), per unit mass as the masses are equal
 dsum = 0.; dabs = 0.
 !$omp parallel do default(none) shared(ncompact,ivar,solve,owapp,Ein,dtp,duFLD) &
 !$omp private(n,i,ei) reduction(+:dsum,dabs)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n)
    duFLD(i) = (owapp(i) + Ein(i))/dtp(i)
    ei = duFLD(i)*dtp(i)
    dsum = dsum + ei - owapp(i); dabs = dabs + abs(ei)
 enddo
 !$omp end parallel do
 dsum = dsum + edep - elost; dabs = dabs + edep_abs + abs(elost)
 if (dabs > 0.) fld_leak = dsum/dabs
 if (iverbose > 2 .and. id == master) write(*,"(a,i7,a,i4,a,es10.3,a,es10.3,a,es10.3,a,es10.3)") &
    ' fld_implicit: sweeps ',fld_nsweeps,'  splits ',fld_nsplits,'  residual ',fld_resid,'  leak ',fld_leak, &
    '  dt/t_cell ',dt/max(fld_tcell,tiny(fld_tcell)),'  stiffness ',fld_stiff

end subroutine do_fld_implicit

!-----------------------------------------------------------------------
!+
!  end-of-run line: the number of implicit solves and how many reached
!  the flux limiter (not converged at the maximum split depth), with the
!  worst residual among those; writes nothing if there were no solves
!+
!-----------------------------------------------------------------------
subroutine fld_summary(iunit)
 integer, intent(in) :: iunit

 if (fld_nsolves_run <= 0) return
 write(iunit,"(a,i10,a,i8,a,es10.3)") ' FLD implicit: solves ',fld_nsolves_run, &
    '  flux-limited ',fld_nlimited_run,'  worst limited residual ',fld_resid_limited

end subroutine fld_summary

!-----------------------------------------------------------------------
!+
!  advance the solved particles from Tstar over f times each pair's
!  dt_ij: solve, and if the sweep cap is reached solve two halves in
!  turn (to fld_split_depth); then apply the exchange, which leaves the
!  end temperature in Tstar
!+
!-----------------------------------------------------------------------
recursive subroutine solve_step(f,depth,ncompact)
 real,    intent(in) :: f
 integer, intent(in) :: depth,ncompact
 logical :: converged
 real    :: resid

 call solve_linear(f,ncompact,converged,resid)
 if (.not.converged .and. depth < fld_split_depth) then
    fld_nsplits = fld_nsplits + 1
    call solve_step(0.5*f,depth+1,ncompact)
    call solve_step(0.5*f,depth+1,ncompact)
    return
 endif
 fld_resid = max(fld_resid,resid)
 if (converged) then
    call apply_exchange(f,ncompact,limit=.false.)
 else
    ! the exchange from an unconverged iterate need not be bounded: limit it
    unconverged = .true.
    call exchange_limit(f,ncompact)
    call apply_exchange(f,ncompact,limit=.true.)
 endif

end subroutine solve_step

!-----------------------------------------------------------------------
!+
!  the linear solve, c_v,i (T'_i - Tstar_i) = sum_j f Kij (T'_j - T'_i)
!  for T' in Tnew, by Gauss-Seidel sweeps in place (each update is a
!  convex combination, so bounded) from T' = Tstar. Converged when the
!  scaled residual (see residual_max) is below fld_tol; it is checked
!  exactly once the residual seen during a sweep is below fld_tol.
!+
!-----------------------------------------------------------------------
subroutine solve_linear(f,ncompact,converged,resid)
 real,    intent(in)  :: f
 integer, intent(in)  :: ncompact
 logical, intent(out) :: converged
 real,    intent(out) :: resid
 integer :: n,i,k,istart,nneigh,isweep
 real    :: num,den,Kp,rpre

 converged = .false.
 !$omp parallel do default(none) shared(ncompact,ivar,solve,Tnew,Tstar) private(n,i)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n)
    Tnew(i) = Tstar(i)
 enddo
 !$omp end parallel do
 do isweep=1,fld_sweep_cap
    rpre = 0.
    !$omp parallel do default(none) shared(ncompact,ivar,ijvar,solve,Kij,cv,Tstar,Tnew,f) &
    !$omp private(n,i,k,istart,nneigh,num,den,Kp) reduction(max:rpre)
    do n=1,ncompact
       if (.not.solve(n)) cycle
       i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
       num = cv(i)*Tstar(i); den = cv(i)
       do k=1,nneigh
          Kp  = f*Kij(istart+k)
          num = num + Kp*Tnew(ijvar(istart+k))
          den = den + Kp
       enddo
       rpre = max(rpre,abs(den*Tnew(i) - num)/(cv(i)*Tnew(i)))
       Tnew(i) = num/den
    enddo
    !$omp end parallel do
    fld_nsweeps = fld_nsweeps + 1
    if (rpre < fld_tol) then
       resid = residual_max(f,ncompact)
       if (resid < fld_tol) then
          converged = .true.
          return
       endif
    endif
 enddo
 resid = residual_max(f,ncompact)
 converged = (resid < fld_tol)

end subroutine solve_linear

!-----------------------------------------------------------------------
!+
!  max_i |r_i|/(c_v,i T'_i), r_i = c_v,i (T'_i - Tstar_i) - sum_j f Kij
!  (T'_j - T'_i): the energy imbalance as a fraction of c_v,i T'_i, a
!  heat content that is positive for every particle (T' > 0, c_v > 0)
!  and does not depend on dt or on how strongly i is coupled
!+
!-----------------------------------------------------------------------
real function residual_max(f,ncompact)
 real,    intent(in) :: f
 integer, intent(in) :: ncompact
 integer :: n,i,k,istart,nneigh
 real    :: r,rmax

 rmax = 0.
 !$omp parallel do default(none) shared(ncompact,ivar,ijvar,solve,Kij,cv,Tstar,Tnew,f) &
 !$omp private(n,i,k,istart,nneigh,r) reduction(max:rmax)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
    r = cv(i)*(Tnew(i) - Tstar(i))
    do k=1,nneigh
       r = r - f*Kij(istart+k)*(Tnew(ijvar(istart+k)) - Tnew(i))
    enddo
    rmax = max(rmax,abs(r)/(cv(i)*Tnew(i)))
 enddo
 !$omp end parallel do
 residual_max = rmax

end function residual_max

!-----------------------------------------------------------------------
!+
!  the pairwise exchange from the iterate in Tnew: E_ij = f Kij (T'_j -
!  T'_i) to i (Ein, and Tstar += E/c_v) and -E_ij to j, through j's own
!  row when j is solved (Kij is exactly symmetric, so the two sides
!  cancel exactly) and into owed_FLD(j) when it is not; with limit, each
!  E_ij is first scaled by the factors exchange_limit set
!+
!-----------------------------------------------------------------------
subroutine apply_exchange(f,ncompact,limit)
 use eos_stamatellos, only:owed_FLD
 real,    intent(in) :: f
 integer, intent(in) :: ncompact
 logical, intent(in) :: limit   ! scale each pair by the factors from exchange_limit
 integer :: n,i,j,k,istart,nneigh
 real    :: e,esum,dep,depabs

 dep = 0.; depabs = 0.
 !$omp parallel do default(none) shared(ncompact,ivar,ijvar,solve,isol,Kij,cv,Tstar,Tnew,Ein,owed_FLD,f,limit,Rp,Rm) &
 !$omp private(n,i,j,k,istart,nneigh,e,esum) reduction(+:dep,depabs)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
    esum = 0.
    do k=1,nneigh
       if (Kij(istart+k) <= 0.) cycle
       j = ijvar(istart+k)
       e = f*Kij(istart+k)*(Tnew(j) - Tnew(i))
       if (limit) then
          if (isol(j)) then
             e = e*merge(min(Rp(i),Rm(j)),min(Rm(i),Rp(j)),e > 0.)
          else
             e = e*merge(Rp(i),Rm(i),e > 0.)
          endif
       endif
       esum = esum + e
       if (.not.isol(j)) then
          !$omp atomic
          owed_FLD(j) = owed_FLD(j) - e
          dep = dep - e; depabs = depabs + abs(e)
       endif
    enddo
    Ein(i)   = Ein(i) + esum
    Tstar(i) = Tstar(i) + esum/cv(i)
 enddo
 !$omp end parallel do
 edep = edep + dep; edep_abs = edep_abs + depabs

end subroutine apply_exchange

!-----------------------------------------------------------------------
!+
!  limiter factors for the exchange from an unconverged iterate (Zalesak
!  1979 flux limiting): with P+-_i the sums of i's positive and negative
!  E_ij, and Q+-_i the energy that takes i from its current u to the
!  lowest and highest start temperature in the solve (T_lo, T_hi; from
!  the EOS table at i's density, so the bound holds in T and not only in
!  the linearisation), sets Rp(i) = min(1,Q+_i/P+_i) and Rm(i) =
!  min(1,Q-_i/P-_i). A pair then exchanges min(R+ of the gainer, R- of
!  the loser) E_ij (factor 1 on a side that is not solved), which keeps
!  every solved T within [T_lo,T_hi] and, being the same factor in both
!  rows, conservative
!+
!-----------------------------------------------------------------------
subroutine exchange_limit(f,ncompact)
 use eos_stamatellos, only:getintenerg_opdep
 use units,           only:unit_ergg
 real,    intent(in) :: f
 integer, intent(in) :: ncompact
 integer :: n,i,j,k,istart,nneigh
 real    :: e,pp,pm,tlo,thi,ulo,uhi,ui

 tlo = huge(0.); thi = -huge(0.)
 !$omp parallel do default(none) shared(ncompact,ivar,ijvar,solve,Kij,Tstar) &
 !$omp private(n,i,k,istart,nneigh) reduction(min:tlo) reduction(max:thi)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
    tlo = min(tlo,Tstar(i)); thi = max(thi,Tstar(i))
    do k=1,nneigh
       if (Kij(istart+k) > 0.) then
          tlo = min(tlo,Tstar(ijvar(istart+k))); thi = max(thi,Tstar(ijvar(istart+k)))
       endif
    enddo
 enddo
 !$omp end parallel do
 !$omp parallel do default(none) shared(ncompact,ivar,ijvar,solve,Kij,Tnew,f,tlo,thi,Rp,Rm,u0,owapp,Ein,rhoc) &
 !$omp shared(unit_ergg) private(n,i,j,k,istart,nneigh,e,pp,pm,ulo,uhi,ui)
 do n=1,ncompact
    if (.not.solve(n)) cycle
    i = ivar(3,n); nneigh = ivar(1,n); istart = ivar(2,n)
    pp = 0.; pm = 0.
    do k=1,nneigh
       j = ijvar(istart+k)
       e = f*Kij(istart+k)*(Tnew(j) - Tnew(i))
       if (e > 0.) pp = pp + e
       if (e < 0.) pm = pm + e
    enddo
    ui = u0(i) + owapp(i) + Ein(i)
    Rp(i) = 1.; Rm(i) = 1.
    if (pp > 0.) then
       call getintenerg_opdep(thi,rhoc(i),uhi)
       Rp(i) = max(min(1.,(uhi/unit_ergg - ui)/pp),0.)
    endif
    if (pm < 0.) then
       call getintenerg_opdep(tlo,rhoc(i),ulo)
       Rm(i) = max(min(1.,(ulo/unit_ergg - ui)/pm),0.)
    endif
 enddo
 !$omp end parallel do

end subroutine exchange_limit

!-----------------------------------------------------------------------
!+
!  K_ij, the rate coefficient of the explicit force-pass term (code
!  units, per unit mass of i), for the pair a < b with both kernels
!  reaching. Written in a form symmetric in a and b and always called
!  with a < b, so K_ab and K_ba are bitwise equal
!+
!-----------------------------------------------------------------------
real function pair_rate(a,b,xyzh,pmass)
 use boundary, only:dxbound,dybound,dzbound
 use dim,      only:periodic
 use kernel,   only:grkern,cnormk,radkern2
 use part,     only:gradh,rhoh
 integer, intent(in) :: a,b
 real,    intent(in) :: xyzh(:,:),pmass
 real :: dx,dy,dz,rab,q2a,q2b,Fa,Fb,kbar

 pair_rate = 0.
 if (kfld(a) + kfld(b) <= 0.) return
 dx = xyzh(1,a) - xyzh(1,b); dy = xyzh(2,a) - xyzh(2,b); dz = xyzh(3,a) - xyzh(3,b)
 if (periodic) then
    if (abs(dx) > 0.5*dxbound) dx = dx - dxbound*sign(1.0,dx)
    if (abs(dy) > 0.5*dybound) dy = dy - dybound*sign(1.0,dy)
    if (abs(dz) > 0.5*dzbound) dz = dz - dzbound*sign(1.0,dz)
 endif
 rab = sqrt(dx*dx + dy*dy + dz*dz)
 q2a = (rab/xyzh(4,a))**2; q2b = (rab/xyzh(4,b))**2
 if (q2a >= radkern2 .or. q2b >= radkern2 .or. rab <= 0.) return
 Fa = grkern(q2a,sqrt(q2a))*cnormk/xyzh(4,a)**4*gradh(1,a)
 Fb = grkern(q2b,sqrt(q2b))*cnormk/xyzh(4,b)**4*gradh(1,b)
 kbar = kfld(a)*kfld(b)/(kfld(a) + kfld(b))
 pair_rate = max(-4.*pmass*kbar/(rhoh(xyzh(4,a),pmass)*rhoh(xyzh(4,b),pmass))*0.5*(Fa + Fb)/rab,0.)

end function pair_rate

!-----------------------------------------------------------------------
!+
!  max over pairs of solved particles of |K_ij dt_ij - K_ji dt_ji|, from
!  the last solve: 0 when the pair coefficients are exactly symmetric
!  (a test diagnostic, O(n nneigh^2))
!+
!-----------------------------------------------------------------------
real function fld_pair_asymmetry()
 integer :: n,i,j,k,m,nj
 real    :: amax

 amax = 0.
 do n=1,ncompact_last
    if (.not.solve(n)) cycle
    i = ivar(3,n)
    do k=1,ivar(1,n)
       j = ijvar(ivar(2,n)+k)
       if (.not.isol(j)) cycle
       nj = irow(j)
       do m=1,ivar(1,nj)
          if (ijvar(ivar(2,nj)+m) == i) amax = max(amax,abs(Kij(ivar(2,n)+k) - Kij(ivar(2,nj)+m)))
       enddo
    enddo
 enddo
 fld_pair_asymmetry = amax

end function fld_pair_asymmetry

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
    deallocate(ivar,ijvar,irow,Kij,Told,Tstar,Tnew,kfld,cv,dtp,Ein,owapp,Rp,Rm,u0,rhoc,need,solve,isol)
 endif
 nalloc = n + n/10
 nneigh_average = int(4./3.*pi*(radkern*hfact)**3) + 1
 icompactmax = int(min(1.2*10.*nneigh_average*real(nalloc),real(huge(0))))
 allocate(ivar(3,nalloc),ijvar(icompactmax),Kij(icompactmax),irow(nalloc))
 allocate(Told(nalloc),Tstar(nalloc),Tnew(nalloc),kfld(nalloc),cv(nalloc),dtp(nalloc),Ein(nalloc),owapp(nalloc))
 allocate(Rp(nalloc),Rm(nalloc),u0(nalloc),rhoc(nalloc),need(nalloc),solve(nalloc),isol(nalloc))

end subroutine ensure_size

end module fld_implicit
