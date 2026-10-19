Sink particle parameters — guide and recommendations
=====================================================

This page explains the sink particle parameters that appear in the ``.in`` runtime
file, with physical motivation, the equations they enter, and practical guidance on
choosing sensible values for protostellar disc fragmentation simulations.

See also :doc:`sinks` for a general overview of how sink particles work in Phantom.

.. contents::
   :local:
   :depth: 2

----

Background: the SPH smoothing length
--------------------------------------

Every recommendation in this guide is relative to the local SPH **smoothing
length** :math:`h`, so it is worth defining it first.

In SPH, particle densities are computed by convolving neighbours with a kernel
function :math:`W(r, h)`:

.. math::

   \rho_i = \sum_j m_j \, W(|\mathbf{r}_i - \mathbf{r}_j|,\, h_i)

The kernel is normalised (:math:`\int W \, dV = 1`) and compact (zero beyond
:math:`\sim 2h`). Phantom uses a cubic spline kernel by default.

The smoothing length is **adaptive** — it adjusts so each particle always
neighbours a fixed number of other particles:

.. math::

   h_i = h_\text{fact} \left( \frac{m_i}{\rho_i} \right)^{1/3} \quad \text{(3D)}

where ``hfact`` :math:`\approx 1.2` (set in the ``.in`` file). As a result,
:math:`h` is small where the disc is dense and large where it is diffuse.
**All sink radii should be interpreted relative to the local** :math:`h`
**at the radius where the relevant physics occurs.**

For a typical 0.2 M\ :sub:`☉` host disc with :math:`N = 10{,}000` particles,
:math:`\Sigma \propto R^{-1}`, and :math:`H/R = 0.1`:

.. list-table::
   :header-rows: 1
   :widths: 15 20 20 20

   * - Radius (AU)
     - :math:`\Sigma` (M\ :sub:`☉`/AU²)
     - :math:`\rho` (M\ :sub:`☉`/AU³)
     - :math:`h_\text{sph}` (AU)
   * - 20
     - :math:`4.0 \times 10^{-6}`
     - :math:`7.9 \times 10^{-7}`
     - 2.4
   * - 50
     - :math:`1.6 \times 10^{-6}`
     - :math:`1.3 \times 10^{-7}`
     - 4.3
   * - 100
     - :math:`7.9 \times 10^{-7}`
     - :math:`3.1 \times 10^{-8}`
     - 6.9

Sink radii set far below :math:`h_\text{sph}` are **sub-resolution** — they
have no hydrodynamic meaning and can produce unphysical results.

----

Accretion radius (``h_acc``)
-----------------------------

*Units: AU. Applies to: newly created fragment sinks.*

``h_acc`` sets the radius inside which gas particles are candidates for accretion
onto a sink. A particle at separation :math:`r` from sink :math:`i` is tested for
accretion if:

.. math::

   |\mathbf{r}_j - \mathbf{r}_i| < h_\text{acc}

When accreted, mass and momentum are transferred conservatively:

.. math::

   M_\text{sink} &\leftarrow M_\text{sink} + m_j \\
   \mathbf{p}_\text{sink} &\leftarrow \mathbf{p}_\text{sink} + m_j \mathbf{v}_j

``h_acc`` defines the **minimum resolved scale** around a fragment — all physics
inside this radius is unresolved and replaced by point-mass dynamics.

**Effect on simulation outputs**

- Too small (:math:`h_\text{acc} \ll h_\text{sph}`): gas flows hydrodynamically
  toward the fragment over ~:math:`h_\text{sph}` but cannot be formally accreted
  until a particle physically arrives within :math:`h_\text{acc}`. This
  *artificially suppresses fragment growth rates* and undercounts the accreted
  mass during the early rapid-accretion phase.
- Too large (:math:`h_\text{acc} \gtrsim h_\text{sph}`): material is vacuumed up
  before the SPH kernel has resolved whether it is truly bound to the fragment.
  This *inflates fragment masses* and can terminate disc fragmentation prematurely
  by removing gas that would otherwise remain in the disc.

**Recommendation**

Set ``h_acc`` to be **resolved but small** — comparable to the SPH smoothing
length at the inner disc edge (the smallest scale you resolve):

.. math::

   h_\text{acc} \sim h_\text{sph}(R_\text{in}) \sim 1\text{–}2 \; \text{AU}

for typical T Tauri disc parameters. The value ``h_acc = 0.001 AU`` used in
``03pol00x`` is effectively sub-resolution for :math:`N = 10{,}000` discs and
should be increased to 0.5–1 AU for physically meaningful accretion rates.

----

Sink–gas gravitational softening (``h_soft_sinkgas``)
-------------------------------------------------------

