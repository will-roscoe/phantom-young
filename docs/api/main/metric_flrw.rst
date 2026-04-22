.. phantom-doc: hand-written

Friedmann-Lemaître-Robertson-Walker Metric
============================================

Overview
--------

The FLRW metric module provides the cosmological Friedmann-Lemaître-Robertson-Walker
(FLRW) metric for Phantom simulations of cosmological structure formation and
homogeneous universe models. It implements Phantom's ``metric`` module interface with
``imetric = 6`` and ``metric_type = 'flrw'``.

The FLRW metric is spatially flat (zero curvature) and time-dependent: the spatial part
is multiplied by a time-dependent scale factor :math:`a(t)`. The ``get_scale_factor``
subroutine currently implements a simple linear expansion :math:`a(t) = 1 + t/2`, which
corresponds to a matter-dominated universe in the chosen code units. The time :math:`t`
is obtained from the global timestep module variable ``time``.

This module is primarily used for testing GR SPH in expanding universes and for
investigations of non-linear cosmological perturbations in the Newtonian or
post-Newtonian regime. Phantom's GR cosmological applications are described in
Macpherson, Lasky & Price (2019) — not yet in phantom.bib.

The metric derivatives in the Cartesian form are noted as returning unity for all
components — this is a placeholder and requires correction for production cosmological
runs involving source terms from :math:`\partial_i g_{\mu\nu}`.

Physical & Mathematical Description
-------------------------------------

The spatially flat FLRW metric in Cartesian coordinates :math:`(t, x, y, z)` is:

.. math::

   \mathrm{d}s^2 = -\mathrm{d}t^2 + a(t)^2\,(\mathrm{d}x^2 + \mathrm{d}y^2 + \mathrm{d}z^2)

with covariant components:

.. math::

   g_{\mu\nu} = \mathrm{diag}\!\left(-1,\; a(t),\; a(t),\; a(t)\right)

and contravariant components:

.. math::

   g^{\mu\nu} = \mathrm{diag}\!\left(-1,\; a(t)^{-1},\; a(t)^{-1},\; a(t)^{-1}\right)

Note that the code stores :math:`a` (not :math:`a^2`) in the spatial components as an
approximation; the strict FLRW convention would be :math:`g_{ii} = a^2`. The determinant
is :math:`\sqrt{-g} = a^3`.

The Hubble parameter is defined by:

.. math::

   H = \frac{\dot{a}}{a}

For the implemented scale factor :math:`a(t) = 1 + t/2`, one has :math:`\dot{a} = 1/2`
and :math:`H = 1/(2+t)`. The conformal time :math:`\eta` is related to coordinate time
by :math:`\mathrm{d}\eta = \mathrm{d}t/a(t)`.

In spherical coordinates, the metric is:

.. math::

   g_{\mu\nu}^{\rm sph} = \mathrm{diag}\!\left(-1,\; a,\; a r^2,\; a r^2\sin^2\!\theta\right)

with :math:`\sqrt{-g^{\rm sph}} = a^3`.

References
----------

Friedmann (1922, 1924); Lemaître (1927); Robertson (1935); Walker (1937) — not yet in
phantom.bib. Macpherson, Lasky & Price (2019) — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/metric_flrw.f90`.
