!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module eos_stamatellos
!
! eos_stamatellos
!
! :References: None
!
! :Owner: Alison Young
!
! :Runtime parameters: None
!
! :Dependencies: allocutils, datafiles, dim, io, part
!

 implicit none
 real, allocatable, public :: optable(:,:,:)
 real, allocatable, public :: gradP_cool(:)!gradP_cool=gradP/rho
 real, allocatable, public :: ttherm_store(:),ueqi_store(:),tau_store(:),du_store(:),duSPH(:)
 real, allocatable, public :: Gpot_cool(:),duFLD(:),lambda_FLD(:),urad_FLD(:)
 real, allocatable, public :: owed_FLD(:)   ! do FLD = 2: energy per unit mass owed by neighbours (code units)
 character(len=25), public :: eos_file= 'eos_lom.dat' !default name of tabulated EOS file
 logical, public :: doFLD = .True.
 integer, public :: fld_mode = 2   ! 0 off, 1 explicit, 2 implicit
 logical, public :: floor_energy = .False.
 integer, public :: iunitst=19
 integer,save :: nx,ny ! dimensions of optable read in
 real, public :: qprofile = 0. ! q index override for lumdisc=1; 0=standard (qindex=0.25), otherwise use as qindex

 ! floored power-law temperature profile (lumdisc=2 / iprofile=2)
 integer, public :: iprofile  = 1     ! 1 = legacy radiative, 2 = floored power-law
 real,    public :: T0_prof   = 100.  ! K,  normalization temperature (value at 1 AU)
 real,    public :: n_prof    = 2.    ! combination index: 2 = MS20 (T^2), 4 = flux-add (T^4)
 real,    public :: R0_prof   = 0.01  ! AU, inner smoothing radius
 real,    public :: T_bg_prof = 10.   ! K,  background floor T_inf (set = T_bg/Tfloor)
 real,    public :: L_star_prof = -1. ! Lsun, luminosity T0_prof was derived from (lumdisc=3); <0 = none

 public :: read_optab,getopac_opdep,init_coolra,getintenerg_opdep,finish_coolra
 public :: alloc_coolra_stores,copy_coolra_stores
 public :: get_k_fld
 public :: get_T_profile,get_T0_from_lum
 public :: write_headeropts_flooredprof,read_headeropts_flooredprof

contains

!----------------------------------------------------------------
!+
!  Allocate the four per-particle cooling stores, and zero them ONLY
!  when this call is what created them.
!  Also installs copy_coolra_stores as part:copy_particle_extra, so
!  shuffle_part moves the cooling arrays with their particles.
!
!  They are the state of the exponential relaxation in radcool_evolve_ui,
!  they are written to every full dump, and on a restart they are read back
!  before init_coolra runs. Zeroing them unconditionally here discarded that
!  read, and because ttherm_store = 0 fails the guard that decides whether to
!  cool at all, every particle then skipped one cooling step per restart.
!+
!----------------------------------------------------------------
subroutine alloc_coolra_stores()
 use dim, only:maxp,maxp_alloc
 use allocutils, only:allocate_array
 use part, only:copy_particle_extra
 integer :: np

 copy_particle_extra => copy_coolra_stores
 if (allocated(ttherm_store)) return
 if (maxp == 0) then
    np = int(maxp_alloc)
 else
    np = maxp
 endif
 call allocate_array('ttherm_store',ttherm_store,np)
 call allocate_array('ueqi_store',ueqi_store,np)
 call allocate_array('tau_store',tau_store,np)
 call allocate_array('du_store',du_store,np)
 ueqi_store(:)   = 0d0
 ttherm_store(:) = 0d0
 tau_store(:)    = 0d0
 du_store(:)     = 0d0

end subroutine alloc_coolra_stores

!----------------------------------------------------------------
!+
!  Copy particle src's entries in the per-particle cooling arrays to
!  dst; alloc_coolra_stores installs it as part:copy_particle_extra so that
!  copy_particle_all (shuffle_part) moves them. Unallocated arrays are skipped.
!+
!----------------------------------------------------------------
subroutine copy_coolra_stores(src,dst)
 integer, intent(in) :: src,dst

 if (allocated(ttherm_store)) ttherm_store(dst) = ttherm_store(src)
 if (allocated(ueqi_store))   ueqi_store(dst)   = ueqi_store(src)
 if (allocated(tau_store))    tau_store(dst)    = tau_store(src)
 if (allocated(du_store))     du_store(dst)     = du_store(src)
 if (allocated(duSPH))        duSPH(dst)        = duSPH(src)
 if (allocated(Gpot_cool))    Gpot_cool(dst)    = Gpot_cool(src)
 if (allocated(duFLD))        duFLD(dst)        = duFLD(src)
 if (allocated(lambda_FLD))   lambda_FLD(dst)   = lambda_FLD(src)
 if (allocated(urad_FLD))     urad_FLD(dst)     = urad_FLD(src)
 if (allocated(gradP_cool))   gradP_cool(dst)   = gradP_cool(src)
 if (allocated(owed_FLD)) then   ! energy in transit: moved, not duplicated
    owed_FLD(dst) = owed_FLD(src)
    if (dst /= src) owed_FLD(src) = 0.
 endif