*Units: AU. Applies to: gravitational force between each sink and all gas particles.*

Without softening, the gravitational acceleration of a gas particle near a sink
diverges as :math:`r \to 0`:

.. math::

   \mathbf{a} = -\frac{G M_\text{sink}}{r^2} \hat{\mathbf{r}}

With softening length :math:`\varepsilon \equiv` ``h_soft_sinkgas``, Phantom
replaces this with a kernel-softened potential :math:`\phi_k`:

.. math::

   \mathbf{a}_\text{soft}(r) = -\frac{G M_\text{sink}}{h_\text{soft}^2} \,
   \phi_k'\!\left(\frac{r}{h_\text{soft}}\right)\hat{\mathbf{r}}

where :math:`\phi_k'(q) \to 1/q^2` for :math:`q \gg 1` (recovering Newtonian
gravity) and :math:`\phi_k'(0) = 0` (no force at zero separation).

**Recommendation**

``h_soft_sinkgas = 0.000`` (no softening) is appropriate **when** ``h_acc`` is
large enough to remove particles before they reach sub-resolution separations.
If ``h_acc`` is very small (sub-resolution), setting
:math:`h_\text{soft} \approx h_\text{acc}` prevents artificially large
accelerations on particles near the sink boundary.

----

Sink–sink gravitational softening (``h_soft_sinksink``)
---------------------------------------------------------

*Units: AU. Applies to: pairwise gravitational force between all sink particles.*

Applies the same kernel-softened gravity (see above) to the direct-sum
sink–sink N-body integration. With ``h_soft_sinksink = 0.000``, the
interaction is exact Newtonian point-mass gravity:

.. math::

   \mathbf{a}_{ij} = -\frac{G M_j}{r_{ij}^2} \hat{\mathbf{r}}_{ij}

This is physically correct for well-separated bodies but can produce very
large accelerations (and correspondingly small timesteps, since
:math:`\Delta t \propto r_{ij}^{3/2} / M^{1/2}`) if two sinks pass very
close without merging.

**Recommendation**

``h_soft_sinksink = 0.000`` is fine provided ``r_merge_uncond`` is set to
catch close approaches before they cause extreme timestep reduction. If close
non-merging encounters are expected (e.g. wide binary fragments), a small
softening :math:`\lesssim r_\text{merge\_cond}` avoids runaway force
spikes without significantly altering the orbital dynamics.

----

Unconditional accretion fraction (``f_acc``)
---------------------------------------------

*Units: dimensionless (0–1). Applies to: gas particles within ``h_acc``.*

Splits the accretion zone into two sub-regions:

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Zone
     - Condition
     - Outcome
   * - Inner (unconditional)
     - :math:`r < f_\text{acc} \cdot h_\text{acc}`
     - Accrete immediately, no checks
   * - Outer (bound check)
     - :math:`f_\text{acc} \cdot h_\text{acc} \leq r < h_\text{acc}`
     - Accrete only if particle is bound to sink: :math:`E_\text{bind} < 0`

The bound-check criterion:

.. math::

   E_\text{bind} = \frac{1}{2}|\mathbf{v}_j - \mathbf{v}_\text{sink}|^2
                   - \frac{G M_\text{sink}}{|\mathbf{r}_j - \mathbf{r}_\text{sink}|} < 0

The inner zone prevents numerical ejections of particles that have already
fallen well inside the accretion radius and are effectively captured.

**Recommendation**

``f_acc = 0.800`` is the standard Phantom default and is appropriate for most
disc simulations. Values between 0.5 and 0.9 are reasonable; very low values
(approaching 0) remove the safety zone and can cause particles near the sink
boundary to be numerically scattered.

----

Unconditional merge radius (``r_merge_uncond``)
------------------------------------------------

*Units: AU. Applies to: sink–sink separations.*

Two sinks merge immediately when:

.. math::

   |\mathbf{r}_i - \mathbf{r}_j| < r_\text{merge\_uncond}

regardless of their relative velocity. The merged sink conserves mass and
linear momentum:

.. math::

   M' = M_i + M_j, \qquad
   \mathbf{v}' = \frac{M_i \mathbf{v}_i + M_j \mathbf{v}_j}{M_i + M_j}

This is primarily a **numerical safety valve**. At sub-resolution separations,
the orbital timestep constraint:

.. math::

   \Delta t_\text{orb} \sim \left(\frac{r^3}{G(M_i + M_j)}\right)^{1/2}

becomes prohibitively small — e.g. at :math:`r = 0.04` AU around a
0.2 M\ :sub:`☉` primary, :math:`\Delta t_\text{orb} \approx 0.1` yr, while
typical disc dump intervals are :math:`\sim 10^2\text{–}10^3` yr. Allowing
sinks to orbit at this separation would require millions of sub-steps.

