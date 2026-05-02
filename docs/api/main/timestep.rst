.. phantom-doc: hand-written

timestep
========

Overview
--------
The ``timestep`` module stores the global timestep control parameters and
provides I/O routines for reading and writing them from the Phantom ``.in``
input file. It does not itself compute the timestep; that computation is
distributed across the force and density loops in the ``forces`` and
``densityforce`` modules, which update the module-level variables
``dtcourant``, ``dtforce``, and ``dtrad`` as side effects of the particle
loop.

The module defines the Courant safety factor ``C_cour``, the force safety
factor ``C_force``, and the velocity-error tolerance ``tolv`` used in the
leapfrog corrector iteration. For MHD runs it additionally stores the
hyperbolic divergence-cleaning parameters ``psidecayfac`` and
``overcleanfac``. For general-relativistic runs the position and momentum
iteration tolerances ``xtol`` and ``ptol`` are included.

The chosen timestep at each step is the minimum over all active constraints:

.. math::

   \Delta t = \min(\Delta t_{\rm Courant},\;\Delta t_{\rm force},\;
                   \Delta t_{\rm rad},\;\Delta t_{\rm max}),

where each component is described below. This ensures that neither
compressibility waves nor acceleration-driven displacements exceed safe
fractions of the smoothing length in a single step.

Physical & Mathematical Description
-------------------------------------
**Courant condition.** The SPH Courant timestep for particle :math:`a` is

.. math::
   :label: dt_courant

   \Delta t_{{\rm Courant},a} = C_{\rm cour}\,\frac{h_a}{v_{{\rm sig},a}},

where :math:`h_a` is the smoothing length and :math:`v_{{\rm sig},a}` is the
maximum signal velocity over all neighbour pairs involving particle :math:`a`.
The signal velocity for a pair :math:`(a,b)` is

.. math::

   v_{{\rm sig},ab} = c_{s,a} + c_{s,b} - \beta\,
                      \min\!\left(0,\,
                      (\mathbf{v}_a-\mathbf{v}_b)\cdot\hat{\mathbf{r}}_{ab}\right),

with :math:`\beta` the non-linear viscosity coefficient (default 2). For MHD
the signal velocity includes the fast magnetosonic speed.

**Force condition.** The acceleration timestep is

.. math::
   :label: dt_force

   \Delta t_{{\rm force},a} = C_{\rm force}\sqrt{\frac{h_a}{|\mathbf{f}_a|}},

which limits the displacement due to the acceleration to a fraction of
:math:`h_a`.

**Global maximum.** The parameter ``dtmax`` imposes an upper bound on the
timestep, ensuring regular output regardless of the physical timescale.

**Radiation condition.** When radiation transport is active, an additional
timestep :math:`\Delta t_{\rm rad}` based on the radiation energy equation is
computed with safety factor ``C_rad`` (default 0.8, following Biriukov & Price
2019).

**Velocity-error tolerance.** The scalar ``tolv`` (default :math:`10^{-2}`)
controls when the leapfrog corrector iteration converges. If the maximum
normalised velocity change across all particles exceeds ``tolv``, the corrector
is repeated; if the required timestep from this error criterion ``dterr`` is
smaller than the current step, the timestep is reduced for the next cycle.

**Divergence-cleaning (MHD).** The parameter ``psidecayfac`` sets the ratio
of parabolic to hyperbolic cleaning coefficients, and ``overcleanfac``
multiplies the hyperbolic cleaning speed, decreasing :math:`\Delta t_{\rm
Courant}` by the same factor.

Synchronisation Points
----------------------

A *sync point* is a moment at which every live particle's state is
self-consistent at the same physical time :math:`t`. The frequency and
nature of sync points differs between the two timestepping modes.

**Global timestepping (** ``IND_TIMESTEPS=no`` **)**

Every leapfrog step is a sync point. All :math:`N_{\rm part}` particles
share the same :math:`\Delta t`, so after every call to ``step`` in
``evol`` the entire system sits at :math:`t^n + \Delta t`. The
``at_dump_time`` flag in ``evol_poststep`` becomes true whenever the
simulation time reaches the next scheduled output time ``tprint``, which
advances by ``dtmax`` after every dump. The number of steps between
dumps therefore depends on ``dtmax / dt``; under normal operation this
ratio fluctuates with the Courant condition.

.. list-table:: Global-timestep event schedule
   :header-rows: 1
   :widths: 30 30 40

   * - Event
     - Fires when
     - Location
   * - All-particle sync
     - Every step
     - ``step`` corrector, ``step_leapfrog.f90``
   * - Energy / ``.ev`` file
     - Every :math:`\Delta t_{\rm max}` (``at_dump_time``)
     - ``write_ev_files``, ``evolve_utils.F90``
   * - Full dump
     - Every :math:`\Delta t_{\rm max}` (``at_dump_time``)
     - ``check_and_write_dump``, ``evolve_utils.F90``
   * - ``check_dtmax_for_decrease``
     - Every dump (``at_dump_time``)
     - ``evol_poststep``, ``evolve.f90``
   * - Dynamic boundaries
     - Every dump (``at_dump_time``)
     - ``evol_poststep``, ``evolve.f90``

