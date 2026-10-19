!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2026 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module testgeometry
!
! Unit tests of the geometry module
!
! :References:
!
! :Owner: Daniel Price
!
! :Runtime parameters: None
!
! :Dependencies: geometry, icosahedron, io, testutils
!
 use testutils, only:checkval,update_test_scores
 use io,        only:id,master
 implicit none
 public :: test_geometry

 private

contains
!--------------------------------------------
!+
!  Unit tests of the geometry module
!+
!--------------------------------------------
subroutine test_geometry(ntests,npass)
 use geometry, only:maxcoordsys,coord_transform,labelcoordsys,vector_transform,&
                    get_coord_limits,small_number,igeom_planetwake
 integer, intent(inout) :: ntests,npass
 real    :: xin(3),xout(3),xtmp(3),tol
 real    :: vecin(3),vecout(3),vectmp(3),xmin(3),xmax(3),rad
 integer :: igeom,ndim,ierr,ndiff(2),itest

 if (id==master) write(*,"(/,a)") '--> TESTING GEOMETRY MODULE'
!
!--check that forward followed by inverse transform
!  returns original result
!
 ndim = 3
 xin   = (/5.,6.,7./)
 vecin = (/2.,3.,4./)

 do itest=1,2
    select case(itest)
    case(2)
       xin = (/0.,0.,0./)
       if (id==master) write(*,"(/,a)") '--> checking transforms for coords and vectors are reversible at r=0'
    case default
       if (id==master) write(*,"(/,a)") '--> checking transforms for coords and vectors are reversible'
    end select
    ndiff = 0
    do igeom=1,maxcoordsys
       ! forward
       call coord_transform(xin,ndim,1,xout,ndim,igeom,ierr)
       call vector_transform(xin,vecin,ndim,1,vecout,ndim,igeom,ierr)

       ! reverse
       call coord_transform(xout,ndim,igeom,xtmp,ndim,1,ierr)
       call vector_transform(xout,vecout,ndim,igeom,vectmp,ndim,1,ierr)

       tol = small_number
       if (igeom==igeom_planetwake) tol = 1e-13
       call checkval(3,xtmp,xin,tol,ndiff(1),trim(labelcoordsys(igeom)))
       call checkval(3,vectmp,vecin,tol,ndiff(2),trim(labelcoordsys(igeom)))
    enddo
    call update_test_scores(ntests,ndiff,npass)
 enddo
!
! check that routines that allegedly do the same thing actually do
!
 if (id==master) write(*,"(/,a)") '--> testing get_coord_limits matches coord_transform'
 ndiff = 0
 do igeom=1,maxcoordsys
    xmin = 0.
    xmax = 1.
    rad = 0.1
    call get_coord_limits(rad,xin,xout,xmin,xmax,igeom)
    call coord_transform(xin,ndim,1,xtmp,ndim,igeom,ierr)
    call checkval(3,xout,xtmp,tol,ndiff(1),trim(labelcoordsys(igeom)))
 enddo
 call update_test_scores(ntests,ndiff,npass)

 call test_icosahedron(ntests,npass)

 if (id==master) write(*,"(/,a)") '<-- GEOMETRY TEST COMPLETE'

end subroutine test_geometry

!--------------------------------------------
!+
!  The 20 icosahedron face matrices are rotations
!  and pixel2vector returns unit vectors
!+
!--------------------------------------------
subroutine test_icosahedron(ntests,npass)
 use icosahedron, only:compute_matrices,compute_corners,pixel2vector
 integer, intent(inout) :: ntests,npass
 real    :: R(0:19,3,3),v(0:11,3),M(3,3),ident(3,3),vec(3),errmax(2)
 integer :: n,i,ipix,ndiff(2)
 integer, parameter :: ires = 4

 if (id==master) write(*,"(/,a)") '--> checking icosahedron rotation matrices are orthogonal'
 call compute_matrices(R)
 call compute_corners(v)
 ident = 0.
 do i=1,3
    ident(i,i) = 1.
 enddo
 errmax = 0.
 do n=0,19
    M = R(n,:,:)
    errmax(1) = max(errmax(1),maxval(abs(matmul(M,transpose(M)) - ident)))
 enddo
 do ipix=0,20*2*ires*(ires-1)+11
    call pixel2vector(ipix,ires,R,v,vec)
    errmax(2) = max(errmax(2),abs(sqrt(dot_product(vec,vec)) - 1.))
 enddo
 call checkval(errmax(1),0.,1.e-12,ndiff(1),'max |R R^T - I|')
 call checkval(errmax(2),0.,1.e-12,ndiff(2),'max ||pixel2vector| - 1|')
 call update_test_scores(ntests,ndiff,npass)

end subroutine test_icosahedron

end module testgeometry
