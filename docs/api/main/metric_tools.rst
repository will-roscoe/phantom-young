.. phantom-doc: hand-written

Metric Tools
============

Overview
--------

The ``metric_tools`` module is the central dispatch layer for metric access in Phantom's GR
framework. It provides a coordinate-independent interface to the covariant and contravariant
metric tensors :math:`g_{\mu\nu}` and :math:`g^{\mu\nu}`, their spatial derivatives, and
utility routines for packing and unpacking metric data into the per-particle storage arrays
used throughout the code.

All other GR modules — ``extern_gr``, ``utils_gr``, ``tmunu2grid``, etc. — obtain the
metric exclusively through this module, never by calling the individual metric backends
(``metric_minkowski``, ``metric_schwarzschild``, etc.) directly. The backend is selected at
compile time by linking the appropriate ``metric_*.f90`` file; ``metric_tools`` remains
identical for all choices.

The public parameter ``imetric`` is re-exported from the underlying metric module and
identifies the active metric type (values 1–7 correspond to Minkowski, Schwarzschild, Kerr,
Kerr-Schild, binary BH, FLRW, and Einstein Toolkit metrics respectively). The parameter
``icoordinate`` is hardwired to ``icoord_cartesian`` for all production use in Phantom.

The module provides two strategies for the contravariant metric: analytic inversion (where
provided by the metric backend) and numerical inversion via the ``inv4x4`` utility. The
internal switch ``useinv4x4 = .true.`` means the 4x4 matrix inverse is always used to
obtain :math:`g^{\mu\nu}`, guaranteeing consistency with the covariant form at the cost of
negligible additional computation.

For metrics whose Cartesian derivatives do not have analytic expressions (Kerr-Schild and
binary BH), ``get_metric_derivs`` automatically falls back to second-order centred
finite-difference numerical derivatives via ``numerical_metric_derivs``.

Physical & Mathematical Description
-------------------------------------

For a given metric backend, ``get_metric`` returns :math:`g_{\mu\nu}` and
:math:`g^{\mu\nu}` satisfying:

.. math::

   g_{\mu\alpha} g^{\alpha\nu} = \delta^\nu_\mu

together with :math:`\sqrt{-g}`, the square root of minus the determinant of the metric.

The packed per-particle metric array has dimensions ``metrici(0:3, 0:3, 2)`` where slice
``1`` stores :math:`g_{\mu\nu}` and slice ``2`` stores :math:`g^{\mu\nu}`. The
``unpack_metric`` subroutine extracts these, along with derived quantities needed by the
3+1 ADM decomposition:

.. math::

   \alpha = \frac{1}{\sqrt{-g^{tt}}}, \qquad
   \beta^i = -\frac{g^{ti}}{g^{tt}}, \qquad
   \gamma_{ij} = g_{ij}

where :math:`\alpha` is the lapse function and :math:`\beta^i` is the shift vector.

The numerical metric derivatives use centred differences with step size
:math:`\delta = 10^{-8}`:

.. math::

   \frac{\partial g_{\mu\nu}}{\partial x^i} \approx
   \frac{g_{\mu\nu}(\mathbf{x} + \delta \hat{e}_i) - g_{\mu\nu}(\mathbf{x} - \delta \hat{e}_i)}{2\delta}

References
----------

No phantom.bib entries apply. The metric packing convention follows Liptai & Price (2019),
MNRAS 485, 819 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/metric_tools.f90
