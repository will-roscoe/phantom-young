.. phantom-doc: hand-written

test_step
=========

Overview
--------

The ``test_step`` module (Fortran module ``teststep``) tests the leapfrog time integrator
(``step_lf_global``) and the periodic boundary-crossing logic in Phantom. The test
requires ``-DPERIODIC``; without it the test body is compiled away and no checks are
performed. A uniform distribution of particles is set up in a periodic cube, initial
velocities are assigned to cause a known fraction of particles to cross the periodic
boundary within one step, and the integrator is advanced for a single leapfrog step.

After the step the test verifies that all particles still lie within the periodic domain,
that the total energy (kinetic plus potential) is conserved to within the expected
leapfrog error :math:`O(\Delta t^2)`, and that the boundary-crossing logic has correctly
wrapped the particle positions without corrupting the neighbour list or the smoothing
lengths. When compiled with ``-DIND_TIMESTEPS`` the test additionally checks that the
bin assignment is consistent with the per-particle timesteps after the step.

Physical & Mathematical Description
------------------------------------

The leapfrog (kick-drift-kick) integrator is second-order accurate in time, so the
energy error after one step should scale as :math:`\Delta E / E \sim (C_{\rm force}
\Delta t_{\rm force})^2` where :math:`C_{\rm force}` is the Courant-like force accuracy
parameter. The test checks that the relative energy error is below ``tol`` (a few
multiples of :math:`10^{-4}` depending on the step size chosen). Periodic boundary
crossing is checked by verifying that no particle coordinate exceeds the domain size.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_step.F90