end subroutine copy_coolra_stores

subroutine init_coolra()
 use dim, only:maxp,maxp_alloc
 use allocutils, only:allocate_array
 integer :: np
 if (maxp == 0) then
    np = int(maxp_alloc)
 else
    np = maxp
 endif
 print *, "Allocating cooling arrays for np=",np
 call allocate_array('gradP_cool',gradP_cool,np)
 call allocate_array('duSPH',duSPH,np)
 call allocate_array('Gpot_cool',Gpot_cool,np)
 call allocate_array('duFLD',duFLD,np)
 call allocate_array('owed_FLD',owed_FLD,np)
 call allocate_array('lambda_fld',lambda_fld,np)
 call allocate_array('urad_FLD',urad_FLD,np)
 ! allocates and zeroes only if nothing has already populated them
 call alloc_coolra_stores()

 gradP_cool(:) = 0d0
 duSPH(:) = 0d0
 Gpot_cool(:) = 0d0
 urad_FLD(:) = 0d0
 duFLD(:) = 0d0
 owed_FLD(:) = 0d0
 if (doFLD) then
    print *, "Using Forgan+ 2009 hybrid cooling method (FLD)"
 else
    print *, "NOT using FLD. Using cooling only"
 endif
end subroutine init_coolra

subroutine finish_coolra()
 use part, only:copy_particle_extra
 nullify(copy_particle_extra)
 if (allocated(optable)) deallocate(optable)
 if (allocated(gradP_cool)) deallocate(gradP_cool)
 if (allocated(ttherm_store)) deallocate(ttherm_store)
 if (allocated(ueqi_store)) deallocate(ueqi_store)
 if (allocated(tau_store)) deallocate(tau_store)
 if (allocated(du_store)) deallocate(du_store)
 if (allocated(duSPH)) deallocate(duSPH)
 if (allocated(Gpot_cool)) deallocate(Gpot_cool)
 if (allocated(duFLD)) deallocate(duFLD)
 if (allocated(owed_FLD)) deallocate(owed_FLD)
 if (allocated(lambda_fld)) deallocate(lambda_fld)
 if (allocated(urad_FLD)) deallocate(urad_FLD)
! close(iunitst)
end subroutine finish_coolra

subroutine read_optab(eos_file,ierr)
 use datafiles, only:find_phantom_datafile
 character(len=*), intent(in) :: eos_file
 integer, intent(out) :: ierr
 integer :: i,j,errread,ios,iunit
 character(len=120) :: filepath,junk
 character(len=512) :: line

 ! read in data file for interpolation
 filepath=find_phantom_datafile(eos_file,'eos/lombardi')
 print *,"EOS file: FILEPATH:",filepath
 open(newunit=iunit,file=filepath,form="formatted",status="old",iostat=ierr)
 if (ierr > 0) return
 do
    read(iunit,'(A120)',iostat=ios) junk
    if (len(trim(adjustl(junk))) == 0) cycle ! blank line
    if ((index(adjustl(junk),"::") == 0) .and. (index(adjustl(junk),"#")  /=  1 )) then !ignore comment lines
       junk = adjustl(junk)
       read(junk, *,iostat=errread) nx, ny
       exit
    endif
 enddo
! allocate array for storing opacity tables
! columns: rho, T, u, mu, pseudo-mean (kappaBar), Rosseland (kappaPart), Planck.
! A 6-column table has no Planck column, so Rosseland stands in for it.
 allocate(optable(nx,ny,7))
 do i = 1,nx
    do j = 1,ny
       read(iunit,'(A)',iostat=ios) line
       if (ios < 0) then
          write(*,*) 'Unexpected EOF in data section at i=',i,' j=',j
          ierr = 3
          close(iunit)
          return
       endif
       read(line,*,iostat=errread) optable(i,j,1:7)
       if (errread /= 0) then
          read(line,*,iostat=errread) optable(i,j,1:6)
          optable(i,j,7) = optable(i,j,6)
       endif
    enddo
 enddo
 close(iunit)
