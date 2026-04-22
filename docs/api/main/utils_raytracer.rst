.. phantom-doc: hand-written

utils_raytracer
===============

Overview
--------

The ``raytracer`` module implements radial ray-tracing for computing optical
depths at the location of each SPH particle in Phantom's stellar wind
simulations. Starting from the primary star, rays are cast outward in the
directions defined by a HEALPix sphere tessellation; the optical depth
:math:`\tau` along each ray is accumulated by summing the opacity
contributions from all SPH particles encountered along the ray. The optical
depths at arbitrary particle positions are then obtained by interpolating
between the tabulated ray values.

The module supports both single-star and binary-star wind geometries. The
main public routine ``get_all_tau`` calls the neighbour search from
``neighkdtree`` to find particles along each ray, integrates the optical
depth, and interpolates the result to all particle positions. The ray
directions are drawn from the HEALPix tessellation provided by ``healpix``,
which ensures uniform angular coverage.

The algorithm is described in Esseldeurs et al. (2023, A&A, 674, A122) and
is valid only for outward-flowing winds from a central source. The module
issues a warning when called for setups other than the Phantom wind
configuration.

Physical & Mathematical Description
------------------------------------

The optical depth along a ray in direction :math:`\hat{\mathbf{n}}` from the
star at position :math:`\mathbf{r}_*` to particle :math:`i` at
:math:`\mathbf{r}_i` is

.. math::

   \tau_i = \int_0^{|\mathbf{r}_i - \mathbf{r}_*|}
   \kappa(\mathbf{r}_* + s\hat{\mathbf{n}})\,\rho(
   \mathbf{r}_* + s\hat{\mathbf{n}})\, ds,

where :math:`\kappa` is the dust opacity per unit mass. This integral is
approximated as a sum over SPH particles near the ray using the SPH kernel
as the weight function.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_raytracer.f90
