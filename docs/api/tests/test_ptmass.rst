.. phantom-doc: hand-written

test_ptmass
===========

Overview
--------

The ``test_ptmass`` module (Fortran module ``testptmass``) is the most comprehensive test
module in the Phantom suite, exercising the sink-particle (point-mass) framework across
many physical scenarios. Sub-tests are selected via the string argument: ``ptmassbinary``
tests a two-sink binary integration, ``ptmassaccrete`` tests particle accretion onto a
sink, ``ptmasscreat`` tests sink creation from an infalling cloud, ``ptmasssoften`` checks
the force softening kernel at small separations, ``ptmassmerge`` tests sink merging,
``chinesecoin`` tests a special orbit (the Chinese coin or figure-eight orbit),
``ptmassHII`` tests HII region feedback, ``ptmassSDAR`` tests the Singly-Degenerate
Accretion Rate model, and ``ptmassgenrel`` tests GR binary integration.

For the binary integration test the leapfrog stepper is run for multiple orbital periods
and the orbital energy :math:`E = \tfrac{1}{2}\mu v^2 - GMm/r` and angular momentum
:math:`L = \mu r v_\perp` are monitored. The accretion test injects SPH particles toward
a sink with a prescribed infall velocity and checks that the accreted mass equals the
expected value. The creation test verifies that a sink is created when the local density
exceeds the threshold and that its mass and position are set correctly.

Physical & Mathematical Description
------------------------------------

The binary orbit energy error :math:`|(E - E_0)/E_0|` and angular momentum error
:math:`|(L - L_0)/L_0|` are required to be below :math:`10^{-5}` per orbit when using
the fourth-order integrator (``use_fourthorder = .true.``). For the accretion test the
accreted mass is compared to the analytic expectation :math:`M_{\rm acc} = \dot{M}\,\Delta t`
to within one particle mass. The softening check verifies that the force at :math:`r = 0`
is exactly zero and that the gradient is smooth to within :math:`10^{-10}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_ptmass.f90
