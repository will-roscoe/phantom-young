.. phantom-doc: hand-written

test_orbits
===========

Overview
--------

The ``test_orbits`` module (Fortran module ``testorbits``) tests the Keplerian orbital
mechanics utilities in ``utils_orbits.f90``, which are used throughout Phantom for binary
system setup, flyby calculations, and orbital element extraction from particle data. The
module runs seven sub-tests: circular orbit elements, true anomaly from separation,
time to reach a given separation on an ellipse, flyby-to-orbital-element conversion,
escape velocity, a simple binary setup with ``set_binary``, and a full binary setup with
all six orbital elements specified.

Each sub-test uses a known analytic result as the reference. For example, the circular
orbit test places a test particle at separation :math:`a = 2.5` with :math:`\mu = 1.0`,
verifies that the eccentricity is zero, the semi-major axis is :math:`a`, and the period
is :math:`T = 2\pi\sqrt{a^3/\mu}` to within the tolerance ``tol = 2e-14``. The flyby
conversion test verifies that the hyperbolic orbital elements recovered from a flyby
trajectory match the input parameters to the same precision.

Physical & Mathematical Description
------------------------------------

Keplerian orbital elements are related by the vis-viva equation
:math:`v^2 = \mu (2/r - 1/a)` and Kepler's third law :math:`T = 2\pi\sqrt{a^3/\mu}`.
All seven sub-tests use the analytic tolerance ``tol = 2e-14``, which corresponds to
approximately ten times double-precision machine epsilon, accommodating the finite-precision
evaluation of trigonometric and square-root functions in the orbital element extraction
routines.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_orbits.f90
