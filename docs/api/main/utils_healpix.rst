.. phantom-doc: hand-written

utils_healpix
=============

Overview
--------

The ``healpix`` module provides the HEALPix sphere-pixelisation type
definitions used by Phantom's ray-tracer and stellar wind modules. HEALPix
(Hierarchical Equal Area isoLatitude Pixelization; Gorski et al. 2005)
divides the sphere into :math:`12 N_\text{side}^2` equal-area pixels
arranged in rings of constant latitude, providing a uniform angular coverage
that is well suited to optical-depth integration along radial rays.

The module defines the standard HEALPix precision parameters: ``i4b``
(4-byte integer), ``i8b`` (8-byte integer), ``sp`` (single-precision real),
``dp`` (double-precision real), ``lgt`` (logical), ``spc`` and ``dpc``
(single and double complex). These are imported by the ``raytracer`` module
and any other module that uses HEALPix-based angular discretisation. The
version string ``healpix_version = '3.80'`` identifies the HEALPix release
from which the type definitions are taken.

Physical & Mathematical Description
------------------------------------

HEALPix pixels are defined such that each pixel subtends the same solid angle
:math:`\Omega_\text{pix} = 4\pi / N_\text{pix}` where
:math:`N_\text{pix} = 12 N_\text{side}^2`. This equal-area property ensures
that ray-tracing integrals over the sphere can be computed as simple sums
without angular-area weighting. The number of rays per unit solid angle is
uniform, which is important for accurate optical-depth calculations in
stellar wind simulations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_healpix.f90