**Individual timestepping (** ``IND_TIMESTEPS=yes`` **)**

Particles are partitioned into bins :math:`k \in \{0, \ldots, k_{\rm
max}\}` with per-bin timestep :math:`\Delta t_k = \Delta t_{\rm
max}/2^k`. The global loop always advances by the finest-bin step
:math:`\Delta t_{\rm SPH} = \Delta t_{k_{\rm max}}`. The step counter
``istepfrac`` (in ``timestep_ind``) increments by one each iteration and
resets to zero after every dump; it ranges over
:math:`[1,\; 2^{k_{\rm max}}]`. One complete cycle of ``istepfrac``
spans exactly one :math:`\Delta t_{\rm max}` interval.

A particle in bin :math:`k` is **active** — has its forces recomputed —
when

.. math::

   \texttt{istepfrac} \bmod 2^{k_{\rm max} - k} = 0,

so the finest-bin particles are active on every step, coarser-bin
particles on every :math:`2^{k_{\rm max}-k}` steps. All particles are
active simultaneously exactly when ``istepfrac == 2**nbinmax``; this is
the **full sync point** and occurs once per :math:`\Delta t_{\rm max}`
interval, coinciding with every dump.

Even between full sync points the leapfrog corrector in ``step``
applies a *synchronisation kick* to every particle (active or not),
bringing all velocities to the common end time :math:`t^{n+1}`. This
uses the most recently evaluated forces and does not require a new
density or derivative evaluation. Positions and smoothing lengths are
always advanced for all particles during the substep.

.. list-table:: Individual-timestep event schedule
   :header-rows: 1
   :widths: 30 30 40

   * - Event
     - Fires when
     - Location
   * - Finest-bin particle sync
     - Every step (every :math:`\Delta t_{\rm SPH}`)
     - ``step`` corrector, ``step_leapfrog.f90``
   * - Bin-:math:`k` particle active
     - Every :math:`2^{k_{\rm max}-k}` steps
     - ``set_active_particles``, ``utils_indtimesteps.f90``
   * - Full all-particle sync
     - ``istepfrac == 2**nbinmax`` (every :math:`\Delta t_{\rm max}`)
     - ``evol_prestep``, ``evolve.f90``
   * - ``check_dtmax_for_decrease``
     - ``istepfrac == 2**nbinmax``
     - ``evol_prestep``, ``evolve.f90``
   * - Dynamic boundaries
     - ``istepfrac == 2**nbinmax`` and ``nactive == nalive``
     - ``evol_prestep``, ``evolve.f90``
   * - Energy / ``.ev`` file
     - Every :math:`\Delta t_{\rm max}` (``at_dump_time``)
     - ``write_ev_files``, ``evolve_utils.F90``
   * - Full dump
     - Every :math:`\Delta t_{\rm max}` (``at_dump_time``)
     - ``check_and_write_dump``, ``evolve_utils.F90``

**Relationship between sync period and dump frequency**

Under both modes each dump corresponds to exactly one
:math:`\Delta t_{\rm max}` interval. Under global timestepping many
physical steps may separate dumps; under individual timestepping exactly
:math:`2^{k_{\rm max}}` fine steps separate them. Because ``tprint``
advances by ``dtmax`` after every dump (``evolve.f90:init_counters``,
``update_dump_counters``), increasing ``dtmax`` both coarsens the finest
allowable timestep and spaces out dumps.

**Adding a custom sync-point routine**

Any operation that requires all particles to share a consistent time
:math:`t` should be inserted in ``evol_prestep`` (``evolve.f90``) after
the ``set_active_particles`` call, guarded as follows:

.. code-block:: fortran

   use dim,          only: ind_timesteps
   use timestep_ind, only: istepfrac, nbinmax

   if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) then
      call my_sync_routine(npart, xyzh, vxyzu, time)
   endif

This guard fires on every step under global timestepping (where every
step is a sync point) and exactly once per :math:`\Delta t_{\rm max}`
under individual timestepping.

Derivations
-----------
The Courant condition in SPH differs from the classical grid-based form because
the relevant wave-crossing time is :math:`h/v_{\rm sig}` rather than the cell
width divided by the signal velocity. The factor :math:`C_{\rm cour} = 0.3`
is the default; values above approximately 0.5 begin to degrade the accuracy
of the scheme for strongly compressible flows.

The force condition :math:`\Delta t \propto \sqrt{h/|f|}` arises from
requiring that the acceleration-induced displacement in one step is bounded
by a fixed fraction of the smoothing length:

.. math::

   \frac{1}{2}|\mathbf{f}|\Delta t^2 \lesssim C_{\rm force}\,h,
   \qquad
   \Rightarrow\quad \Delta t \lesssim \sqrt{\frac{2\,C_{\rm force}\,h}{|\mathbf{f}|}}.

The factor of 2 is absorbed into ``C_force``.

References
----------
The Courant–Friedrichs–Lewy (CFL) stability condition is the foundational
reference for the Courant timestep constraint: Courant, Friedrichs & Lewy
(1928), Mathematische Annalen 100, 32–74 (not yet in phantom.bib — citation
key needed). The SPH-specific formulation of the Courant and force conditions
is discussed in :cite:`price12`.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/timestep.f90