**Recommendation**

Set ``r_merge_uncond`` to a few times the largest ``h_acc`` among all sinks,
and well above the scale where the orbital period becomes a meaningful fraction
of the smallest dynamical timestep you can afford:

.. math::

   r_\text{merge\_uncond} \gtrsim 10 \times h_\text{acc}

``r_merge_uncond = 0.040 AU`` is reasonable for the ``03pol0xx`` setup.
If ``h_acc`` is increased (as recommended above), ``r_merge_uncond`` should
be increased proportionally.

----

Conditional (bound) merge radius (``r_merge_cond``)
-----------------------------------------------------

*Units: AU. Applies to: sink–sink separations between* ``r_merge_cond`` *and* ``r_merge_uncond``.

Two sinks merge only if they are **mutually gravitationally bound** — their
two-body total orbital energy is negative:

.. math::

   E_{ij} = \frac{1}{2} \mu \, |\mathbf{v}_i - \mathbf{v}_j|^2
             - \frac{G M_i M_j}{r_{ij}} < 0

where :math:`\mu = M_i M_j / (M_i + M_j)` is the reduced mass. Sinks on a
hyperbolic (unbound) flyby at this separation survive; genuinely captured
pairs merge.

The gap between ``r_merge_cond`` and ``r_merge_uncond`` defines a regime
where **orbital physics decides fate**: bound orbits end in a merger, unbound
encounters continue. This is where binary fragment formation vs. ejection is
determined in the simulation.

**Recommendation**

``r_merge_cond`` should be comfortably above the numerical noise floor (a few
times ``h_acc``) but below the scale where physical binary formation at the
given resolution would be meaningful:

.. math::

   h_\text{acc} \lesssim r_\text{merge\_cond} \leq r_\text{merge\_uncond}

``r_merge_cond = 0.010 AU`` is consistent with ``r_merge_uncond = 0.040 AU``.
The 4:1 ratio between the two merge radii is a sensible separation.

----

Calculating h_sph and choosing parameter values
-------------------------------------------------

**Step 1 — compute the local smoothing length at the fragmentation radius**

Given disc mass :math:`M_d`, particle count :math:`N`, surface density slope
:math:`p`, aspect ratio :math:`H/R`, and fragmentation radius :math:`R_f`:

.. math::

   m_p &= \frac{M_d}{N} \\[4pt]
   \Sigma_0 &= \frac{M_d}{2\pi \displaystyle\int_{R_\text{in}}^{R_\text{out}} R^{1-p}\,dR}
   \quad \xrightarrow{p=1} \quad \frac{M_d}{2\pi(R_\text{out}-R_\text{in})} \\[4pt]
   \rho(R_f) &\approx \frac{\Sigma(R_f)}{\sqrt{2\pi}\,H(R_f)}
             = \frac{\Sigma_0 R_f^{-p}}{\sqrt{2\pi}(H/R)\,R_f} \\[4pt]
   h_\text{sph}(R_f) &= h_\text{fact}\left(\frac{m_p}{\rho(R_f)}\right)^{1/3}

Use :math:`R_f \sim 50\text{–}100` AU for where fragmentation is expected.
Use :math:`R_\text{in}` for the tightest scale any sink will encounter.

**Step 2 — resolution scaling with N**

Since :math:`m_p \propto N^{-1}` and :math:`\rho` is fixed by the disc,
:math:`h_\text{sph} \propto N^{-1/3}`. All sink length scales should scale
the same way:

.. list-table::
   :header-rows: 1
   :widths: 15 18 18 18 18

   * - Radius (AU)
     - N = 10\ :sup:`4`
     - N = 10\ :sup:`5`
     - N = 10\ :sup:`6`
     - N = 10\ :sup:`7`
   * - 1 AU
     - 0.32
     - 0.15
     - 0.07
     - 0.03
   * - 20 AU
     - 2.35
     - 1.09
     - 0.51
     - 0.24
   * - 50 AU
     - 4.33
     - 2.01
     - 0.93
     - 0.43
   * - 100 AU
     - 6.87
     - 3.19
     - 1.48
     - 0.69

*(0.2 M*\ :sub:`☉` *star, 0.059 M*\ :sub:`☉` *disc,* :math:`\Sigma \propto R^{-1}`,
:math:`H/R = 0.1`\ *)*

