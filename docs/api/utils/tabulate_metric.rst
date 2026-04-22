.. phantom-doc: hand-written

tabulate_metric
===============

Overview
--------

``tabulate_metric`` is a utility program that tabulates the components of a general relativistic spacetime metric and Christoffel symbols on a 3D Cartesian grid for use in the Einstein Toolkit coupling. It calls the ``metric_et_utils`` routines to initialise the grid, fill it with metric components computed from the analytic metric (e.g. Kerr-Schild), and write the result to a file.

The output file (default ``tabuled_metric.dat``) stores the covariant metric tensor :math:`g_{\mu\nu}` and the Christoffel symbols :math:`\Gamma^\mu_{\nu\rho}` at each grid point, enabling Phantom to interpolate metric quantities without recomputing them at every time step when coupled to the Einstein Toolkit.

This pre-tabulation approach is critical for performance in Phantom-ET coupled simulations where metric evaluation is expensive, replacing on-the-fly metric computation with fast grid interpolation.

Physical & Mathematical Description
------------------------------------

The covariant metric components :math:`g_{\mu\nu}(x^k)` are computed at each grid point from the analytic Kerr-Schild (or other chosen) metric and stored in a binary file. The Christoffel symbols are :math:`\Gamma^\mu_{\nu\rho} = \frac{1}{2} g^{\mu\sigma} (\partial_\nu g_{\sigma\rho} + \partial_\rho g_{\sigma\nu} - \partial_\sigma g_{\nu\rho})`, computed via finite differencing of the tabulated metric at adjacent grid points.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/tabulate_metric.f90
