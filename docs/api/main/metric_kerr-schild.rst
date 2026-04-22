.. phantom-doc: hand-written

Kerr Metric (Kerr-Schild Coordinates)
========================================

Overview
--------

The Kerr-Schild metric module provides the Kerr rotating black hole spacetime in
horizon-penetrating Kerr-Schild coordinates. It implements Phantom's ``metric`` module
interface with ``imetric = 4`` and ``metric_type = 'Kerr-Schild'``. Unlike the
Boyer-Lindquist form, Kerr-Schild coordinates are non-singular at the event horizon, making
this module the preferred choice when particles may cross :math:`r = r_+` during a
simulation (e.g., black hole accretion with a realistic inner boundary).

The metric is written in Cartesian-like Kerr-Schild coordinates. Because the analytic
expressions for the Cartesian derivatives are complex, the module delegates to the
numerical metric derivative fallback in ``metric_tools`` (``numerical_metric_derivs``),
which uses centred finite differences with step :math:`\delta = 10^{-8}`. The analytic
Cartesian derivative routine is intentionally left as a zero stub. Spherical-coordinate
routines are also stubs — this module always operates in Cartesian coordinates.

The module is primarily used for simulations of accreting black holes where material must
pass through the horizon without encountering a coordinate singularity, or as a consistency
check against Boyer-Lindquist results in the exterior region.

Physical & Mathematical Description
-------------------------------------

The Kerr-Schild form of the Kerr metric is obtained by a null tetrad transformation from
Boyer-Lindquist coordinates. The covariant metric is:

.. math::

   g_{\mu\nu} = \eta_{\mu\nu} + \frac{2M r}{\Sigma} l_\mu l_\nu

where :math:`\eta_{\mu\nu}` is the Minkowski metric and :math:`l_\mu` is the ingoing
principal null congruence. In Cartesian Kerr-Schild coordinates
:math:`(t,x,y,z)` the null vector components are:

.. math::

   l_\mu = \left(1,\; \frac{rx + ay}{r^2+a^2},\; \frac{ry - ax}{r^2+a^2},\; \frac{z}{r}\right)

where the Boyer-Lindquist radial coordinate :math:`r` is defined implicitly by:

.. math::

   r^2 = \frac{1}{2}\!\left[(x^2+y^2+z^2-a^2) +
         \sqrt{(x^2+y^2+z^2-a^2)^2 + 4a^2 z^2}\right]

and :math:`\Sigma = r^2 + a^2 z^2/r^2`. The auxiliary quantity is
:math:`\mathrm{term} = 2Mr/\Sigma`. The metric components implemented in the code are:

.. math::

   g_{tt} = -1 + \mathrm{term}\cdot r, \qquad
   g_{ti} = \mathrm{term}\cdot r\, (l_i), \qquad
   g_{ij} = \delta_{ij} + \mathrm{term}\cdot r\, l_i l_j

The contravariant metric has the convenient Kerr-Schild form:

.. math::

   g^{\mu\nu} = \eta^{\mu\nu} - \frac{2Mr}{\Sigma} l^\mu l^\nu

so the sign of the perturbation is flipped for :math:`g^{\mu\nu}` relative to
:math:`g_{\mu\nu}`, as coded in ``get_metric_cartesian``.

References
----------

Kerr (1963), Phys. Rev. Lett. 11, 237 — not yet in phantom.bib.
Kerr-Schild form: Boyer & Lindquist (1967); see also Visser (2007), arXiv:0706.0622 —
not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/metric_kerr-schild.f90`.
