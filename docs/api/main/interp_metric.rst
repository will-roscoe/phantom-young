.. phantom-doc: hand-written

interp_metric
=============

Overview
--------

The ``metric_interp`` module interpolates spacetime metric quantities from
a precomputed Cartesian grid to arbitrary particle positions in Phantom GR
simulations that use a tabulated (numerically-computed) spacetime metric,
such as those produced by numerical relativity codes. It is used in
conjunction with the ``metric_et`` module for simulations on FLRW or
Einstein Toolkit backgrounds.

The module defines a generic ``trilinear_interp`` interface with three
implementations: ``interp_g`` (interpolate the metric components
:math:`g_{\mu\nu}`), ``interp_sqrtg`` (interpolate :math:`\sqrt{-g}`), and
``interp_gderiv`` (interpolate the metric spatial derivatives). A helper
subroutine ``get_grid_neighbours`` maps a physical position to the indices
of the eight surrounding grid points using floor division, accounting for
the grid origin stored in ``einsteintk_utils``.

Physical & Mathematical Description
------------------------------------

The trilinear interpolation of a scalar field :math:`f` at position
:math:`\mathbf{x}` within a grid cell with corner positions
:math:`\mathbf{x}_0` and spacing :math:`\Delta x_i` is

.. math::

   f(\mathbf{x}) = \sum_{i,j,k \in \{0,1\}} f_{i,j,k}
   \prod_{\alpha \in \{x,y,z\}}
   \bigl[(1 - t_\alpha)(1-i_\alpha) + t_\alpha\, i_\alpha\bigr],

where :math:`t_\alpha = (x_\alpha - x_{0,\alpha})/\Delta x_\alpha`. The
metric is a symmetric :math:`4 \times 4` tensor :math:`g_{\mu\nu}` and its
spatial derivatives :math:`\partial_k g_{\mu\nu}` are similarly interpolated
component-by-component.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/interp_metric.f90
