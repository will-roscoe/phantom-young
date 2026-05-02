
Timestep Loop
==============

This page describes what happens for each timestep.

.. .. contents:: Contents
..    :local:
..    :depth: 1

----



State variables and notation
----------------------------

The following quantities are stored per particle :math:`a` at timestep :math:`n`:

.. list-table::
   :header-rows: 1
   :widths: 20 20 60
   
   * - Symbol
     - Code
     - Description
   * - :math:`\vec{x}_a^n`
     - ``xyzh(1:3,a)``
     - Position
   * - :math:`h_a^n`
     - ``xyzh(4,a)``
     - Smoothing length
   * - :math:`\vec{v}_a^n` 
     - ``vxyzu(1:3,a)`` 
     - Velocity 
   * - :math:`u_a^n` 
     - ``vxyzu(4,a)`` 
     - Specific thermal energy [u]_
   * - :math:`\vec{f}_a^n` 
     - ``fxyzu(1:3,a)`` 
     - Specific force — output of last ``derivs`` call 
   * - :math:`\dot{u}_a^n` 
     - ``fxyzu(4,a)`` 
     - Specific thermal energy rate — output of last ``derivs`` call [u]_ 
   * - :math:`(\div{\vec{v}})_a^n` 
     - ``divcurlv(1,a)`` 
     - Velocity divergence — output of last ``derivs`` call 
   * - :math:`m_a` 
     - ``massoftype(itype)`` 
     - Particle mass (constant) 


The following are computed on demand:

.. list-table::
    :header-rows: 1
    :widths: 20 20 60

    * - Symbol 
      - Code 
      - Description 

    * - :math:`\rho_a^n = \rho(h_a^n, m_a)` 
      - ``rhoh(h,m)`` 
      - Density from the fixed-neighbour-count condition 

    * - :math:`\left.\pd{h}{\rho}\right|_a` 
      -  ``dhdrho(h,m)`` 
      - Smoothing-length density slope; in 3D: :math:`-h_a/(3\rho_a)`

The **fixed-neighbour-count condition** requires each particle to enclose a fixed effective mass, 
giving :math:`\rho \propto m/h^3`. Differentiating yields :math:`\pd{h}{\rho} = -h/(3\rho)` in 3D.

The global step size :math:`\Delta t` (passed as ``dtsph``) is determined externally from 
``dtforce``, ``dtcourant``, and ``dterr``.

---

1) Global Timestepping (``IND_TIMESTEPS=no``)
----------------------------------------------

**Input:** :math:`\Delta t`, a single timestep shared by all particles. The step advances
 :math:`t^n \rar t^{n+1} = t^n + \Delta t`.

1.1) Predictor (first half-kick)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For each active non-boundary particle :math:`a`, advance using forces known at :math:`t^n`:

.. math:: 

	\mb{v}_a^* = \mb{v}_a^n + \frac{\Delta t}{2}\,\mb{f}_a^n


.. math:: 

	u_a^* = u_a^n + \frac{\Delta t}{2}\,\dot{u}_a^n
    
[u]_ [c]_


The result :math:`\mb{v}_a^*` is called the *predicted* (half-step) velocity and overwrites 
``vxyzu``. Optional fields are also half-kicked here [B]_ [r]_ [d]_.

1.2) Position drift (sub-step)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Positions are advanced over the full step using the half-step velocity:

.. math:: 

	\mb{x}_a^{n+1} = \mb{x}_a^n + \Delta t\,\mb{v}_a^*


Handled by ``substep_sph`` when no sinks or external forces are present, or by ``substep`` otherwise [s]_.

1.3) SPH prediction loop
^^^^^^^^^^^^^^^^^^^^^^^^^^

After the position drift, time is at :math:`t^{n+1}`. Two operations are performed.

**(i)** Update the smoothing length using :math:`\div{\mb{v}}` from the **previous** ``derivs`` 
call, evaluated at :math:`t^n`:

.. math:: 

	h_a^{n+1} = h_a^n - \Delta t \left.\pd{h}{\rho}\right|_a \rho_a^n\, (\div{\mb{v}})_a^n


**(ii)** Form the full-step predicted velocity. Since ``vxyzu`` already holds :math:`\mb{v}_a^*` 
(the half-step value), a further half-step using the same old forces gives:

