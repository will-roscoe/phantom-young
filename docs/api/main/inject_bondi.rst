.. phantom-doc: hand-written

inject_bondi
============

Overview
--------

The ``inject_bondi`` module (module name ``inject``, ``inject_type = 'grbondi'``)
injects particles to set up a spherical Bondi wind or accretion flow test.
Particles are injected on concentric geodesic spheres at radius ``rin`` using
icosahedron-based sphere tessellations. The module uses the analytic Bondi
solution from ``bondiexact`` to set particle velocities, densities, and
thermodynamic states at the injection radius, providing a self-consistent
inflow boundary condition.

Runtime parameters control the desired sphere-spacing to particle-spacing
ratio (``drdp``), the number of boundary spheres (``iboundspheres``), and
the solution type (``isol = 1`` for the geodesic sphere approach, ``isol = 2``
for the sonic-point solution). This injection module is used for testing and
validating the Phantom SPH solver against the analytic Bondi solution.

Physical & Mathematical Description
------------------------------------

Particles are injected with velocity, density, and internal energy set by
the non-relativistic Bondi solution at radius :math:`r_\text{in}`:
:math:`v(r_\text{in})`, :math:`\rho(r_\text{in})`, and
:math:`u(r_\text{in}) = c_{s,\text{in}}^2 / (\gamma(\gamma-1))`.
The spacing between consecutive injection spheres equals the inter-particle
spacing, ensuring a constant and uniform mass flux :math:`\dot{M} = 4\pi
\rho v r^2`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
