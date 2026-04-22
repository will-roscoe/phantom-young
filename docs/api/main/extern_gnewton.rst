.. phantom-doc: hand-written

extern_gnewton — Generalised Newtonian Potential (Tejeda–Rosswog)
==================================================================

Overview
--------

The ``extern_gnewton`` module implements the generalised Newtonian potential of
Tejeda & Rosswog (2013), which reproduces several key features of the Schwarzschild
space-time — including the innermost stable circular orbit, the photon sphere, and the
orbital precession rate — within a purely Newtonian-framework SPH code.

It is activated when ``iexternalforce = iext_gnewton``.  The force has two parts: a
position-dependent spatial part (``get_gnewton_spatial_force``) and a
velocity-dependent part (``get_gnewton_vdependent_force``) that must be treated
implicitly.  The implicit update is handled iteratively in ``update_gnewton`` via
fixed-point iteration converging to a relative velocity change of less than
:math:`10^{-2}` (``tolv``).  Code units with :math:`G = c = 1` are assumed.

Physical & Mathematical Description
-------------------------------------

The gravitational radius of the central mass :math:`M` is
:math:`r_g = GM/c^2`.  In code units (:math:`G = c = 1`) this reduces to
:math:`r_g = M`.

**Spatial force**

The position-dependent part of the acceleration is

.. math::

   \mathbf{f}_\mathrm{s}
   = -\frac{M\,\mathbf{r}}{r^3}
     \left(1 - \frac{2r_g}{r}\right)^2,

which vanishes at the Schwarzschild radius :math:`r = 2r_g` and correctly reproduces
the location of the innermost stable circular orbit at :math:`r = 6r_g`.

**Velocity-dependent force**

The velocity-dependent correction is (Tejeda & Rosswog 2013)

.. math::

   \mathbf{f}_v = \frac{2r_g}{r(r - 2r_g)}(\mathbf{v}\cdot\hat{\mathbf{r}})\,\mathbf{v}
                  - \frac{3r_g}{r^5}|\mathbf{r}\times\mathbf{v}|^2\,\mathbf{r}

Here :math:`\hat{\mathbf{r}} = \mathbf{r}/r` is the unit radial vector,
:math:`\mathbf{v}\cdot\hat{\mathbf{r}}` is the radial velocity component, and
:math:`|\mathbf{r}\times\mathbf{v}|^2` is the squared specific angular momentum.

**Angular momentum and energy**

The module also provides ``get_gnewton_energy``, which returns the
pseudo-Schwarzschild energy and angular momentum useful for diagnostics and
conservation checks.

References
----------

The generalised Newtonian potential is described in:

- Tejeda, E. & Rosswog, S. 2013, MNRAS, 433, 1930 — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_gnewton.f90