.. math:: 

	\mb{v}_a^{\rm pred} = \mb{v}_a^* + \frac{\Delta t}{2}\,\mb{f}_a^n = \mb{v}_a^n + \Delta t\,\mb{f}_a^n


This is the best available estimate of :math:`\mb{v}_a^{n+1}` before the new force evaluation. Stored in 
``vpred``. Optional fields are similarly predicted [B]_ [r]_ [d]_ The artificial viscosity parameter :math:`\alpha_a` 
is updated here [t-alpha]_.

1.4) Force evaluation
^^^^^^^^^^^^^^^^^^^^^^

``derivs(1,...)`` is called with the predicted state :math:`(\mb{x}_a^{n+1},\, \mb{v}_a^{\rm pred},\, h_a^{n+1})`, yielding:

.. math:: 

	\mb{f}_a^{n+1} = \mb{f}(\mb{x}_a^{n+1},\, \mb{v}_a^{\rm pred},\, h_a^{n+1})


Also computed: :math:`\dot{u}_a^{n+1}` and :math:`(\div{\mb{v}})_a^{n+1}`. Results overwrite ``fxyzu`` and ``divcurlv``.

1.5) Corrector (second half-kick) and velocity iteration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The corrected full-step velocity is:

.. math:: 

	\mb{v}_a^{n+1} = \mb{v}_a^* + \frac{\Delta t}{2}\,\mb{f}_a^{n+1}


Because the artificial viscosity force depends on the pairwise relative velocity :math:`\mb{v}_{ab} = \mb{v}_a - \mb{v}_b`, 
the force :math:`\mb{f}_a^{n+1}` is itself a function of :math:`\mb{v}^{n+1}`, making the corrector implicit. 
Convergence is measured by the normalised maximum velocity error:

.. math:: 

	\epsilon = \frac{\displaystyle\max_a\left|\mb{v}_a^{n+1} - \mb{v}_a^{\rm pred}\right|^2}{\langle v^2 \rangle},
    \qquad \langle v^2 \rangle = \frac{1}{N}\sum_a \left|\mb{v}_a^{n+1}\right|^2


If :math:`\epsilon \leq \tm{tolv}`: converged; step complete. Otherwise, iterate (maximum :math:`\tm{maxits} = 30` times):

1. :math:`\mb{v}_a^{\rm pred} \lar \mb{v}_a^{n+1}`
2. :math:`\mb{v}_a^* \lar \mb{v}_a^{n+1} - \dfrac{\Delta t}{2}\,\mb{f}_a^{n+1}` — since :math:`\mb{v}_a^{n+1} = \mb{v}_a^* + \tfrac{\Delta t}{2}\mb{f}_a^{n+1}`, this correctly recovers the half-step state
3. Call ``derivs(2,...)`` with updated :math:`\mb{v}_a^{\rm pred}` (density step skipped)
4. Recompute corrector; check :math:`\epsilon`

Non-convergence after ``maxits`` iterations is a fatal error. On the first iteration, the error suggests a reduced timestep:

.. math:: 

	\Delta t_{\rm err} = \Delta t\sqrt{\tm{tolv}/\epsilon}


---

2) Individual Timestepping (``IND_TIMESTEPS=yes``)
---------------------------------------------------

Additional per-particle state:

.. list-table::
    :header-rows: 1
    :widths: 20 20 60

    * - Symbol 
      - Code 
      - Description 

    * - :math:`k_a \in \{0,\ldots,k_{\rm max}\}` 
      - ``ibin(a)`` 
      - Timestep bin (``kind=1`` integer) 

    * - :math:`t_a^{\rm was}` 
      - ``twas(a)`` 
      - Time at which particle :math:`a` was last at its own half-step 

    * - :math:`k_a^{\rm wake}` 
      - ``ibin_wake(a)`` 
      - Requested new bin, set by ``derivs`` 


Bin-timestep correspondence and global step size:

.. math:: 

	\Delta t_k = \frac{\Delta t_{\rm max}}{2^k}, \quad k \in \{0,\ldots,k_{\rm max}\}


where :math:`k = 0` is the coarsest (largest :math:`\Delta t`) and :math:`k = k_{\rm max}` is the finest. The global step is :math:`\Delta t_{\rm SPH} = \Delta t_{k_{\rm max}}`; the outer loop always advances by :math:`\Delta t_{\rm SPH}`.

A particle is **active** on a given step if an integer number of its own intervals :math:`\Delta t_{k_a}` have elapsed since its last correction. All others are **inactive**.

