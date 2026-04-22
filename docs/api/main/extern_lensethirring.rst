.. phantom-doc: hand-written

extern_lensethirring — Lense–Thirring Frame-Dragging Precession
================================================================

Overview
--------

The ``extern_lensethirring`` module computes the Lense–Thirring (frame-dragging)
precession torque exerted by a spinning central black hole on an orbiting gas disc.
It provides a post-Newtonian, velocity-dependent force that causes disc rings to
precess about the black-hole spin axis at the Lense–Thirring rate, which is the
mechanism responsible for the Bardeen–Petterson effect and disc warping.

The module is activated when ``iexternalforce = iext_lensethirring``.  Validity
requires code units with :math:`G = c = 1` and an inner disc edge at least at the
gravitational radius :math:`r_g = GM/c^2`; a warning is issued if the accretion
radius is smaller than :math:`30\,r_g` since the weak-field approximation breaks down
at very small separations.

The precession angular velocity :math:`\boldsymbol{\Omega}_p` is computed from the
black-hole spin angular momentum at each particle position.  The resulting
:math:`\mathbf{v}\times\boldsymbol{\Omega}_p` force is velocity-dependent and is
handled implicitly using the same :math:`3\times 3` matrix-inversion scheme as
:doc:`extern_corotate`.

The spin vector of the black hole is parameterised by ``blackhole_spin`` (:math:`a`
in units of :math:`GM/c^2`, ranging from :math:`-1` to :math:`+1`) and
``blackhole_spin_angle`` (the tilt in degrees from the :math:`z`-axis, i.e. the
obliquity of the spin axis relative to the disc mid-plane).

Physical & Mathematical Description
-------------------------------------

The spin angular momentum of a black hole of mass :math:`M` and dimensionless spin
parameter :math:`a` is (see Nelson & Papaloizou 2000, eq. 6)

.. math::

   \mathbf{J} = \frac{GM^2}{c}\,a\,\hat{s},

where :math:`\hat{s}` is the unit spin vector.  In code units (:math:`G = c = 1`)
this simplifies to :math:`\mathbf{J} = M^2 a\,\hat{s}`.

The Lense–Thirring precession frequency at position :math:`\mathbf{r}` is

.. math::

   \boldsymbol{\Omega}_p(\mathbf{r})
   = \frac{G}{c^2}
     \left[\frac{2\mathbf{J}}{r^3}
           - \frac{6(\mathbf{J}\cdot\hat{r})\,\hat{r}}{r^3}\right],

which in code units (:math:`G = c = 1`) becomes
:math:`\boldsymbol{\Omega}_p = 2\mathbf{J}/r^3 - 6(\mathbf{J}\cdot\hat{r})\hat{r}/r^3`.

The corresponding velocity-dependent force on a gas particle with velocity
:math:`\mathbf{v}` is

.. math::

   \mathbf{f}_\mathrm{LT} = \mathbf{v}\times\boldsymbol{\Omega}_p.

This causes the orbital angular momentum vector of each disc annulus to precess about
:math:`\hat{s}`, driving Bardeen–Petterson alignment via viscous coupling.

**Implicit update**

Since :math:`\mathbf{f}_\mathrm{LT}` depends on :math:`\mathbf{v}`, the corrector
equation for the end-of-step velocity is

.. math::

   \mathbf{v}^1 = \mathbf{v}^{1/2}
                  + \tfrac{1}{2}\Delta t\,
                    \bigl[\mathbf{f}_\mathrm{SPH}
                          + \mathbf{v}^1\times\boldsymbol{\Omega}_p\bigr],

which is rearranged into the linear system
:math:`(I - \tfrac{1}{2}\Delta t\,[\boldsymbol{\Omega}_p]_\times)\,\mathbf{v}^1 = \mathbf{A}`
and solved by matrix inversion.

References
----------

The precession frequency formula follows:

- Nelson, R. P. & Papaloizou, J. C. B. 2000, MNRAS, 315, 570 — not yet in phantom.bib
- Lodato, G. & Pringle, J. E. 2006, MNRAS, 368, 1196 — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_lensethirring.f90
