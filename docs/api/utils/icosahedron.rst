.. phantom-doc: hand-written

icosahedron
===========

Overview
--------

``icosahedron`` is a Fortran 90 conversion of Max Tegmark's icosahedron sphere pixelisation package. It provides routines for dividing the sphere into approximately equal-area pixels using icosahedral symmetry, which is used in Phantom for generating uniform distributions of injection points on a spherical surface (e.g. for spherical wind injection).

The module provides ``pixel2vector`` (convert a pixel index to a 3D unit vector), ``compute_corners`` (compute the 12 icosahedron vertex directions), and ``compute_matrices`` (compute rotation matrices for the 20 triangular faces). The resolution parameter ``ires`` controls the number of pixels: the sphere is divided into :math:`10 \times 4^{i_\mathrm{res}} + 2` pixels.

Modified by Daniel Price (19 December 2012) to use Fortran 90 constructs and to replace ``pause`` statements with error calls for integration into Phantom. The package is widely used in CMB map-making and is well suited to generating uniform spherical point distributions.

Physical & Mathematical Description
------------------------------------

At resolution level :math:`i_\mathrm{res}`, the sphere is divided into :math:`N_\mathrm{pix} = 10 \times 4^{i_\mathrm{res}} + 2` pixels of approximately equal solid angle :math:`\Omega_\mathrm{pix} = 4\pi / N_\mathrm{pix}`. The pixel centres are arranged by subdividing the 20 equilateral triangles of the icosahedron each into :math:`4^{i_\mathrm{res}}` sub-triangles and projecting the barycentres onto the unit sphere.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/icosahedron.f90
