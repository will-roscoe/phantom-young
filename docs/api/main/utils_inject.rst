.. phantom-doc: hand-written

utils_inject
============

Overview
--------

The ``injectutils`` module provides geometric utility routines for injection
schemes that place particles on geodesic spheres. It is used primarily by
the stellar wind injection modules (``inject_wind``, ``inject_BHL``) that
need to inject particles uniformly over a spherical surface with controlled
spacing between injection spheres and between particles on each sphere.

The key public function ``get_sphere_resolution`` solves a cubic equation to
find the integer resolution parameter :math:`q` of a geodesic sphere (based
on a subdivided icosahedron) such that the ratio of the inter-sphere spacing
to the inter-particle spacing matches a desired value. The golden ratio
:math:`\phi = (1+\sqrt{5})/2` is used in the icosahedron geometry. A
companion routine computes the total number of particles on a sphere of
resolution :math:`q` as :math:`20q^3 - 30q^2 + 16q - 3`.

Physical & Mathematical Description
------------------------------------

A geodesic sphere of resolution :math:`q` constructed by subdividing an
icosahedron has :math:`N(q) = 20q^3 - 30q^2 + 16q - 3` vertices. Given
a desired particle mass :math:`m` and injection volume flux
:math:`\dot{M}/\rho v_\text{inj}`, the required ratio
:math:`m / (M v_\text{inj} / \dot{M})` determines :math:`N(q)` and hence
:math:`q`. The cubic equation :math:`N(q) = N_\text{target}` is solved
analytically using the real cube root of the discriminant.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_inject.f90