end subroutine read_optab

!
! Main subroutine for interpolating tables to get EOS values
!
subroutine getopac_opdep(ui,rhoi,kappaBar,kappaPart,Ti,gmwi,kappaPl)
 use io, only:warning
 real, intent(in)  :: ui,rhoi
 real, intent(out) :: kappaBar,kappaPart,Ti,gmwi
 real, intent(out), optional :: kappaPl  ! Planck mean, for optically thin emission

 integer :: irho,iu
 real :: m,c
 real :: kbar1,kbar2
 real :: kappa1,kappa2
 real :: kpl1,kpl2
 real :: Tpart1,Tpart2
 real :: gmw1,gmw2
 real :: rhomin,umin

 rhomin = optable(1,1,1)
 umin = optable(1,1,3)
 ! interpolate through optable to find corresponding kappaBar, kappaPart and T
 ! check values are in range of tables
 if (rhoi > optable(nx,1,1) ) then
    call warning('getopac_opdep','rhoi above range of EOS table.',var='rhoi',val=rhoi)
 elseif  (rhoi < rhomin) then
    call warning('getopac_opdep','rhoi below range of EOS table.',var='rhoi',val=rhoi)
 elseif (ui > optable(1,ny,3) .or. ui < umin) then
    call warning('getopac_opdep','ui out of range',var='ui',val=ui)
 endif

 ! Find index of rhoi in table such that array(ind) < rhoi < array(ind+1)
! print *, "search for rhoi"
 irho = search_table(optable(:,1,1),nx,rhoi)
 iu = search_table(optable(irho,:,3),ny,ui)

 m = (optable(irho,iu,5)-optable(irho,iu+1,5))/(optable(irho,iu,3)-optable(irho,iu+1,3))
 c = optable(irho,iu+1,5) - m*optable(irho,iu+1,3)
 kbar1 = m*ui + c

 m = (optable(irho,iu,6)-optable(irho,iu+1,6))/(optable(irho,iu,3)-optable(irho,iu+1,3))
 c = optable(irho,iu+1,6) - m*optable(irho,iu+1,3)
 kappa1 = m*ui + c

 if (present(kappaPl)) then
    m = (optable(irho,iu,7)-optable(irho,iu+1,7))/(optable(irho,iu,3)-optable(irho,iu+1,3))
    c = optable(irho,iu+1,7) - m*optable(irho,iu+1,3)
    kpl1 = m*ui + c
 endif

 m = (optable(irho,iu,2) - optable(irho,iu+1,2))/(optable(irho,iu,3)-optable(irho,iu+1,3))
 c = optable(irho,iu+1,2) - m*optable(irho,iu+1,3)
 Tpart1 = m*ui + c

 m = (optable(irho,iu,4) - optable(irho,iu+1,4))/(optable(irho,iu,3)-optable(irho,iu+1,3))
 c = optable(irho,iu+1,4) - m*optable(irho,iu+1,3)
 gmw1 = m*ui + c

 ! Search for ui in irho+1 list for interpolation
 iu = search_table(optable(irho+1,:,3),ny,ui)

 m = (optable(irho+1,iu,5) - optable(irho+1,iu+1,5))/(optable(irho+1,iu,3) - optable(irho+1,iu+1,3))
 c = optable(irho+1,iu+1,5) - m*optable(irho+1,iu+1,3)
 kbar2 = m*ui + c

 m = (optable(irho+1,iu,6) - optable(irho+1,iu+1,6))/(optable(irho+1,iu,3) - optable(irho+1,iu+1,3))
 c = optable(irho+1,iu+1,6) - m*optable(irho+1,iu+1,3)
 kappa2 = m*ui + c

 if (present(kappaPl)) then
    m = (optable(irho+1,iu,7) - optable(irho+1,iu+1,7))/(optable(irho+1,iu,3) - optable(irho+1,iu+1,3))
    c = optable(irho+1,iu+1,7) - m*optable(irho+1,iu+1,3)
    kpl2 = m*ui + c
 endif

 m = (optable(irho+1,iu,2) - optable(irho+1,iu+1,2))/(optable(irho+1,iu,3) - optable(irho+1,iu+1,3))
 c = optable(irho+1,iu+1,2) - m*optable(irho+1,iu+1,3)
 Tpart2 = m*ui + c

 m = (optable(irho+1,iu,4) - optable(irho+1,iu+1,4))/(optable(irho+1,iu,3) - optable(irho+1,iu+1,3))
 c = optable(irho+1,iu+1,4) - m*optable(irho+1,iu+1,3)
 gmw2 = m*ui + c

 m = (kappa2 - kappa1)/(optable(irho+1,1,1)-optable(irho,1,1))
 c = kappa2 - m*optable(irho+1,1,1)
 kappaPart = m*rhoi + c

 if (present(kappaPl)) then
    m = (kpl2 - kpl1)/(optable(irho+1,1,1)-optable(irho,1,1))
    c = kpl2 - m*optable(irho+1,1,1)
    kappaPl = m*rhoi + c
 endif

 m = (kbar2 - kbar1)/(optable(irho+1,1,1)-optable(irho,1,1))
 c = kbar2 - m*optable(irho+1,1,1)
 kappaBar = m*rhoi + c

 m = (Tpart2 - Tpart1)/(optable(irho+1,1,1)-optable(irho,1,1))
 c = Tpart2 - m*optable(irho+1,1,1)
 Ti = m*rhoi + c

 m = (gmw2 - gmw1)/(optable(irho+1,1,1)-optable(irho,1,1))
 c = gmw2 - m*optable(irho+1,1,1)
 gmwi = m*rhoi + c

