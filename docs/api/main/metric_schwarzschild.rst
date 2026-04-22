.. phantom-doc: hand-written

Schwarzschild Metric
====================

Overview
--------

The Schwarzschild metric module provides the exact vacuum solution to the Einstein field
equations for a non-rotating, spherically symmetric black hole of mass :math:`M`. It
implements Phantom's ``metric`` module interface with ``imetric = 2`` and
``metric_type = 'Schwarzschild'``, making it a drop-in replacement for any other metric
backend.

Both a Cartesian-like (isotropic) form and a standard spherical-coordinate form are
provided. The Cartesian form is used in all production Phantom runs, where SPH particles
are always tracked in Cartesian coordinates. The spherical form is available for
diagnostic output and initialisation of purely spherical setups. Analytic first derivatives
of the Cartesian metric are implemented in ``metric_cartesian_derivatives``, avoiding the
need for finite-difference approximations and yielding exact curvature source terms in the
momentum equations.

The single runtime parameter is ``mass1``, the gravitational mass of the central black
hole in code units (where :math:`G = c = 1`). The Schwarzschild radius is
:math:`r_s = 2M`. The module is used for accretion disc simulations, tidal disruption
events, and test-particle geodesic calculations around a non-rotating black hole.

Physical & Mathematical Description
-------------------------------------

In spherical coordinates :math:`(t, r, \theta, \phi)` the Schwarzschild metric is:

.. math::

   \mathrm{d}s^2 = -\!\left(1 - \frac{2M}{r}\right)\mathrm{d}t^2
                   + \left(1 - \frac{2M}{r}\right)^{\!-1}\!\mathrm{d}r^2
                   + r^2\,\mathrm{d}\Omega^2

where :math:`\mathrm{d}\Omega^2 = \mathrm{d}\theta^2 + \sin^2\!\theta\,\mathrm{d}\phi^2`.
The covariant metric components are:

.. math::

   g_{tt} = -\!\left(1-\frac{2M}{r}\right), \quad
   g_{rr} = \left(1-\frac{2M}{r}\right)^{\!-1}, \quad
   g_{\theta\theta} = r^2, \quad
   g_{\phi\phi} = r^2\sin^2\!\theta

In the Cartesian-like form, the metric is transformed to coordinates
:math:`(x,y,z)` with :math:`r = \sqrt{x^2+y^2+z^2}`. The off-diagonal spatial
components in Cartesian coordinates are non-zero:

.. math::

   g_{ij}^{\rm Cart} = \delta_{ij} + \frac{r_s / r^3}{1 - r_s/r}
                       \left(\delta_{ij} r^2 - x^i x^j\right)^{\!-1}\!x^i x^j

where :math:`r_s = 2M`. The time-time component remains diagonal:
:math:`g_{tt}^{\rm Cart} = -(1-r_s/r)`. The contravariant metric is
:math:`g^{tt} = -(1-r_s/r)^{-1}`, and the spatial contravariant components have the form
:math:`g^{ij} = \delta^{ij} - (r_s/r^3) x^i x^j`.

The innermost stable circular orbit (ISCO) for a test mass is located at
:math:`r_{\rm ISCO} = 6M` in these coordinates.

References
----------

Schwarzschild (1916) — not yet in phantom.bib. Standard reference: Misner, Thorne &
Wheeler (1973), Gravitation.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/metric_schwarzschild.f90`.
