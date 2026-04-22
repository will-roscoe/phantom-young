.. phantom-doc: hand-written

test_setstar
============

Overview
--------

The ``test_setstar`` module (Fortran module ``testsetstar``) tests the stellar setup
and stellar relaxation routines in Phantom. The test requires ``gravity`` to be enabled;
if the code is compiled without self-gravity the test is skipped. The module runs two
sub-tests: ``test_get_mass_coord`` verifies the Lagrangian mass-coordinate extraction
utility used in ``relax_star``, and ``test_polytrope`` sets up a polytropic stellar
model and checks its density and pressure profiles.

The mass-coordinate test creates a sorted radial particle distribution, calls
``get_mass_coord`` to compute the enclosed mass as a function of radius, and verifies
that the returned values match the analytic result :math:`M(r) = (4\pi/3)\rho_0 r^3`
for a uniform sphere to within a relative tolerance of :math:`10^{-14}`. The polytrope
test sets up an :math:`n=1.5` polytrope using ``set_star`` and checks that the central
density and stellar radius from the Lane-Emden solution are reproduced to within a few
percent of the analytic values.

Physical & Mathematical Description
------------------------------------

The Lane-Emden equation for an :math:`n = 3/2` polytrope has the numerical solution
:math:`\xi_1 = 3.65375` (dimensionless stellar radius) and :math:`\theta'(\xi_1) = -0.20330`.
The dimensional central density is :math:`\rho_c = \rho_{\rm mean} \times 5.991` and the
stellar radius is :math:`R = \xi_1 [(n+1)K/(4\pi G)]^{1/2} \rho_c^{(1/n-1)/2}`. The
test checks these values to within the :math:`O(h^2)` error of the SPH density estimate.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_setstar.f90