end subroutine getopac_opdep

subroutine getintenerg_opdep(Teqi, rhoi, ueqi)
 use io, only:warning
 real, intent(out) :: ueqi
 real, intent(in)    :: Teqi,rhoi

 real :: u1, u2
 real :: m, c
 integer :: irho,itemp

 if (rhoi > optable(nx,1,1) .or. rhoi < optable(1,1,1)) then
    call warning('getintenerg_opdep','rhoi out of range',var='rhoi',val=rhoi)
 elseif (Teqi > optable(1,ny,2) .or. Teqi < optable(1,1,2)) then
    call warning('getintenerg_opdep','Ti out of range',var='Ti',val=Teqi)
 endif

 ! interpolate through optable to obtain equilibrium internal energy
 irho = search_table(optable(:,1,1),nx,rhoi)
 itemp = search_table(optable(irho,:,2),ny,Teqi)

 m = (optable(irho,itemp,3) - optable(irho,itemp+1,3))/(optable(irho,itemp,2) - optable(irho,itemp+1,2))
 c = optable(irho,itemp+1,3) - m*optable(irho,itemp+1,2)
 u1 = m*Teqi + c

 itemp = search_table(optable(irho+1,:,2),ny,Teqi)

 m = (optable(irho+1,itemp,3) - optable(irho+1,itemp+1,3))/&
      (optable(irho+1,itemp,2) - optable(irho+1,itemp+1,2))
 c = optable(irho+1,itemp+1,3) - m*optable(irho+1,itemp+1,2)
 u2 = m*Teqi + c

 m = (u2 - u1)/(optable(irho+1,1,1)-optable(irho,1,1))
 c = u2 - m*optable(irho+1,1,1)

 ueqi = m*rhoi + c
end subroutine getintenerg_opdep

!
! Binary search given array
!
integer function search_table(array,arrlen,invalue) result(outind)
 real, intent(in)    :: array(:),invalue
 integer, intent(in) :: arrlen
 integer            :: leftind,rightind,midind

 leftind = 1; rightind = arrlen
 do
    if (rightind - leftind == 1 .or. rightind == leftind) then
       outind = leftind
       return
    endif
    midind = (rightind - leftind) / 2 + leftind
    if (invalue == array(midind) ) then
       outind = midind
       return
    endif
    if (invalue < array(midind)) then
       rightind = midind
    else
       leftind = midind
    endif
 enddo

end function search_table

!
! Calculate factor for FLD
!
subroutine get_k_fld(rhoi,eni,i,ki,Ti)
 use units,    only:unit_density,unit_ergg,unit_opacity,get_radconst_code,get_c_code
 real,intent(in)    :: rhoi,eni
 integer,intent(in) :: i
 real               :: kappaBar,gmwi,kappaPart,eni_ergg,rhoi_g
 real,intent(out)   :: ki,Ti

 if (lambda_FLD(i) == 0d0) then
    ki = 0.
 else
    eni_ergg = eni*unit_ergg
    rhoi_g = rhoi*unit_density
    call getopac_opdep(eni_ergg,rhoi_g,kappaBar,kappaPart,Ti,gmwi)
   kappaPart = kappaPart/unit_opacity
    ! k = 16 sigma lambda T^3/(kappa rho) with sigma = a c/4, all in code units
    ki = 4d0*get_c_code()*get_radconst_code()*lambda_FLD(i)*Ti**3 /rhoi/kappaPart
    if (isnan(ki)) then
       print *, "WARNING k isnan, lambda_FLDi,Ti,rhoi,kappaPart", &
             lambda_FLD(i), Ti, rhoi,kappaPart
    endif
 endif