2.1) Initialisation (``init_step``; called once at :math:`t^0`)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All particles are placed on the finest bin so the first derivative call includes all particles:

.. math:: 

	k_a = k_{\rm max} \quad \forall\, a


Boundary particles are fixed at :math:`k_a = 0` since their forces are never evaluated and they must not constrain the global timestep. Each particle's initial half-step time is the midpoint of its first interval:

.. math:: 

	t_a^{\rm was} = t^0 + \tfrac{1}{2}\Delta t_{k_a}


2.2) Step start: precompute bin lookup table ``ibin_dts``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At the start of each step, for all bins :math:`k`:

.. list-table::
    :header-rows: 1
    :widths: 20 20 60

    * - Entry 
      - Value 
      - Description 
    * - ``itdt`` 
      - :math:`\Delta t_k` 
      - Timestep for bin :math:`k`  
    * - ``ithdt`` 
      - :math:`\frac{1}{2}\Delta t_k` 
      - Half-timestep for bin :math:`k` 
    * - ``itdt1`` 
      - :math:`1/\Delta t_k` 
      - Reciprocal timestep (avoids division in inner loops) 
    * - ``ittwas`` 
      - :math:`t_k^{\rm was} = \left(\left\lfloor\dfrac{t^{n+1}}{\Delta t_k}\right\rfloor + \dfrac{1}{2}\right)\Delta t_k` 
      - Target half-step grid time for bin :math:`k` 


where :math:`t^{n+1} = t^n + \Delta t_{\rm SPH}`. The expression :math:`t_k^{\rm was}` is the nearest half-integer multiple of :math:`\Delta t_k`, providing a consistent half-step grid for waking particles onto any bin.

2.3) Predictor
^^^^^^^^^^^^^^

Each particle is advanced from :math:`t^n` to its **own** half-step time :math:`t_a^{\rm was}`:

.. math:: 

	\delta t_a^{\rm pred} = t_a^{\rm was} - t^n


.. math:: 

	\mb{v}_a^* = \mb{v}_a^n + \delta t_a^{\rm pred}\,\mb{f}_a^n, \qquad u_a^* = u_a^n + \delta t_a^{\rm pred}\,\dot{u}_a^n  
[u]_ [c]_

For a particle that has not changed bin since its last correction:

.. math:: 

	t_a^{\rm was} = t^n + \tfrac{1}{2}\Delta t_{k_a} \implies \delta t_a^{\rm pred} = \tfrac{1}{2}\Delta t_{k_a}


More generally :math:`\delta t_a^{\rm pred}` differs from :math:`\tfrac{1}{2}\Delta t_{k_a}` when the particle was recently woken to a new bin or when :math:`\Delta t_{\rm max}` was reduced. Optional fields are also half-kicked here [B]_ [r]_ [d]_.

2.4) Position drift (sub-step)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Positions are advanced by :math:`\Delta t_{\rm SPH}` using each particle's own :math:`\mb{v}_a^*`:

.. math:: 

	\mb{x}_a^{n+1} = \mb{x}_a^n + \Delta t_{\rm SPH}\,\mb{v}_a^*


Time is advanced: :math:`t^n \rar t^{n+1} = t^n + \Delta t_{\rm SPH}`.

2.5) SPH prediction loop
^^^^^^^^^^^^^^^^^^^^^^^^^

Smoothing-length update is identical to the global case, using the old divergence:

.. math:: 

	h_a^{n+1} = h_a^n - \Delta t_{\rm SPH} \left.\pd{h}{\rho}\right|_a \rho_a^n\, (\div{\mb{v}})_a^n


The full-step velocity prediction uses each particle's own :math:`t_a^{\rm was}`:

.. math:: 

	\delta t_a^{\rm sph} = t^{n+1} - t_a^{\rm was}, \qquad \mb{v}_a^{\rm pred} = \mb{v}_a^* + \delta t_a^{\rm sph}\,\mb{f}_a^n


For the finest bin: :math:`\delta t_a^{\rm sph} = \tfrac{1}{2}\Delta t_{\rm SPH}`. For a coarser bin: :math:`\delta t_a^{\rm sph} > \tfrac{1}{2}\Delta t_{\rm SPH}`, since :math:`t_a^{\rm was}` is earlier in the step. Optional fields similarly predicted. Viscosity switch updated here [t-alpha]_.

