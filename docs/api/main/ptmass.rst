.. phantom-doc: hand-written

ptmass — Sink Particle Physics
================================

Overview
--------

The ``ptmass`` module is the central implementation of sink (point-mass) particle
physics in Phantom.  Sink particles represent compact objects — protostars, stellar
remnants, or massive bodies — whose gravitational influence on the surrounding gas is
tracked explicitly but whose internal structure is not resolved.  Following Bate,
Bonnell & Price (1995), each sink is characterised by an accretion radius ``h_acc``,
a softening length ``h_soft_sinkgas``, a mass, a velocity, and a spin vector
(:math:`S_x, S_y, S_z`).  Sink particles are not placed in the neighbour lists and
are, in an MPI context, stored as identical copies on every processor.

Sink creation is triggered when the density of a gas particle exceeds a threshold
``rho_crit`` (set via ``rho_crit_cgs`` at runtime), provided that a suite of
additional virial, angular-momentum, and convergence-flow checks are also satisfied
(``icreate_sinks = 1``).  An alternative star-formation prescription
(``icreate_sinks = 2``) uses a probabilistic core-collapse criterion seeded by
``iseed_sf``.  A particle is accreted onto a nearby sink if it lies within
``h_acc``, is gravitationally bound to the sink, and its specific angular momentum
is below the threshold :math:`\sqrt{G M_{\rm sink}\, h_{\rm acc}}`.  Particles
within the innermost fraction ``f_acc`` of the accretion radius are accreted
unconditionally.

Two sinks merge if their separation falls within the conditional merge radius
``r_merge_cond`` and they are mutually bound, or unconditionally within
``r_merge_uncond``.  The merged sink inherits the combined mass, linear momentum,
and angular momentum of its progenitors.  Spin vectors are evolved via torques
from the oblate geopotential (when the quadrupole coefficient :math:`J_2` is
non-zero), accumulated in ``dsdt_ptmass``.  Gravitational softening between a
sink and a gas particle uses a kernel-based softening scheme when the
gas–sink separation is less than :math:`r_{\rm kern} \times h_{\rm soft}`; the
potential form at large separations switches between a pure :math:`1/r` Newtonian
form (``isink_potential = 0``) and an Ayliffe–Bate surface-gravity modification
that suppresses accretion near the sink surface (``isink_potential = 1``).

Physical & Mathematical Description
-------------------------------------

**Sink-gas gravitational acceleration.**  For a gas particle at position
:math:`\mathbf{x}_i` and a sink :math:`j` at :math:`\mathbf{x}_j`, the
displacement vector is :math:`\mathbf{d} = \mathbf{x}_i - \mathbf{x}_j` with
magnitude :math:`r = |\mathbf{d}|`.  When :math:`r > r_{\rm kern}\,h_{\rm soft}`,
the unsoftened acceleration on the gas particle is

.. math::

   \mathbf{a}_{i \leftarrow j} = -\frac{G M_j}{r^3}\,\mathbf{d}

and the corresponding potential is :math:`\phi = -G M_j / r`.  Within the
softening kernel, the acceleration and potential are replaced by the kernel-softened
forms :math:`f_{\rm soft}` and :math:`p_{\rm soft}` provided by the ``kernel``
module:

.. math::

   \mathbf{a}_{i \leftarrow j} = -G M_j\,f_{\rm soft}(q^2)\,h_{\rm soft}^{-2}\,
   \frac{\mathbf{d}}{r}, \qquad
   \phi = G M_j\,p_{\rm soft}(q)\,h_{\rm soft}^{-1}

where :math:`q = r / h_{\rm soft}`.  Newton's third law is used to accumulate the
equal-and-opposite back-reaction force on the sink particle.

**Sink-sink acceleration.**  The force on sink :math:`i` due to sink :math:`j` is
computed identically to the sink-gas case, using the inter-sink softening length
``h_soft_sinksink``.  Orbital time-step control employs the estimator

.. math::

   \Delta t_\phi = C_\phi \sqrt{\frac{|\phi|}{|\mathbf{a}|^2}}

