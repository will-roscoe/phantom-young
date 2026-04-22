.. phantom-doc: hand-written

GR Utility Functions
====================

Overview
--------

The ``utils_gr`` module collects fundamental utility routines needed throughout Phantom's
general-relativistic hydrodynamics implementation. These include the computation of the
time component of the 4-velocity :math:`u^0`, the Lorentz factor and Eulerian velocity
:math:`V^i`, conversion between the conserved SPH density :math:`\rho^*` and the
primitive rest-frame density :math:`\rho`, evaluation of the geodesic acceleration, and
determinant-related geometric quantities such as :math:`\sqrt{-g}` and
:math:`\sqrt{\gamma}`.

The module is a dependency of nearly every other GR module in Phantom. It is described in
the context of the relativistic SPH formalism of Liptai & Price (2019), MNRAS 485, 819
— not yet in phantom.bib.

The routine ``get_u0`` is called whenever a 4-velocity normalisation is required. Because
the argument :math:`v^\mu v_\mu` must be negative (timelike 4-velocity), the routine
returns an error flag ``ierr = 1`` whenever the velocity is spacelike; the calling code
then issues a fatal error indicating a particle has passed inside a black hole or the
numerical velocity has become unphysical.

The routine ``perturb_metric`` adds a weak-field Newtonian gravitational perturbation
:math:`\phi` to an existing metric via the Bardeen scalar perturbation formulation, which
is used in linear perturbation test problems.

Physical & Mathematical Description
-------------------------------------

**4-velocity normalisation.** Given the three-velocity components :math:`v^i` relative to
coordinate time, the four-vector :math:`v^\mu = (1, v^i)` is not normalised.
The normalisation factor :math:`u^0` is obtained from the constraint
:math:`g_{\mu\nu} u^\mu u^\nu = -1`:

.. math::

   u^0 = \frac{1}{\sqrt{-g_{\mu\nu} v^\mu v^\nu}}

**Eulerian velocity.** The velocity measured by a normal (Eulerian) observer is:

.. math::

   V^i = \frac{v^i + \beta^i}{\alpha}

where :math:`\alpha` is the lapse and :math:`\beta^i` is the shift. The Lorentz factor of
this observer is :math:`\mathcal{W} = (1 - \gamma_{ij} V^i V^j)^{-1/2}`.

**Conserved-to-primitive density.** The conserved density stored in the SPH smoothing
length is :math:`\rho^* = \sqrt{-g}\,u^0\,\rho`. Inverting this gives:

.. math::

   \rho = \frac{\rho^*}{\sqrt{-g}\,u^0}

**Geodesic acceleration.** For a test particle (or a pressureless fluid element), the
acceleration is derived from the geodesic equation:

.. math::

   \frac{\mathrm{d}p_i}{\mathrm{d}t}
   = \left(g^{\lambda}{}_{i} - v^{\lambda} g^{0}{}_{i}\right)
     \left(\partial_\mu g_{\lambda\sigma} - \tfrac{1}{2}\partial_\lambda g_{\mu\sigma}\right)
     v^\mu v^\sigma

**Bardeen metric perturbation.** A weak-field perturbation with Newtonian potential
:math:`\phi` is added to the diagonal components:

.. math::

   \tilde{g}_{tt} = g_{tt} - 2\phi, \qquad
   \tilde{g}_{ii} = g_{ii} - 2\phi \quad (i = 1,2,3)

References
----------

Liptai & Price (2019), MNRAS 485, 819 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_gr.f90