**Step 3 — apply the rules of thumb**

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parameter
     - Rule
   * - ``h_acc``
     - :math:`\sim h_\text{sph}(R_\text{in})` — resolved, but at the inner-disc scale
   * - ``r_merge_uncond``
     - :math:`\sim 10 \times h_\text{acc}`
   * - ``r_merge_cond``
     - :math:`\sim 2\text{–}3 \times h_\text{acc}` (keep ~4:1 ratio with ``r_merge_uncond``)
   * - ``h_soft_*``
     - 0.000 unless a specific scenario applies (see below)
   * - ``f_acc``
     - 0.800 unless a specific scenario applies (see below)

----

Forcing creation in hot cores (``f_crit_override``)
---------------------------------------------------

Sink creation requires the gas to pass the energy checks, which are evaluated
on the sphere of radius :math:`2h` around the densest particle. When that sphere
is a hot, pressure-supported core, the thermal-to-gravitational energy ratio can
be well above 1 and the test fails even though the fragment is bound on larger
scales. ``f_crit_override`` (default ``0``, off) creates a sink unconditionally
once the density exceeds ``f_crit_override * rho_crit_cgs``. For example,
``f_crit_override = 10`` creates a sink at ten times the creation density
whether or not the energy checks pass.

Before relying on the override, check that the gas around the new sinks is
bound (total energy negative inside the Hill radius) and that the sink mass
matches the bound mass just before creation.

----

When to change ``h_soft_*``, ``r_merge_*``, and ``f_acc``
-----------------------------------------------------------

**``h_soft_sinkgas`` — change when:**

- ``h_acc`` is intentionally set *below* the local :math:`h_\text{sph}` (e.g. to
  track very early fragment accretion). Without softening, gas particles at
  sub-:math:`h_\text{acc}` separations experience unbounded gravitational forces.
  Set :math:`h_\text{soft\_sinkgas} \approx h_\text{acc}` to cap the force.
- The simulation produces NaN accelerations or runaway particles near a sink —
  this is a sign that unsoftened sink–gas gravity is diverging.

**``h_soft_sinksink`` — change when:**

- Two or more fragment sinks are expected to form close binary-like pairs that
  survive without merging (e.g. studying binary fragment statistics). Without
  softening, close-pass encounters produce large force spikes and erratic
  timestep behaviour. Set :math:`h_\text{soft\_sinksink} \lesssim r_\text{merge\_cond}`
  to damp the spike without altering long-range orbital dynamics.
- The simulation wall-time per step increases sharply after a fragmentation event
  (sign of a small-timestep runaway from two nearby sinks).

**``r_merge_uncond`` — change when:**

- Wall-time per step increases sharply after the first fragmentation event, and
  inspection shows two sinks orbiting at sub-resolution separations. Increase
  ``r_merge_uncond`` to catch them earlier.
- Studying wide binary fragment formation: decrease ``r_merge_uncond`` (carefully,
  ensuring it stays above the timestep-stability floor) to allow wider pairs to
  survive without unconditionally merging.

**``r_merge_cond`` — change when:**

- Many fragments are forming and immediately merging even on clearly hyperbolic
  (unbound) trajectories. This means ``r_merge_cond`` is too large relative to
  the fragment separation at formation. Decrease it toward :math:`2 \times h_\text{acc}`.
- Studying close binary fragment survival: decrease to allow bound pairs at
  larger separations to be tracked without merging.

**``f_acc`` — change when:**

- Particles are being numerically ejected from sink neighbourhoods with high
  outward velocities (sign that the bound-check zone extends too far and unbound
  particles are crossing it). Increase ``f_acc`` toward 0.9 to widen the
  unconditional zone.
- Studying fragment accretion physics carefully, where you want *all* accretion
  to be subject to the bound check. Decrease ``f_acc`` toward 0.5, accepting
  that some very-close particles may scatter rather than accrete.

----

Summary table
-------------

.. list-table::
   :header-rows: 1
   :widths: 22 12 12 54

   * - Parameter
     - ``03pol002`` value
     - Recommended (N=10k disc)
     - Notes
   * - ``h_acc``
     - 0.001 AU
     - 0.5–1.0 AU
     - Should be ~ :math:`h_\text{sph}(R_\text{in})`; current value is sub-resolution
   * - ``h_soft_sinkgas``
     - 0.000
     - 0.000
     - Fine if ``h_acc`` is at resolution scale
   * - ``h_soft_sinksink``
     - 0.000
     - 0.000
     - Fine; set non-zero only if close non-merging encounters are expected
   * - ``f_acc``
     - 0.800
     - 0.800
     - Standard Phantom default; no change needed
   * - ``r_merge_uncond``
     - 0.040 AU
     - ~10 × ``h_acc``
     - Increase proportionally if ``h_acc`` is increased
   * - ``r_merge_cond``
     - 0.010 AU
     - ~2–3 × ``h_acc``
     - Maintain ~4:1 ratio with ``r_merge_uncond``
