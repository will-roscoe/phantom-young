.. phantom-doc: hand-written

extern_Bfield — External Tokamak Magnetic Field Configurations
===============================================================

Overview
--------

The ``extern_Bfield`` module implements external magnetic field prescriptions for MHD
simulations in Phantom.  It is designed for tokamak-geometry problems where an
externally imposed field confines a plasma torus: the field is specified in toroidal
coordinates :math:`(r_t, \theta, \phi)` relative to the torus axis and converted to
Cartesian components for use in the force and induction equations.

Two analytic profiles are provided.  The first (``itype_externB = 1``) follows the
current distribution described by Wesson (Tokamaks), in which the toroidal current
density is :math:`J_\phi \propto (1 - (r_t/a)^2)^n` where :math:`a` is the minor
radius and :math:`n` = ``nutorus`` is the winding number.  The second
(``itype_externB = 2``) uses a Gaussian current profile
:math:`J_\phi \propto \exp(-4(r_t/a)^2)` that decays smoothly at the torus boundary.

The central routine ``externBfield`` accepts a mode string (``'Bfield'``,
``'fext'``, ``'all'``) selecting which output quantities are required: the external
field vector alone, the external Lorentz body force alone, or the full set including
the cross-terms :math:`\mathbf{J}_\mathrm{int}\times\mathbf{B}_\mathrm{ext}`,
:math:`\mathbf{J}_\mathrm{ext}\times\mathbf{B}_\mathrm{int}`, and the advection
term :math:`\mathbf{v}\cdot\nabla\mathbf{B}_\mathrm{ext}` needed in the induction
equation.  A simplified interface ``get_externalB_force`` is called from the
external-force dispatcher when ``iexternalforce = iext_externB``.

Physical & Mathematical Description
-------------------------------------

The magnetic field and current are specified in toroidal coordinates
:math:`(r_t, \theta, \phi_t)`, where :math:`r_t` is the minor radius from the torus
axis and :math:`\phi_t` is the azimuthal angle around the torus.  The Cartesian
position :math:`(x,y,z)` maps to toroidal coordinates via

.. math::

   r_\mathrm{cyl} = \sqrt{x^2+y^2},
   \qquad
   r_t = \sqrt{(r_\mathrm{cyl} - R_0)^2 + z^2},

where :math:`R_0` = ``Rtorus`` is the major radius.

**Wesson profile** (``itype_externB = 1``)

The toroidal current density is

.. math::

   J_\phi^\mathrm{ext} = J_0\!\left(1 - \frac{r_t^2}{a^2}\right)^n,

where :math:`J_0` = ``currJ0``, :math:`a = \texttt{a\_on\_R}\times R_0`, and
:math:`n` = ``nutorus``.  The poloidal field :math:`B_\theta` is obtained by
integrating Ampere's law:

.. math::

   B_\theta(r_t) = \frac{J_0\,a^2}{2(n+1)}
                    \left[1 - \left(1 - \frac{r_t^2}{a^2}\right)^{n+1}\right]
                    \frac{1}{r_t}.

A toroidal field :math:`B_\phi = B_\phi^\mathrm{ext} R_0 / r_\mathrm{cyl}` is
superimposed via the parameter ``Bphi``.

**Gaussian profile** (``itype_externB = 2``)

.. math::

   J_\phi^\mathrm{ext} = J_0\,e^{-4 r_t^2/a^2},
   \qquad
   B_\theta(r_t) = \frac{J_0\,a^2}{8}
                    \left(1 - e^{-4 r_t^2/a^2}\right)\frac{1}{r_t}.

**External Lorentz force**

The force per unit mass in the minor-radius direction is

.. math::

   f_{r_t} = -\frac{B_\theta J_\phi^\mathrm{ext}}{\rho},

with cross-term contributions from :math:`\mathbf{J}_\mathrm{int}\times\mathbf{B}_\mathrm{ext}`
and :math:`\mathbf{J}_\mathrm{ext}\times\mathbf{B}_\mathrm{int}` added when the
full ``'all'`` mode is requested.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_Bfield.f90
