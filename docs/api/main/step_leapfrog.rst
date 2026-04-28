.. phantom-doc: hand-written

step_leapfrog
=============

Overview
--------
The ``step_lf_global`` module implements Phantom's primary time-integration
algorithm: a velocity Verlet (leapfrog) integrator with operator splitting of
external and sink-particle forces. The module is the direct interface between
the outer time-loop in ``phantom.F90`` and the derivative evaluator in
``deriv``. Changing the integration scheme for the SPH particles requires
modifying this module.

The integrator follows the Reversible Reference System Propagator Algorithm
(RESPA) of Tuckerman, Berne & Martyna (1992), which enables the computationally
expensive SPH forces to be evaluated on a long timestep :math:`\Delta t_{\rm
SPH}` while the cheaper gravitational interactions between sink particles are
sub-stepped at a shorter timestep :math:`\Delta t_{\rm ext}`. This operator
splitting preserves time-reversibility and maintains the symplectic structure
of the integration.

The module supports both global timestepping, in which all particles share a
single :math:`\Delta t_{\rm SPH}`, and individual (hierarchical) timestepping,
activated at compile time by setting ``IND_TIMESTEPS=yes``. In individual
timestep mode each particle is assigned to a power-of-two *bin* :math:`k \in
\{0,\ldots,k_{\rm max}\}` with corresponding timestep :math:`\Delta t_k =
\Delta t_{\rm max}/2^k`. Particles on coarser bins are integrated with larger
steps and are only *active* — meaning their forces are re-evaluated — on a
fraction of global steps. The global SPH step size :math:`\Delta t_{\rm SPH}`
equals the finest bin timestep :math:`\Delta t_{k_{\rm max}}`. At the end of
every global step all particles, active or not, are synchronised to the common
time :math:`t^{n+1}` before the next derivative call.

For velocity-dependent forces — principally the SPH artificial viscosity —
the corrector step is iterated until the velocity difference between the
predicted and corrected values falls within the tolerance ``tolv``. Up to
``maxits = 30`` corrector iterations are permitted; failure to converge is a
fatal error, indicating the timestep is too large for the viscous timescale.

The SPH artificial viscosity parameter :math:`\alpha` is evolved within the
predictor loop. Depending on compile-time options, either the Morris & Monaghan
(1997) source-decay equation or the Cullen & Dehnen (2010) limiter is applied.
Both are integrated implicitly in time to ensure stability when the decay
timescale is shorter than the timestep.

Physical & Mathematical Description
-------------------------------------
The leapfrog (velocity Verlet) algorithm advances the phase-space variables
through one timestep :math:`\Delta t` in three conceptual stages,
following :cite:`price12`.

**Predictor (first half-kick):** velocities and thermal energy are advanced
by half a timestep using forces from the beginning of the step:

.. math::
   :label: lf_predict

   \mathbf{v}^{*} = \mathbf{v}^{n} + \tfrac{1}{2}\Delta t\,\mathbf{f}^{n}.

The predicted velocity :math:`\mathbf{v}^*` is then used to evaluate the SPH
forces at the full step.

**Drift and sub-step:** particle positions are advanced over the full step
during the sub-stepping phase, which is handled by the ``substep`` subroutine
in the ``substepping`` module. The smoothing length is updated within this step
via

.. math::

   h^{n+1} = h^n - \Delta t\,\frac{\partial h}{\partial \rho}\,\rho\,
             \nabla\!\cdot\!\mathbf{v},

where :math:`\partial h/\partial\rho` is the derivative of smoothing length
with respect to density, computed from the fixed neighbour-count condition.

**Corrector (second half-kick):** after the derivative evaluation at the
predicted state, the velocity is corrected:

.. math::
   :label: lf_correct

   \mathbf{v}^{n+1} = \mathbf{v}^{*} + \tfrac{1}{2}\Delta t\,\mathbf{f}^{n+1}.

Because the artificial viscosity force depends on the relative velocity
:math:`\mathbf{v}_{ab}`, it is velocity dependent. The corrector step
therefore iterates: if the normalised maximum velocity error

