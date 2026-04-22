.. phantom-doc: hand-written

Subgroup Regularisation Integrator
====================================

Overview
--------

The ``subgroup`` module implements the Slow-Down Algorithmic Regularisation (SDAR) method
for accurately integrating close encounters and bound subsystems (binaries, triples, and
higher-order multiples) within a larger N-body simulation. The method is based on the
Time-Transformed Leapfrog (TTL) integrator of Mikkola & Aarseth (2002) — not yet in
phantom.bib — combined with the slowdown technique to decouple internal binary motion from
the slower external perturbation timescale.

Group identification is performed by ``subgroup_search``, which constructs an adjacency
matrix over all point masses using a fixed neighbour radius ``r_neigh`` and physical
binding/periapsis criteria (Rantala et al. 2023 — not yet in phantom.bib). Connected
components of this graph are subgroups; isolated particles are classified as singles.
Binary orbital elements within each subgroup are identified and stored in ``bin_info``.

Time integration of each subgroup proceeds in ``subgroup_evolve`` and ``subgroup_step``,
where the TTL drift and kick operators advance positions and velocities in fictitious
(regularised) time :math:`s` rather than coordinate time :math:`t`. The step size
:math:`\mathrm{d}s` is chosen to resolve the tightest orbit in the group. A synchronisation
algorithm converges the internal regularised time to the external leapfrog time :math:`t_{\rm end}`.

The slowdown factor :math:`\kappa` is updated by ``update_kappa`` at each substep. For
strongly perturbed binaries :math:`\kappa = 1` (no slowdown); for isolated hard binaries
:math:`\kappa \gg 1` so that internal oscillations are artificially slowed while the
centre-of-mass motion advances at the correct rate.

Physical & Mathematical Description
-------------------------------------

**TTL time transformation.** The regularised time :math:`s` is related to coordinate time
:math:`t` by:

.. math::

   \frac{\mathrm{d}t}{\mathrm{d}s} = \frac{1}{\Omega(\mathbf{q})}

where :math:`\Omega = \frac{1}{2}\sum_{a \neq b} m_a m_b / r_{ab}` is proportional to the
gravitational potential. The TTL drift and kick operators are:

.. math::

   \Delta t = \frac{c_k \,\mathrm{d}s}{\Omega}, \qquad
   \Delta \mathbf{v}_a = \frac{d_k \,\mathrm{d}s}{\Omega}\, \mathbf{f}_a

where :math:`c_k` and :math:`d_k` are the Yoshida (1990) sixth-order symplectic coefficients
stored in ``cks`` and ``dks`` (``ck_size = 8`` stages).

**Slowdown.** The slowdown factor :math:`\kappa \geq 1` is computed from:

.. math::

   \kappa = \min\!\left(\kappa_{\rm max},\,
            \frac{\kappa_{\rm ref}}{\displaystyle\frac{r_{\rm apo}^3}{\mu}\,\mathcal{F}_{\rm out}}\right)

where :math:`\mu` is the reduced mass of the binary, :math:`r_{\rm apo}` is the apoapsis
distance, :math:`\mathcal{F}_{\rm out}` is the magnitude of the external perturbation
force (tidal field from third bodies), and :math:`\kappa_{\rm ref} = 10^{-6}`. The
internal relative velocity is scaled by :math:`\kappa^{-1}` in the drift step while the
centre-of-mass drifts at the unmodified rate.

**Group identification.** Two particles :math:`i` and :math:`j` are connected in the
adjacency matrix if either :math:`r_{ij} < r_{\rm neigh}` or, within the search radius
:math:`r_{\rm search} = 100\, r_{\rm neigh}`, the orbit is bound with semi-major axis
:math:`a_{ij} < r_{\rm neigh}`, or the encounter is hyperbolic with periapsis
:math:`r_{\rm peri} < r_{\rm neigh}` and the encounter timescale :math:`C_{\rm bin}
\sqrt{r^2/v^2} < \Delta t_{\rm ext}`.

References
----------

Mikkola & Aarseth (2002) — not yet in phantom.bib.
Wang, Nitadori, Tanikawa & Makino (2020, 2021) — not yet in phantom.bib.
Rantala, Naab & Springel (2023) — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/subgroup.f90
