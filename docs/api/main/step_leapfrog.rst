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
single :math:`\Delta t`, and individual (hierarchical) timestepping, in which
each particle is assigned to a power-of-two timestep bin. In individual
timestep mode the corrector step synchronises all particles to a common time
before the next global diagnostic output.

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
through one timestep :math:`\Delta t` in three conceptual stages.

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
The velocity Verlet (leapfrog) algorithm is described in Verlet (1967),
Physical Review 159, 98–103 (not yet in phantom.bib — citation key needed).
The Morris & Monaghan (1997) source-decay viscosity switch is given in MNRAS
290, 553–573 (not yet in phantom.bib — citation key needed). The Cullen &
Dehnen (2010) limiter is described in MNRAS 408, 669–683 (not yet in
phantom.bib — citation key needed). The RESPA operator-splitting scheme
follows Tuckerman, Berne & Martyna (1992), J. Chem. Phys. 97, 1990–2001 (not
yet in phantom.bib — citation key needed).

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/step_leapfrog.f90