.. math::
   :label: lf_errmax

   \epsilon = \frac{\max_a |\mathbf{v}_a^{n+1} - \mathbf{v}_a^*|^2}
                   {\langle v^2 \rangle}

exceeds ``tolv``, the predicted velocity is reset to :math:`\mathbf{v}^{n+1}`,
the force is re-evaluated with ``icall=2`` (skipping the density step), and
the corrector is repeated.

The Morris & Monaghan (1997) viscosity switch evolves :math:`\alpha` according
to a source-decay equation integrated implicitly within each predictor step:

.. math::
   :label: alpha_mm97

   \alpha_a^{n+1} = \frac{\alpha_a^n + \Delta t\,(S_a + \alpha_{\rm min}
                    \tau_a^{-1})}{1 + \Delta t\,\tau_a^{-1}},
   \qquad
   \tau_a^{-1} = \frac{0.1\,c_{s,a}}{h_a},
   \qquad
   S_a = \max(0,{-\nabla\!\cdot\!\mathbf{v}_a}),

where :math:`c_{s,a}` is the sound speed and :math:`0.1` is ``avdecayconst``.
The Cullen & Dehnen (2010) switch sets :math:`\alpha_a` to the larger of
the current value and a target :math:`\alpha_{\rm loc}` computed from the
velocity-gradient tensor, decaying back to the minimum when no shock is present.

Individual Timesteps (``IND_TIMESTEPS=yes``)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When individual timesteps are compiled in, each particle carries an additional
state variable :math:`t^{\rm was}_a`, the time at which it was last located at
its own half-step point.  A precomputed lookup table ``ibin_dts`` stores, for
each bin :math:`k`:

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Entry
     - Value
   * - ``itdt``
     - :math:`\Delta t_k = \Delta t_{\rm max}/2^k`
   * - ``ithdt``
     - :math:`\tfrac{1}{2}\Delta t_k`
   * - ``itdt1``
     - :math:`1/\Delta t_k`
   * - ``ittwas``
     - :math:`t^{\rm was}_k = ({\rm floor}(t^{n+1}/\Delta t_k) + \tfrac{1}{2})\,\Delta t_k`

The last entry aligns ``twas`` to the nearest half-integer multiple of
:math:`\Delta t_k`, ensuring particles that are woken mid-step land on a
consistent half-step grid.

**Initialisation** (``init_step``).
At :math:`t = 0` every particle is placed on the finest bin
(:math:`k = k_{\rm max}`) so that the first derivative call is performed with
all particles active.  Boundary particles are fixed to bin 0 (coarsest) because
their forces are never evaluated and they must not constrain the global
timestep.  The initial ``twas`` for particle :math:`a` is

.. math::

   t^{\rm was}_a = t + \tfrac{1}{2}\,\Delta t_{k_a},

placing each particle's half-step at the midpoint of its first interval.

**Predictor (half-kick to** :math:`t^{\rm was}_a`\ **)**
In the predictor loop, active and inactive particles alike are advanced from the
current time :math:`t^n` to their individual half-step time:

.. math::
   :label: lf_ind_predict

   \delta t^{\rm pred}_a = t^{\rm was}_a - t^n, \qquad
   \mathbf{v}^*_a = \mathbf{v}^n_a + \delta t^{\rm pred}_a\,\mathbf{f}^n_a.

For a particle that has not changed bin, :math:`\delta t^{\rm pred}_a =
\tfrac{1}{2}\Delta t_{k_a}` exactly.

**SPH force prediction (kick to** :math:`t^{n+1}`\ **)**
After the substep advances :math:`t^n \to t^{n+1} = t^n + \Delta t_{\rm SPH}`,
the predicted velocity used in the force evaluation is formed by advancing each
particle from its half-step to the full-step end:

.. math::
   :label: lf_ind_vpred

   \delta t^{\rm sph}_a = t^{n+1} - t^{\rm was}_a, \qquad
   \mathbf{v}^{\rm pred}_a = \mathbf{v}^*_a + \delta t^{\rm sph}_a\,\mathbf{f}^n_a.

For a particle on the finest bin, :math:`\delta t^{\rm sph}_a =
\tfrac{1}{2}\Delta t_{k_{\rm max}}`; for coarser bins it is correspondingly
larger, since :math:`t^{\rm was}_a` is further behind :math:`t^{n+1}`.

