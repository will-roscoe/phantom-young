.. phantom-doc: hand-written

Minkowski Metric
================

Overview
--------

The Minkowski metric module provides the flat-spacetime metric used as the reference case in
Phantom's general-relativistic hydrodynamics framework. It implements the trivial Lorentzian
metric :math:`\eta_{\mu\nu} = \mathrm{diag}(-1,+1,+1,+1)` in Cartesian coordinates, with
all spatial derivatives identically zero.

In Phantom, the GR infrastructure selects a specific metric at compile time through the
``metric`` Fortran module interface. Every metric module — including this one — exports the
same set of public subroutines (``get_metric_cartesian``, ``get_metric_spherical``,
``metric_cartesian_derivatives``, etc.), enabling transparent substitution. This module sets
``imetric = 1`` and ``metric_type = 'Minkowski'``.

The primary role of this module is to serve as a physically trivial test case against which
GR implementations can be validated. In the Minkowski limit all curvature source terms vanish
and the relativistic SPH equations should reproduce their Newtonian or special-relativistic
counterparts. It is also used during setup phases before a more complex metric is activated,
because its metric components are position-independent constants.

Because the metric is diagonal and constant, the contravariant form equals the covariant form,
:math:`g^{\mu\nu} = \eta^{\mu\nu} = \mathrm{diag}(-1,+1,+1,+1)`, and the volume element
:math:`\sqrt{-g} = 1` everywhere. The module also provides coordinate transformation routines
between Cartesian and spherical representations, as well as the Jacobian tensor
:math:`\partial x^{\mu'}/\partial x^\mu`, which are required when initialising data in
spherical coordinates.

Physical & Mathematical Description
-------------------------------------

The Minkowski metric in Cartesian coordinates :math:`(t, x, y, z)` is:

.. math::

   g_{\mu\nu} = \eta_{\mu\nu} = \mathrm{diag}(-1,+1,+1,+1)

The contravariant metric is identical to the covariant metric:

.. math::

   g^{\mu\nu} = \eta^{\mu\nu} = \mathrm{diag}(-1,+1,+1,+1)

All first derivatives of the metric vanish:

.. math::

   \partial_i g_{\mu\nu} = 0 \quad \forall\, i \in \{x, y, z\}

All Christoffel symbols :math:`\Gamma^\alpha{}_{\mu\nu} = 0`, so geodesics are straight
lines and no curvature source terms appear in the relativistic momentum equations. In
spherical coordinates :math:`(t, r, \theta, \phi)` the metric takes the standard form:

.. math::

   g_{\mu\nu}^{\rm sph} = \mathrm{diag}\!\left(-1,\, 1,\, r^2,\, r^2\sin^2\!\theta\right)

with volume element :math:`\sqrt{-g^{\rm sph}} = r^2 \sin\theta`. The spherical and
Cartesian metric components are related via the Jacobian of the coordinate transformation,
:math:`\partial(r,\theta,\phi)/\partial(x,y,z)`, which is provided by the ``get_jacobian``
subroutine.

References
----------

No phantom.bib entries apply. This metric is described in any standard GR textbook (e.g.,
Misner, Thorne & Wheeler 1973; Wald 1984) — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/metric_minkowski.f90