2.6) Force evaluation
^^^^^^^^^^^^^^^^^^^^^^

Identical to the global case: ``derivs(1,...)`` called with :math:`(\mb{x}^{n+1},\, \mb{v}^{\rm pred},\, h^{n+1}) \rar \mb{f}^{n+1}`.

2.7) Corrector
^^^^^^^^^^^^^^^

Unlike the global case, **no velocity iteration** is performed.

**Active particles** — step 1, corrector kick from the old half-step to the new half-step:

.. math:: 

	\delta t_a^{\rm corr} = \underbrace{(t^{n+1} - t_a^{\rm was})}_{\text{remainder of old interval}} + \underbrace{\tfrac{1}{2}\Delta t_{k_a^{\rm new}}}_{\text{half of new interval}}


.. math:: 

	\mb{v}_a \lar \mb{v}_a^* + \delta t_a^{\rm corr}\,\mb{f}_a^{n+1}


.. math:: 

	t_a^{\rm was} \lar t_a^{\rm was} + \delta t_a^{\rm corr} = t^{n+1} + \tfrac{1}{2}\Delta t_{k_a^{\rm new}}


For an unchanged bin with no :math:`\Delta t_{\rm max}` change: :math:`\delta t_a^{\rm corr} = \tfrac{1}{2}\Delta t_{k_a} + \tfrac{1}{2}\Delta t_{k_a} = \Delta t_{k_a}`. Optional fields receive the same kick [B]_ [r]_ [d]_.

**All particles (active and inactive) — synchronisation kick:** every particle is brought to :math:`t^{n+1}` using the new forces:

.. math:: 

	\delta t_a^{\rm sync} = t^{n+1} - t_a^{\rm was}, \qquad \mb{v}_a \lar \mb{v}_a + \delta t_a^{\rm sync}\,\mb{f}_a^{n+1}


For an active particle after step 1: :math:`t_a^{\rm was} = t^{n+1} + \tfrac{1}{2}\Delta t_{k_{\rm new}}`, so :math:`\delta t_a^{\rm sync} = -\tfrac{1}{2}\Delta t_{k_{\rm new}}`. The net velocity change for an active particle with unchanged bin is therefore:

.. math:: 

	\Delta\mb{v}_a = \left(\Delta t_{k_a} - \tfrac{1}{2}\Delta t_{k_a}\right)\mb{f}_a^{n+1} = \tfrac{1}{2}\Delta t_{k_a}\,\mb{f}_a^{n+1}


Combined with the predictor, the full update recovers the standard leapfrog on the particle's own timestep :math:`\Delta t_{k_a}`:

.. math:: 

	\mb{v}_a^{n+1} = \mb{v}_a^n + \tfrac{1}{2}\Delta t_{k_a}\,\mb{f}_a^n + \tfrac{1}{2}\Delta t_{k_a}\,\mb{f}_a^{n+1}


For an **inactive** particle: :math:`t_a^{\rm was}` has not been updated since the particle's last active step, so :math:`\delta t_a^{\rm sync} > 0`. The sync applies a small correction using the new forces without re-evaluating density. :math:`t_a^{\rm was}` is unchanged by the sync; only the step-1 corrector kick updates it.

2.9) Waking
^^^^^^^^^^^

During the corrector, ``derivs`` may have set :math:`k_a^{\rm wake} > k_a` to indicate the particle requires a finer timestep. If so:

.. math:: 

	k_a \lar k_a^{\rm wake}, \qquad t_a^{\rm was} \lar \left(\left\lfloor\frac{t^{n+1}}{\Delta t_{k_a^{\rm wake}}}\right\rfloor + \frac{1}{2}\right)\Delta t_{k_a^{\rm wake}}, \qquad k_a^{\rm wake} \lar 0


The particle will be active from the next step onward with the shorter timestep :math:`\Delta t_{k_a^{\rm wake}}`.

.. rubric:: Footnotes

.. [u] Thermal energy (``maxvxyzu`` :math:`\geq 4`)
    For non-isothermal equations of state, ``vxyzu(4,a)`` stores :math:`u_a` and ``fxyzu(4,a)`` stores :math:`\dot{u}_a = Du/Dt`. All kick operations (predictor, corrector, sync) apply identically to :math:`u_a` as to :math:`\mb{v}_a`.