end subroutine get_k_fld

!
! Floored power-law temperature profile (MS20-style)
!
real function get_T_profile(r)
   use units,   only:udist
   use physcon, only:au
   real, intent(in) :: r          ! radius in code distance units
   real :: Rau, q_eff
   Rau   = r*udist/au             ! robust to any dist_unit
   q_eff = merge(qprofile, 0.35, qprofile > 0.)   ! slope: T proportional to R^(-2*q_eff)
   get_T_profile = ( T0_prof**n_prof * (Rau**2 + R0_prof**2)**(-n_prof*q_eff) &
                     + T_bg_prof**n_prof )**(1./n_prof)
end function get_T_profile

!
! Irradiation temperature at 1 AU from the stellar luminosity, for lumdisc=3.
!
!   sigma_SB T0^4 = L / (16 pi (1 AU)^2)
!
! The 16pi normalisation is the equilibrium temperature of an isothermal grain,
! T = 279 K (L/Lsun)^(1/4) (R/AU)^(-1/2), and matches the lumdisc=1 runtime
! floor in cooling_radapprox.f90.  get_cs_from_lum / get_T_from_lum /
! get_u_stamatellos in set_disc.f90, which set the legacy lumdisc=1 initial
! conditions, use 4pi (a flat absorbing surface) and are 4**0.25 = 1.414 hotter.
! That inconsistency does not reach lumdisc=3, because there both the IC and
! the runtime floor come from get_T_profile.
!
! Anchored on au rather than udist because T0_prof is by definition the value at
! 1 AU, and get_T_profile converts its argument to AU regardless of dist_unit.
!
! L = 0.035 Lsun (a young brown dwarf) gives 121 K.
!
real function get_T0_from_lum(L_star)
 use physcon, only:steboltz,solarl,pi,au
 real, intent(in) :: L_star

 get_T0_from_lum = ( L_star*solarl/(16.*pi*steboltz*au*au) )**0.25
end function get_T0_from_lum

!-----------------------------------------------------------------------
!+
!   Persist the floored power-law temperature profile parameters (mode
!   iprofile=2) in the dump header, so a restart uses exactly the values
!   the IC was built with rather than whatever is (or isn't) in the .in
!   file.  No-op (writes nothing) for legacy iprofile=1.
!+
!-----------------------------------------------------------------------
subroutine write_headeropts_flooredprof(hdr,ierr)
 use dump_utils, only:dump_h,add_to_rheader,add_to_iheader
 type(dump_h), intent(inout) :: hdr
 integer,      intent(inout) :: ierr

 if (iprofile /= 2) return
 call add_to_iheader(iprofile,  'iprofile', hdr, ierr)
 call add_to_rheader(T0_prof,   'T0_prof',  hdr, ierr)
 call add_to_rheader(n_prof,    'nprof',    hdr, ierr)
 call add_to_rheader(R0_prof,   'R0_prof',  hdr, ierr)
 call add_to_rheader(T_bg_prof, 'Tinf',     hdr, ierr)
 call add_to_rheader(qprofile,  'qprofile', hdr, ierr)
 if (L_star_prof >= 0.) call add_to_rheader(L_star_prof, 'L_star', hdr, ierr)
end subroutine write_headeropts_flooredprof

!-----------------------------------------------------------------------
!+
!   Restores the floored power-law temperature profile parameters from
!   the dump header.  iprofile is extracted first; if absent (legacy
!   dump, written before this feature existed) it is left at its
!   compiled-in default (1) and nothing else is read.
!+
!-----------------------------------------------------------------------
subroutine read_headeropts_flooredprof(hdr)
 use dump_utils, only:dump_h,extract,i_real
 type(dump_h), intent(in) :: hdr
 integer :: ierr
 real    :: rval

 ierr = 0
 call extract('iprofile', iprofile, hdr, ierr, default=iprofile)
 if (iprofile == 2) then
    ierr = 0;  call extract('T0_prof',  T0_prof,   hdr, ierr)
    ierr = 0;  call extract('nprof',    n_prof,    hdr, ierr)
    ierr = 0;  call extract('R0_prof',  R0_prof,   hdr, ierr)
    ierr = 0;  call extract('Tinf',     T_bg_prof, hdr, ierr)
    ierr = 0;  call extract('qprofile', qprofile,  hdr, ierr)
    ierr = 0;  call extract('L_star', rval, hdr%realvals, hdr%realtags, hdr%nums(i_real), ierr, q=.true., default=-1.)
    L_star_prof = rval
 endif
end subroutine read_headeropts_flooredprof

end module eos_stamatellos