**Corrector — active particles**
Particle :math:`a` is *active* on a given step if its bin counter indicates that
a full interval :math:`\Delta t_{k_a}` has elapsed.  The corrector applies two
half-kicks in sequence.

First, a corrector kick completing the full step from :math:`t^{\rm was,old}_a`:

.. math::
   :label: lf_ind_correct_active

   \delta t^{\rm corr}_a
     = (t^{n+1} - t^{\rm was}_a) + \tfrac{1}{2}\Delta t_{k_a^{\rm new}},
   \qquad
   \mathbf{v}^{n+1}_a = \mathbf{v}^*_a + \delta t^{\rm corr}_a\,\mathbf{f}^{n+1}_a,
   \qquad
   t^{\rm was}_a \leftarrow t^{\rm was}_a + \delta t^{\rm corr}_a.

The term :math:`t^{n+1} - t^{\rm was}_a` accounts for any mismatch between the
old half-step time and the end of the new step (e.g., when the particle has just
been woken to a different bin or when ``dtmax`` has been reduced).

Second, a *synchronisation* kick applied to **all** particles (active or not)
that brings them to the common time :math:`t^{n+1}`:

.. math::
   :label: lf_ind_sync

   \delta t^{\rm sync}_a = t^{n+1} - t^{\rm was}_a, \qquad
   \mathbf{v}^{n+1}_a \leftarrow \mathbf{v}^{n+1}_a
     + \delta t^{\rm sync}_a\,\mathbf{f}^{n+1}_a.

For active particles this synchronisation step is zero by construction (since
:math:`t^{\rm was}_a = t^{n+1}` after :eq:`lf_ind_correct_active`).  For
inactive particles it provides a small correction from the previous half-step
without a full force evaluation.

**Waking**
If the force evaluation determines that an inactive particle should move to a
shorter-timestep bin — signalled by ``ibin_wake(a) > ibin(a)`` — the particle
is *woken*: it is assigned to the requested bin and its ``twas`` is set to the
nearest half-grid point for that bin.  Waking only occurs during the corrector
and takes effect on the next global step.

**Convergence check**
The ``check_velocity_error`` routine computes the normalised velocity error
:eq:`lf_errmax`.  When ``IND_TIMESTEPS=yes``, the adaptive timestep-error
estimate ``dterr`` is not computed (only the global timestepping branch uses it)
and the damping-corrected tolerance path is likewise inactive.  Iteration
convergence is still checked against ``tolv`` for active particles.

Derivations
-----------
The RESPA operator-split construction separates the total Hamiltonian into a
slowly varying SPH part :math:`H_{\rm SPH}` and a fast external/sink part
:math:`H_{\rm ext}`. The Liouville propagator for one step :math:`\Delta t` is
approximated as

.. math::

   e^{i\mathcal{L}\Delta t} \approx
   e^{i\mathcal{L}_{\rm ext}\Delta t/2}\,
   e^{i\mathcal{L}_{\rm SPH}\Delta t}\,
   e^{i\mathcal{L}_{\rm ext}\Delta t/2}.

This leads to the sub-stepped scheme: the sink particles are integrated with
the fast force over :math:`N` sub-steps of duration :math:`\delta t =
\Delta t/N`, bracketed by half-kicks from the slow SPH force. The construction
is time-reversible by virtue of the palindromic ordering of the propagators.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

The following works are referenced in the text but not yet present in ``phantom.bib``:

- Tuckerman, M., Berne, B.J., & Martyna, G.J. 1992, J. Chem. Phys., 97, 1990 — RESPA multiple-timescale integrator
- Morris, J.P., & Monaghan, J.J. 1997, MNRAS, 290, 553 — artificial viscosity switch
- Cullen, L., & Dehnen, W. 2010, MNRAS, 408, 669 — artificial viscosity limiter

.. seealso::

   :doc:`deriv` — derivative evaluations called at each half-step.
   :doc:`evolve` — outer loop that controls timestep and calls step_leapfrog.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/step_leapfrog.f90
