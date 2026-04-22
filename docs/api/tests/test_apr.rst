.. phantom-doc: hand-written

test_apr
========

Overview
--------

The ``test_apr`` module (Fortran module ``testapr``) contains unit tests for the Adaptive
Particle Refinement (APR) framework in Phantom. APR allows the simulation to
dynamically split high-resolution regions into finer particles and merge them back when
resolution is no longer needed, without altering the global hydrodynamics. The tests
verify that the splitting and merging operations conserve mass, linear momentum, angular
momentum, and total energy to within floating-point precision.

The test initialises a uniform particle distribution in a periodic box, designates a
spherical refinement region, calls ``update_apr`` to trigger the splitting process, and
then checks that the conserved quantities match their pre-split values to within tight
absolute tolerances. A companion routine ``setup_apr_region_for_test`` is exported for
re-use by the gravity test module so that APR compatibility with the tree solver can also
be validated.

This module requires the code to be compiled with the ``-DAPR`` preprocessor flag; if
the flag is absent the test is skipped with an informational message and no failure is
recorded. The test only runs when ``use_apr`` is ``.true.`` at runtime.

Physical & Mathematical Description
------------------------------------

Particle splitting must satisfy strict conservation laws. The test checks that total
mass :math:`M = \sum_i m_i`, linear momentum :math:`\mathbf{p} = \sum_i m_i \mathbf{v}_i`,
angular momentum :math:`\mathbf{L} = \sum_i m_i (\mathbf{r}_i \times \mathbf{v}_i)`,
and total energy :math:`E = E_{\rm kin} + E_{\rm therm}` are each preserved to within
the tolerances ``tolmom = 2e-15``, ``tolang``, and ``tolen``, which are set to values
consistent with double-precision round-off. The merging pass is verified by the same
criteria applied in reverse.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_apr.f90
