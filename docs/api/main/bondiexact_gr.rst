.. phantom-doc: hand-written

Exact GR Bondi Accretion Solution
====================================

Overview
--------

The ``bondiexact`` module provides the exact general-relativistic solution for spherically
symmetric steady-state accretion onto a Schwarzschild black hole (Bondi accretion in GR).
The solution is used for code verification and setting up convergence tests of Phantom's GR
SPH framework, as described in Liptai & Price (2019), MNRAS 485, 819 — not yet in
phantom.bib.

Two solution modes are implemented, selected by the integer parameter ``isol``:

1. ``isol = 1`` — geodesic (pressureless dust) infall: the density and velocity profiles
   are obtained from analytical conservation laws for radial free-fall.

2. ``isol = 2`` (default) — sonic-point solution: a polytropic equation of state is
   assumed and the fluid passes through a sonic point at radius ``rcrit`` (default
   :math:`r_{\rm crit} = 8M`). The temperature profile is obtained by Newton-Raphson
   iteration of the relativistic Bernoulli equation at each radius.

The logical flag ``iswind`` switches between inflow (:math:`v < 0`, default) and outflow
wind (:math:`v > 0`) boundary conditions.

Physical & Mathematical Description
-------------------------------------

**Geodesic solution.** For pressureless radial infall the conserved rest-mass flux and
energy give:

.. math::

   \rho(r) = \frac{D_0}{\sqrt{2M/r}\,(1-2M/r)\,r^2}, \qquad
   v(r) = \sqrt{\frac{2M}{r}}\left(1-\frac{2M}{r}\right)

where :math:`D_0` is set by the normalisation constant ``den0``.

**Sonic-point solution.** For a polytropic fluid with adiabatic index :math:`\gamma` and
index :math:`n = 1/(\gamma - 1)`, the flow satisfies the relativistic Bernoulli equation:

.. math::

   \left[1 + (1+n)T\right]^2\!\left[1 - \frac{2M}{r} + \frac{C_1^2}{r^4 T^{2n}}\right] = C_2

where :math:`T` is the temperature (proportional to the polytropic pressure over density),
and the integration constants are:

.. math::

   C_1 = \sqrt{u_c^2}\, T_c^n\, r_{\rm crit}^2, \qquad
   u_c^2 = \frac{M}{2 r_{\rm crit}}, \qquad
   v_c^2 = \frac{u_c^2}{1-3u_c^2}, \qquad
   T_c = \frac{v_c^2 n}{1 + n - v_c^2 n(1+n)}

The temperature at radius :math:`r` is found by Newton-Raphson iteration on the Bernoulli
equation with convergence tolerance :math:`10^{-5}`. Given :math:`T(r)`, the radial
velocity, density, and specific internal energy are:

.. math::

   u(r) = \frac{C_1}{r^2 T^n}, \qquad
   \rho(r) = \rho_{\rm ad} T^n, \qquad
   \varepsilon(r) = nT

where :math:`u = v/u^0` is the coordinate velocity. The normalisation :math:`u^0` accounts
for the GR time-dilation at radius :math:`r` in the Schwarzschild metric.

References
----------

Liptai & Price (2019), MNRAS 485, 819 — not yet in phantom.bib.
Michel (1972), Astrophys. Space Sci. 15, 153 — not yet in phantom.bib (original GR Bondi
solution).

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/bondiexact_gr.f90`.
