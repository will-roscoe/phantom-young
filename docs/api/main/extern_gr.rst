.. phantom-doc: hand-written

GR External Forces (extern_gr)
===============================

Overview
--------

The ``extern_gr`` module computes the curvature source terms that appear on the right-hand
side of the relativistic SPH momentum equation. These terms arise from spatial gradients of
the metric tensor and couple the fluid stress-energy to the spacetime geometry. The module
is the central hub for evaluating GR forces on SPH particles in Phantom's GR framework,
as described in Liptai & Price (2019).

The module exposes the public routine ``get_grforce`` (for a single particle) and
``get_grforce_all`` (an OpenMP-parallelised loop over all particles). A timestep constraint
based on the magnitude of the GR force and, for Schwarzschild/Kerr metrics, the orbital
period, is computed by ``dt_grforce``.

In addition to force evaluation, the module provides ``get_tmunu`` and ``get_tmunu_all`` for
computing the covariant stress-energy tensor :math:`T_{\mu\nu}` from the fluid state. These
are needed when Phantom is coupled to the Einstein Toolkit for fully self-consistent GR
evolution (Magnall et al. 2023, Phys. Rev. D 108, 103534 — not yet in phantom.bib).

The internal subroutine ``forcegr`` performs the actual computation of the source term
:math:`f^i = T^{\mu\nu}\partial_\mu g_{\nu i}`, constructing the stress-energy tensor
from the 4-velocity, enthalpy, and pressure, and contracting it with the stored metric
derivatives.

Physical & Mathematical Description
-------------------------------------

In relativistic SPH the momentum equation for a fluid particle is written in terms of the
canonical momentum :math:`p_i = m_0 w \rho^* u_0 v_i`, where :math:`w` is the specific
enthalpy, :math:`u^0` is the time component of the 4-velocity, and :math:`\rho^*` is the
conserved density. The curvature source term on the right-hand side is:

.. math::

   \frac{\mathrm{d}p_i}{\mathrm{d}t} = \frac{1}{2} T^{\mu\nu} \frac{\partial g_{\mu\nu}}{\partial x^i}

where the stress-energy tensor per unit conserved rest mass is:

.. math::

   T^{\mu\nu} = w \rho^* u^0 v^\mu v^\nu + \frac{P}{\rho^* u^0} g^{\mu\nu}

Here :math:`v^\mu = (1, v^i)` is the coordinate 4-velocity, :math:`u^0 = (-g_{\mu\nu}v^\mu
v^\nu)^{-1/2}` is the normalisation factor computed by ``get_u0``, and :math:`P` is the
pressure. The metric derivatives :math:`\partial g_{\mu\nu}/\partial x^i` are pre-computed
and stored in the packed array ``metricderivs``.

The covariant stress-energy tensor used for coupling to the Einstein Toolkit is:

.. math::

   T_{\mu\nu} = w \rho\, u_\mu u_\nu + P g_{\mu\nu}

where indices are lowered with :math:`g_{\mu\nu}`.

The timestep constraint from the GR force magnitude is:

.. math::

   \Delta t_f = \sqrt{\frac{h}{|f|}}\,, \qquad
   \Delta t_{\rm orb} = \frac{2\pi}{\omega_{\rm Kepler}} \cdot \frac{1}{N_{\rm orb}}

where :math:`h` is the smoothing length, :math:`\omega_{\rm Kepler} = \sqrt{M/r^3}`, and
:math:`N_{\rm orb} = 100` steps per orbit. The actual timestep is :math:`\Delta t =
C_{\rm force}\min(\Delta t_f, \Delta t_{\rm orb})`.

References
----------

Liptai, D. & Price, D.J. 2019, MNRAS, 000, 000 — GR SPH formulation (not yet in phantom.bib).
Magnall, Price, Lasky & Macpherson (2023), Phys. Rev. D 108, 103534 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_gr.f90