with the constant :math:`C_\phi` set to ``dtfacphi`` (0.05 for the standard
leapfrog, 0.15 for the FSI scheme).

**Oblate geopotential (J2).**  When a sink carries a non-zero quadrupole coefficient
:math:`J_2` and effective radius :math:`R_{\rm sink}`, the gravitational potential
acquires the zonal harmonic correction

.. math::

   \delta\phi = -\frac{G M J_2 R_{\rm sink}^2}{2 r^3}
   \left(3\cos^2\theta - 1\right)

where :math:`\theta` is the angle between the separation vector and the sink spin
axis :math:`\hat{\mathbf{S}}`.  The corresponding force and back-torque on the spin
are computed by ``get_geopot_force`` from the ``extern_geopot`` module.

**Surface-gravity potential (isink_potential = 1).**  Following Ayliffe & Bate
(2010), the potential near the sink surface (:math:`r < 2 R_{\rm sink}`) is
modified to prevent artificial accretion:

.. math::

   \phi = -\frac{G M}{R_{\rm sink}^4}
   \left(\frac{r^3}{3} - 4 r^2 R_{\rm sink} + 24 r R_{\rm sink}^2
   - \frac{16 R_{\rm sink}^4}{r} - 32 R_{\rm sink}^3 \ln r\right)

and the force amplitude is scaled by the factor
:math:`1 - (2 - r/R_{\rm sink})^4`.

**Accretion criterion.**  A gas particle of specific kinetic energy
:math:`\tfrac{1}{2}|\Delta\mathbf{v}|^2` relative to sink :math:`j` and at
separation :math:`r` is accreted if it satisfies all of the following:

.. math::

   r < h_{\rm acc}, \qquad
   \varepsilon = \tfrac{1}{2}|\Delta\mathbf{v}|^2 - \frac{G M_j}{r} < 0, \qquad
   h^2_\ell = r^2 |\Delta\mathbf{v}|^2 - (\mathbf{r}\cdot\Delta\mathbf{v})^2
   < G M_j\, h_{\rm acc}

where :math:`h_\ell` is the specific angular momentum of the gas particle relative
to the sink.  Particles with :math:`r < f_{\rm acc}\,h_{\rm acc}` are accreted
unconditionally.

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Symbol
     - Definition
   * - :math:`M_j`
     - Sink mass stored in ``xyzmh_ptmass(4, j)``
   * - :math:`h_{\rm acc}`
     - Accretion radius (``h_acc``; runtime parameter)
   * - :math:`h_{\rm soft}`
     - Gravitational softening length for sink-gas (``h_soft_sinkgas``)
   * - :math:`f_{\rm acc}`
     - Inner accretion fraction for unconditional accretion (``f_acc``)
   * - :math:`\rho_{\rm crit}`
     - Density threshold for sink creation (derived from ``rho_crit_cgs``)
   * - :math:`r_{\rm merge,c}`
     - Conditional merge radius (``r_merge_cond``)
   * - :math:`r_{\rm merge,u}`
     - Unconditional merge radius (``r_merge_uncond``)
   * - :math:`J_2`
     - Quadrupole moment coefficient stored in ``xyzmh_ptmass(iJ2, j)``
   * - :math:`R_{\rm sink}`
     - Effective sink radius stored in ``xyzmh_ptmass(iReff, j)``
   * - :math:`\hat{\mathbf{S}}`
     - Unit spin vector (``ispinx``, ``ispiny``, ``ispinz``)
   * - :math:`C_\phi`
     - Time-step pre-factor (``dtfacphi``)

References
----------

The sink particle algorithm implemented in this module follows:

- Bate, M. R., Bonnell, I. A., & Price, N. M. 1995, MNRAS, 277, 362 — original
  sink particle creation and accretion criteria (BBP95)
- Ayliffe, B. A. & Bate, M. R. 2010, MNRAS, 408, 876 — surface-gravity potential
  modification (``isink_potential = 1``)

No entries from ``phantom.bib`` are directly cited by this module.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/ptmass.F90
