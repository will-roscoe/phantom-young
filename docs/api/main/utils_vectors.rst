.. phantom-doc: hand-written

utils_vectors
=============

Overview
--------

The ``vectorutils`` module provides utility routines for vector and
:math:`3 \times 3` matrix operations used throughout Phantom. Public
routines include: ``minmaxave`` (minimum, maximum, and mean of an array),
``cross_product3D`` (3D cross product :math:`\mathbf{a} \times \mathbf{b}`),
``curl3D_epsijk`` (curl using the Levi-Civita tensor), ``det`` (3x3 matrix
determinant), ``matrixinvert3D`` (3x3 matrix inverse by Cramer's rule),
``rotatevec`` (rotate a vector by a given angle about a given axis),
``unitvec`` (normalise a vector), ``mag`` (vector magnitude), and
``make_perp_frame`` (construct an orthonormal frame given one axis).

These utilities are used in the MHD, gravity, accretion disc, and GR modules
for computing curl of the magnetic field, gravitational multipoles, disc
orientation vectors, and frame-dragging rotations.

Physical & Mathematical Description
------------------------------------

The 3D cross product is :math:`(\mathbf{a}\times\mathbf{b})_i =
\epsilon_{ijk} a_j b_k`, where :math:`\epsilon_{ijk}` is the Levi-Civita
symbol. The :math:`3\times 3` matrix inverse uses the cofactor formula
:math:`A^{-1} = C^T / \det A`, where :math:`C_{ij}` is the :math:`(i,j)`
cofactor. The ``make_perp_frame`` routine constructs an orthonormal basis
:math:`\{\hat{\mathbf{e}}_1, \hat{\mathbf{e}}_2, \hat{\mathbf{e}}_3\}`
given :math:`\hat{\mathbf{e}}_3` by finding a vector that is not parallel
to :math:`\hat{\mathbf{e}}_3` and applying Gram-Schmidt orthogonalisation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_vectors.f90
