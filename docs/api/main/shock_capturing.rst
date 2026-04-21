.. phantom-doc: hand-written

shock_capturing
===============

Overview
--------
The ``shock_capturing`` module stores the parameters controlling Phantom's
artificial dissipation scheme and provides the utility functions used to
compute the Cullen & Dehnen (2010) shock-detection switch. Artificial
dissipation in SPH is necessary to capture shocks, which are inherently
non-smooth structures that cannot be represented by the smooth kernel
approximation. Without dissipation, the SPH equations produce unphysical
oscillations near discontinuities.

Phantom implements the standard approach of adding dissipative terms
proportional to inter-particle differences in velocity, thermal energy,
and (for MHD) magnetic field. The strength of each dissipation channel is
controlled by dimensionless parameters:

- ``alpha`` — artificial shear viscosity coefficient (or its minimum value
  when a switch is active).
- ``alphamax`` — maximum allowed viscosity when the per-particle switch
  ``alphaind`` is used.
- ``beta`` — coefficient of the non-linear (quadratic) viscosity term, which
  provides additional dissipation at strong shocks.
- ``alphau`` — artificial thermal conductivity coefficient, important for
  energy transfer at contact discontinuities.
- ``alphaB`` — artificial resistivity coefficient for MHD.

The module also stores the decay constant ``avdecayconst = 0.1``, which sets
the ratio of the viscosity decay timescale to the local sound-crossing time
:math:`h/c_s`.

When per-particle viscosity (``maxalpha == maxp``) is enabled, this module
provides the ``get_alphaloc`` function, which evaluates the Cullen & Dehnen
(2010) target viscosity based on the local velocity divergence time derivative,
and the ``xi_limiter`` function, which suppresses the viscosity in regions of
pure rotation by comparing the compressive and solenoidal parts of the velocity
gradient tensor.

Physical & Mathematical Description
-------------------------------------
The SPH artificial viscosity term added to the momentum equation is
:cite:`price12`

.. math::
   :label: av_term

   \left(\frac{d\mathbf{v}_a}{dt}\right)_{\rm AV}
   = -\sum_b m_b \Pi_{ab} \,\overline{\nabla_a W_{ab}},

where :math:`\overline{\nabla_a W_{ab}} = \tfrac{1}{2}[\nabla_a W_{ab}(h_a)
+ \nabla_a W_{ab}(h_b)]` and the viscosity tensor is

.. math::
   :label: Pi_ab

   \Pi_{ab} = \begin{cases}
     \dfrac{-\bar{\alpha}_{ab}\,v_{{\rm sig},ab}\,\mathbf{v}_{ab}\cdot\hat{\mathbf{r}}_{ab}
            + \bar{\beta}_{ab}\,(\mathbf{v}_{ab}\cdot\hat{\mathbf{r}}_{ab})^2}
            {\bar{\rho}_{ab}}
       & \mathbf{v}_{ab}\cdot\mathbf{r}_{ab} < 0, \\[6pt]
     0 & \text{otherwise,}
   \end{cases}

with :math:`\bar{\alpha}_{ab} = \tfrac{1}{2}(\alpha_a + \alpha_b)`,
:math:`\bar{\beta}_{ab} = \tfrac{1}{2}(\beta_a + \beta_b) = \beta` (constant),
:math:`\bar{\rho}_{ab} = \tfrac{1}{2}(\rho_a + \rho_b)`, and the signal
velocity :math:`v_{{\rm sig},ab} = c_{s,a} + c_{s,b} -
\beta\,\mathbf{v}_{ab}\cdot\hat{\mathbf{r}}_{ab}`.

The thermal energy equation receives a complementary dissipation term with
coefficient ``alphau``, and the MHD induction equation receives a resistive
term with coefficient ``alphaB``.

The Cullen & Dehnen (2010) target viscosity for particle :math:`a` is

.. math::
   :label: alphaloc

   \alpha_{\rm loc} = \max\!\left(\alpha_{\rm min},\;
   \min\!\left(\alpha_{\rm max},\;
   \frac{10\,h_a^2\,\xi_a\,\max(0,\,-\dot{\xi}_a\nabla\!\cdot\!\mathbf{v}_a)}
        {c_{s,a}^2}\right)\right),

where :math:`\dot{\xi}_a\nabla\!\cdot\!\mathbf{v}_a` is the material time
derivative of the velocity divergence, computed from the stored tensor
``dvdx``, and :math:`\xi_a` is the dimensionless limiter function

.. math::
   :label: xi_limiter

   \xi_a = \frac{\max(0,-\nabla\!\cdot\!\mathbf{v}_a)^2}
                {\max(0,-\nabla\!\cdot\!\mathbf{v}_a)^2 + |\nabla\!\times\!\mathbf{v}_a|^2},

which is unity in a pure compression and zero in pure rotation. This limiter
prevents the viscosity from being triggered in shear flows and vortices,
a significant improvement over the constant-:math:`\alpha` approach.

The actual per-particle :math:`\alpha_a` is evolved toward ``alphaloc`` on the
growth timescale set by ``alphaloc``, and decays back to zero on the timescale
:math:`\tau_a = h_a / (0.1\,c_{s,a})` as implemented in
``step_leapfrog`` during the predictor step.

Derivations
-----------
The viscosity tensor :eq:`Pi_ab` is a discrete analogue of the
Navier–Stokes viscous stress, designed to satisfy the Rankine–Hugoniot jump
conditions at shocks. The linear term :math:`\propto \alpha\,v_{\rm sig}\,
\mathbf{v}_{ab}\cdot\hat{\mathbf{r}}_{ab}` provides the bulk viscosity needed
to capture the velocity jump at a shock, while the quadratic term
:math:`\propto \beta\,(\mathbf{v}_{ab}\cdot\hat{\mathbf{r}}_{ab})^2` gives
additional dissipation at strong shocks, mimicking the von Neumann–Richtmyer
artificial pressure. The condition :math:`\mathbf{v}_{ab}\cdot\mathbf{r}_{ab}
< 0` restricts dissipation to converging flows, preventing spurious damping
in rarefactions and bulk expansions.

The Cullen & Dehnen limiter function :eq:`xi_limiter` is derived from the
Helmholtz decomposition of the velocity gradient into divergence (compressive)
and curl (solenoidal) parts. In a pure compression :math:`|\nabla\!\times\!
\mathbf{v}| = 0`, so :math:`\xi = 1`; in pure rotation
:math:`\nabla\!\cdot\!\mathbf{v} = 0`, so :math:`\xi = 0`. The
material-derivative trigger :math:`\dot{\xi}_a\nabla\!\cdot\!\mathbf{v}_a`
ensures that viscosity is switched on only when a compression is actually
strengthening, not during the post-shock relaxation phase.

References
----------
The artificial viscosity formulation and the overall Phantom algorithm are
described in :cite:`price12`. The Morris & Monaghan (1997) source-decay
viscosity switch (MNRAS 290, 553–573) and the Cullen & Dehnen (2010) limiter
(MNRAS 408, 669–683) are referenced in the code but are not yet in
``phantom.bib`` — citation keys are needed for inline citations.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/shock_capturing.f90
