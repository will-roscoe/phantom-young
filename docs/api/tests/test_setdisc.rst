.. phantom-doc: hand-written

test_setdisc
============

Overview
--------

The ``test_setdisc`` module (Fortran module ``testsetdisc``) tests the ``set_disc``
routine that initialises Keplerian disc particle distributions in Phantom. The test
requires non-periodic boundary conditions (``periodic = .false.``); if the code is
compiled with ``-DPERIODIC`` the test is skipped. Units are set to solar mass and AU
before the disc is set up.

The primary sub-test calls ``set_disc`` with a prescribed surface density power law,
then computes SPH derivatives and checks two things: (i) that the radial component of
the centrifugal acceleration balances the gravitational plus pressure force at each
particle location (i.e. the disc is in centrifugal balance), and (ii) that the surface
density profile recovered from the particle distribution matches the input power law to
within the SPH truncation error. The test also calls ``check_setup`` to verify that the
initial conditions pass all the internal consistency checks.

Physical & Mathematical Description
------------------------------------

Centrifugal balance requires
:math:`v_\phi^2 / r = GM/r^2 + (1/\rho)\partial P/\partial r`
in the disc midplane. The test evaluates the left and right sides of this equation for
each particle using the SPH pressure gradient from ``fxyzu`` and checks their relative
difference with tolerance ``tol = 2e-5``. The surface density power-law check uses a
buffered comparison of the local surface density to the analytic expression
:math:`\Sigma(r) = \Sigma_0 (r/r_0)^{-p}` with a relative tolerance that depends on
particle number.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_setdisc.f90
