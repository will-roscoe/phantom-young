.. phantom-doc: hand-written

Einstein Toolkit Metric Grid Utilities
=======================================

Overview
--------

The ``metric_et_utils`` module provides the data structures and I/O infrastructure needed
to store and manage a tabulated spacetime metric supplied by an external GR evolution code
such as the Einstein Toolkit. Rather than computing metric components from an analytic
formula, the coupled Phantom–Einstein Toolkit system receives discrete samples of
:math:`g_{\mu\nu}`, :math:`g^{\mu\nu}`, :math:`\sqrt{-g}`, and :math:`\partial_i
g_{\mu\nu}` on a Cartesian grid, which this module allocates, initialises, and serialises.

The module declares globally accessible allocatable arrays — ``gcovgrid``, ``gcongrid``,
``sqrtggrid``, and ``metricderivsgrid`` — indexed by grid cell position. Grid metadata
(origin, spacing, and size) are stored in ``gridorigin``, ``dxgrid``, and ``gridsize``.
The logical flag ``gridinit`` records whether the grid has been populated; it is checked in
``metric_et.f90`` before attempting interpolation to particle positions.

The ``allocate_grid`` routine sizes and allocates all arrays given the grid dimensions and
spacing. The metric derivatives are stored in the form
``metricderivsgrid(0:3, 0:3, 1:3, nx, ny, nz)`` where the third dimension indexes the
three spatial derivative directions :math:`\partial/\partial x^i`. Binary serialisation and
deserialisation of the full grid state are provided by ``write_tabulated_metric`` and
``read_tabulated_metric``, enabling checkpointing and restart of coupled GR simulations.

The module is referenced by Magnall et al. (2023), Phys. Rev. D 108, 103534 — not yet in
phantom.bib — which describes the Phantom–Einstein Toolkit coupling methodology.

Physical & Mathematical Description
-------------------------------------

In the 3+1 ADM decomposition of general relativity, the four-dimensional metric is written
in terms of the lapse :math:`\alpha`, shift :math:`\beta^i`, and spatial metric
:math:`\gamma_{ij}`:

.. math::

   \mathrm{d}s^2 = -\alpha^2 \mathrm{d}t^2 + \gamma_{ij}
   (\mathrm{d}x^i + \beta^i \mathrm{d}t)(\mathrm{d}x^j + \beta^j \mathrm{d}t)

Equivalently, the full covariant metric components are:

.. math::

   g_{tt} = -\alpha^2 + \beta_i \beta^i, \quad
   g_{ti} = \beta_i, \quad
   g_{ij} = \gamma_{ij}

The Einstein Toolkit evolves :math:`\alpha`, :math:`\beta^i`, and :math:`\gamma_{ij}` on
its numerical grid and passes the assembled :math:`g_{\mu\nu}` and its derivatives to
Phantom. This module stores those sampled values and the Phantom ``metric_et`` module then
performs trilinear interpolation from the grid to individual SPH particle positions.

The grid is uniform with spacing :math:`\Delta x^i` (``dxgrid``). Given a particle at
position :math:`\mathbf{x}`, the lower grid neighbour in each direction is:

.. math::

   i_{\rm low} = \left\lfloor \frac{x - x_{\rm origin}}{\Delta x} \right\rfloor + 1

and the interpolation weight along direction :math:`x` is
:math:`x_d = (x - x_{\rm low})/\Delta x \in [0,1]`. Trilinear interpolation is then
applied across the eight surrounding grid nodes.

References
----------

Magnall, Price, Lasky & Macpherson (2023), Phys. Rev. D 108, 103534 — not yet in
phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/metric_et_utils.f90
