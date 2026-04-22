.. phantom-doc: hand-written

test_radiation
==============

Overview
--------

The ``test_radiation`` module (Fortran module ``testradiation``) tests the radiation
hydrodynamics solver in Phantom, which implements flux-limited diffusion (FLD) coupled to
the gas energy equation. The module requires ``RADIATION=yes`` at compile time; without
it the test is skipped. Units are set to AU and solar mass. The module runs three main
sub-tests: ``test_exchange_terms`` checks the gas–radiation energy exchange coupling in
both explicit and implicit modes; ``test_implicit_matches_explicit`` verifies that the
implicit FLD solver reproduces the explicit result in the optically thin limit; and
``test_radiation_diffusion`` compares the numerical diffusion solution against the analytic
1D slab solution for both explicit and implicit radiation transport.

The exchange-term test sets a radiation energy density and a gas temperature, calls the
exchange routine for one timestep, and checks that the equilibrium condition
:math:`E_{\rm rad} = a_{\rm rad} T^4` is satisfied after the exchange. The diffusion
test initialises a Gaussian radiation pulse in a 3D periodic box and integrates for
several diffusion times, checking that the pulse width evolves as
:math:`\sigma(t) = \sqrt{\sigma_0^2 + 2D t}` where :math:`D = c/(3\kappa\rho)`.

Physical & Mathematical Description
------------------------------------

The flux-limited diffusion equation is
:math:`\partial E/\partial t = \nabla\cdot(D_{\rm FLD} \nabla E) - c\kappa\rho E + c\kappa\rho a_{\rm rad} T^4`,
where :math:`D_{\rm FLD} = \lambda c / (\kappa\rho)` is the FLD diffusion coefficient and
:math:`\lambda` is the flux limiter. The diffusion test checks the Gaussian pulse width to
within :math:`1\%` after one diffusion time, with the tolerance ``tol_rad = 1e-6`` used
for the implicit solver convergence criterion.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_radiation.f90