.. [c] Radiative cooling thermal energy (``icooling = 9``)
    When the ``radcool`` module is active, :math:`u_a` is evolved by an implicit solver at each kick rather than by the simple half-kick form:
    
    .. math:: 

        \mb{v}_{a,\,1:3}^* = \mb{v}_{a,\,1:3}^n + \tfrac{\Delta t}{2}\,\mb{f}_{a,\,1:3}^n

    .. math:: 

	    u_a^* = \tm{radcool\_evolve\_ui}(u_a^n,\; \tfrac{\Delta t}{2},\; a,\; T_{\rm floor},\; h_a^n)

    Velocity components 1:3 still receive the standard half-kick. This applies at every kick (predictor, corrector, sync).

.. [t-alpha] Artificial viscosity switch (``maxalpha = maxp``)
    Updated in the SPH prediction loop (A.3 / B.4) by an implicit Euler step over the full step :math:`\Delta t` (or :math:`\Delta t_{\rm SPH}`) for stability. Decay rate:
    
    .. math:: 

        \tau_a^{-1} = C_{\rm decay}\,\frac{c_{s,a}}{h_a}, \qquad C_{\rm decay} = 0.1 \quad (\tm{avdecayconst})

    **Morris & Monaghan (1997)** (``nalpha < 2``):
    
    .. math:: 

        \alpha_a^{n+1} = \frac{\alpha_a^n + \Delta t\left(S_a + \alpha_{\rm min}\,\tau_a^{-1}\right)}{1 + \Delta t\,\tau_a^{-1}}, \qquad S_a = \max\!\left(0,\,-(\div{\mb{v}})_a^n\right)

    **Cullen & Dehnen (2010)** (``nalpha >= 2``):
    
    .. math:: 

        \alpha_a^{n+1} = \begin{cases} \alpha_a^{\rm loc} & \text{if } \alpha_a^n < \alpha_a^{\rm loc} \\[4pt] \dfrac{\alpha_a^n + \Delta t\,\alpha_a^{\rm loc}\,\tau_a^{-1}}{1 + \Delta t\,\tau_a^{-1}} & \text{otherwise} \end{cases}

    where :math:`\alpha_a^{\rm loc}` is a target value computed from the velocity-gradient tensor by ``derivs`` and stored in ``alphaind(2,a)``.



.. [s] Sub-stepping with external/sink-particle forces
    When ``nptmass > 0``, ``iexternalforce > 0``, H:math:`_2` chemistry, step-cooling, or damping are present, ``substep_sph`` is replaced by ``substep``, which implements the RESPA operator split. The Liouville propagator for one step is approximated as:
    
    .. math:: 

        e^{i\mathcal{L}\Delta t} \approx e^{i\mathcal{L}_{\rm ext}\Delta t/2}\; e^{i\mathcal{L}_{\rm SPH}\Delta t}\; e^{i\mathcal{L}_{\rm ext}\Delta t/2}

    The external/sink forces are sub-stepped at interval :math:`\delta t = \Delta t_{\rm SPH}/N_s \leq \Delta t_{\rm ext}`, bracketed by half-kicks from the SPH force. The palindromic ordering preserves time-reversibility. 

.. [B] MHD magnetic field (``mhd``)
    The evolved magnetic field ``Bevol(:,a)`` and rate ``dBevol(:,a)`` are advanced with the same half-kick structure as :math:`\mb{v}_a` at every kick. Predicted values are stored in ``Bpred`` for use in ``derivs``.

.. [r] Radiation energy density (``do_radiation``)
    The radiation energy density ``rad(:,a)`` and rate ``drad(:,a)`` are evolved identically to _[B], with predicted values in ``radpred``. For implicit radiation (``implicit_radiation``): after ``derivs``, the updated ``radpred`` and ``vpred(4,a)`` are copied back to ``rad`` and ``vxyzu(4,a)``.

.. [d] Dust fraction and dust growth (``use_dustfrac``, ``use_dustgrowth``)
    ``dustevol(:,a)`` (dust fraction) and ``dustprop(:,a)`` (grain properties) are evolved by identical half-kicks from their rates. 
    The absolute value of ``dustevol`` is enforced after the predictor to prevent negative fractions. Predicted values ``dustpred`` and ``dustproppred`` are passed to ``derivs``. 
    When porosity is active (``use_porosity``), the filling factor ``filfac(a)`` is recomputed via ``get_filfac`` after each kick, using saved values ``mprev`` and ``filfacprev``.
