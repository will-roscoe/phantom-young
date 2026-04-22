.. phantom-doc: hand-written

Einstein Toolkit Tabulated Metric
====================================

Overview
--------

The Einstein Toolkit metric module provides a grid-interpolated spacetime metric for
Phantom when it is coupled to the Einstein Toolkit (ET) numerical relativity code. It
implements Phantom's ``metric`` module interface with ``imetric = 7`` and
``metric_type = 'et'``. Instead of evaluating an analytic formula, both the covariant
metric :math:`g_{\mu\nu}` and its spatial derivatives are obtained by trilinear
interpolation from the tabulated arrays managed by ``metric_et_utils``.

During coupled Phantom–ET runs the Einstein Toolkit evolves the spacetime geometry and
passes updated metric data to Phantom at every coupling step. The grid flag ``gridinit``
from ``metric_et_utils`` gates all interpolation: if the grid has not yet been populated
(e.g., during ``phantomsetup`` before any ET coupling has occurred), the metric falls
back to Minkowski, ensuring graceful behaviour during setup.

The ``get_metric_cartesian`` subroutine calls ``interpolate_metric`` to perform the
trilinear interpolation of :math:`g_{\mu\nu}`, :math:`g^{\mu\nu}`, and
:math:`\sqrt{-g}` at a particle position. The ``metric_cartesian_derivatives`` subroutine
analogously interpolates the pre-tabulated derivatives
:math:`\partial g_{\mu\nu}/\partial x^i` from the ``metricderivsgrid`` array.

The grid indexing uses the lower-corner convention: for a particle at position
:math:`\mathbf{x}`, the lower index in each direction is
:math:`i_{\rm low} = \lfloor (x - x_{\rm origin})/\Delta x \rfloor + 1`.

Physical & Mathematical Description
-------------------------------------

At each coupling step the Einstein Toolkit supplies the 3+1 ADM variables — lapse
:math:`\alpha`, shift :math:`\beta^i`, and spatial metric :math:`\gamma_{ij}` — on its
Cartesian grid. These are assembled into the full 4-metric:

.. math::

   g_{\mu\nu} = \begin{pmatrix}
   -\alpha^2 + \beta_k \beta^k & \beta_j \\
   \beta_i                      & \gamma_{ij}
   \end{pmatrix}

Phantom stores both :math:`g_{\mu\nu}` and :math:`g^{\mu\nu}` on the grid (the latter
obtained by matrix inversion on the ET side), along with :math:`\sqrt{-g} = \alpha\sqrt{\gamma}`.

For a particle at position :math:`\mathbf{x}`, trilinear interpolation from the
eight neighbouring grid nodes gives:

.. math::

   g_{\mu\nu}(\mathbf{x}) = \sum_{i,j,k \in \{0,1\}} w_i^x w_j^y w_k^z\,
                             g_{\mu\nu}^{(i_{\rm low}+i,\, j_{\rm low}+j,\, k_{\rm low}+k)}

where :math:`w_0^x = 1 - x_d`, :math:`w_1^x = x_d`, and :math:`x_d = (x -
x_{\rm low})/\Delta x \in [0,1]`. An identical interpolation is applied to each of the
16 independent metric components and to the three spatial derivative arrays
:math:`\partial_i g_{\mu\nu}`.

References
----------

Magnall, Price, Lasky & Macpherson (2023), Phys. Rev. D 108, 103534 — not yet in
phantom.bib. Einstein Toolkit: https://einsteintoolkit.org — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/metric_et.f90`.
