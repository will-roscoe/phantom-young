.. phantom-doc: hand-written

extern_prdrag — Poynting–Robertson Drag and Radiation Pressure
===============================================================

Overview
--------

The ``extern_prdrag`` module computes the combined radiation pressure and
Poynting–Robertson (PR) drag force exerted by a luminous central source on a
dust grain or small body in orbit.  It is activated when
``iexternalforce = iext_prdrag``.  Code units with :math:`G = c = 1` are required.

The radiation force is parametrised by the ratio :math:`\beta` of radiation
pressure to gravitational force.  For a grain of radiation-pressure efficiency
:math:`Q_\mathrm{pr}`, geometric cross-section :math:`\sigma`, mass :math:`m`, and
stellar luminosity :math:`L_*`:

.. math::

   \beta = \frac{Q_\mathrm{pr}\,\sigma\,L_*}{4\pi c\,G\,M_*\,m}.

The force has two parts: a position-dependent radial part that reduces the effective
gravity by the factor :math:`(1 - \beta k_0)` (radiation pressure) and a
velocity-dependent part that removes energy from the orbit (the PR drag proper).
Three multiplicative constants :math:`k_0`, :math:`k_1`, :math:`k_2` allow the
relative strengths of radiation pressure, the radial velocity (redshift) term, and
the transverse drag term to be independently scaled for testing purposes; their
default values are all unity, recovering the standard Robertson (1937) formula.

Physical & Mathematical Description
-------------------------------------

**Spatial (radiation-pressure) force**

The position-dependent acceleration is a reduced Newtonian gravity:

.. math::

   \mathbf{f}_\mathrm{rad}
   = -\frac{G M_*\,(1 - k_0\beta)}{r^3}\,\mathbf{r},

so the effective gravitational parameter is
:math:`\mu_\mathrm{eff} = GM_*(1-k_0\beta)`.

**Velocity-dependent (PR drag) force**

The velocity-dependent part of the radiation force in the particle's rest frame is
(Robertson 1937; Klacka 1992)

.. math::

   \mathbf{f}_\mathrm{PR}
   = -\frac{\beta G M_*}{c\,r^2}
     \left[k_1\frac{v_r}{r}\,\mathbf{r} + k_2\,\mathbf{v}\right],

where :math:`v_r = \mathbf{v}\cdot\hat{r}` is the radial velocity component.  This
force dissipates orbital energy and angular momentum, causing the grain to spiral
inward on the Poynting–Robertson timescale.

**Implicit update**

Since :math:`\mathbf{f}_\mathrm{PR}` depends on velocity, the corrector step solves
the linear system

.. math::

   \bigl(I + b(k_2 I + k_1\hat{r}\hat{r}^T)\bigr)\,\mathbf{v}^1 = \mathbf{A},
   \quad
   b = \frac{1}{2}\Delta t\,\frac{\beta G M_*}{c\,r^2},

where :math:`\mathbf{A} = \mathbf{v}^{1/2} + \tfrac{1}{2}\Delta t\,\mathbf{f}_\mathrm{SPH}`,
via :math:`3\times 3` matrix inversion.

References
----------

The Poynting–Robertson force formula follows:

- Robertson, H. P. 1937, MNRAS, 97, 423 — not yet in phantom.bib
- Klacka, J. 1992, Earth Moon Planets, 59, 41 — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_prdrag.f90
