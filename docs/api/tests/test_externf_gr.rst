.. phantom-doc: hand-written

test_externf_gr
===============

Overview
--------

The ``test_externf_gr`` source file contains unit tests for the General Relativistic
external force routines in Phantom, specifically those in ``extern_gr`` that compute
metric-dependent accelerations in curved spacetime. These tests verify that the GR
external potential gradient and the associated four-acceleration are consistent with the
metric chosen at runtime (Schwarzschild or Kerr), exercising the interface between the
external-force framework and the GR metric machinery.

This file shares the Fortran module name ``testexternf`` with the Newtonian external
force test file ``test_externf.f90``. Because the Fortran autodoc parser cannot
distinguish between two modules of the same name in the same source tree, this file is
excluded from the automatic API index and its documentation is provided here manually.
The physical tests performed are analogous to those in ``test_externf``: a numerical
finite-difference gradient of the GR potential is compared to the analytic geodesic
acceleration, with tolerances appropriate for the chosen metric.

Physical & Mathematical Description
------------------------------------

In GR the external acceleration for a test particle follows from the geodesic equation
:math:`Du^\mu/d\tau = -\Gamma^\mu_{\nu\rho} u^\nu u^\rho + f^\mu_{\rm ext}`, where
:math:`f^\mu_{\rm ext}` is the external four-force per unit rest mass. The test checks
the spatial components :math:`f^i_{\rm ext}` against a numerical gradient of the metric
potential, with tolerances set to match the finite-difference truncation error at the
step size used, typically :math:`\sim 10^{-4}` in code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   Autodoc is not available for this file. The Fortran module ``testexternf`` is defined
   in both ``test_externf.f90`` and ``test_externf_gr.f90``; the parser can only index
   one of them. The source file ``src/tests/test_externf_gr.f90`` must be consulted
   directly for the full API.
