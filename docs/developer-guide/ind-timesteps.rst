Individual timesteps: sync points and custom hooks
==================================================

This page explains where all particles share the same simulation time when
``IND_TIMESTEPS=yes`` is compiled, and how to inject a custom routine that
runs at those sync points.

.. contents:: Contents
   :local:
   :depth: 1

----

The bin hierarchy
-----------------

Each particle is assigned to an integer bin :math:`b_i \in [0,\, b_\text{max}]`.
Its individual timestep is

.. math::

   \Delta t_i = \frac{\Delta t_\text{max}}{2^{b_i}}.

Bin 0 is the coarsest level (:math:`\Delta t_\text{max}`); bin
:math:`b_\text{max}` (``nbinmax``) is the finest
(:math:`\Delta t_\text{max} / 2^{b_\text{max}}`). The arrays ``ibin(i)``
and ``iphase(i)`` in ``part`` store each particle's current bin and
active/inactive status respectively.

The step counter: ``istepfrac``
--------------------------------

The module ``timestep_ind`` (``utils_indtimesteps.f90``) maintains a counter
``istepfrac`` that advances by 1 each main-loop iteration and resets to 0
after every dump. Its range is :math:`[1, 2^{b_\text{max}}]`. One full cycle
of ``istepfrac`` corresponds to exactly one :math:`\Delta t_\text{max}`
interval.

At each iteration ``set_active_particles`` marks particle :math:`i` as active
when

.. math::

   \texttt{istepfrac} \bmod 2^{b_\text{max} - b_i} = 0.

This means:

.. list-table::
   :header-rows: 1
   :widths: 25 35 40

   * - Bin
     - Timestep
     - Active when
   * - ``nbinmax`` (finest)
     - :math:`\Delta t_\text{max}/2^{b_\text{max}}`
     - every step (mod 1 = 0 always)
   * - ``nbinmax − 1``
     - :math:`\Delta t_\text{max}/2^{b_\text{max}-1}`
     - every 2 steps
   * - ``nbinmax − k``
     - :math:`\Delta t_\text{max}/2^{b_\text{max}-k}`
     - every :math:`2^k` steps
   * - ``0`` (coarsest)
     - :math:`\Delta t_\text{max}`
     - only when ``istepfrac == 2**nbinmax``

The full sync point
-------------------

All particles are simultaneously active — and therefore all at the same
physical time — **exactly when** ``istepfrac == 2**nbinmax``.  This occurs
once per :math:`\Delta t_\text{max}` interval, just before a snapshot dump.

The code already uses this condition in ``evol_prestep`` (``evolve.f90``) for
several built-in operations:

.. code-block:: fortran

   ! check whether dtmax needs to be reduced
   if (istepfrac == 2**nbinmax) then
      call check_dtmax_for_decrease(...)
   endif

   ! update dynamic boundaries
   if (dynamic_bdy .and. nactive==nalive .and. istepfrac==2**nbinmax) then
      call update_boundaries(...)
   endif

There is also a convenience flag ``all_active`` in ``part`` that
``set_active_particles`` sets to ``.true.`` whenever ``nactive == nalive``
(all live particles active), which is equivalent for normal runs.

Adding a custom sync-point routine
-----------------------------------

The recommended injection point is ``evol_prestep`` in ``evolve.f90``,
immediately after the existing ``set_active_particles`` call (around line 221):

.. code-block:: fortran

   use dim,          only: ind_timesteps
   use timestep_ind, only: istepfrac, nbinmax

   ! ... existing code ...
   call set_active_particles(npart,nactive,nalive,nactivetot,nalivetot,iphase,ibin,xyzh)

   ! run custom routine at every sync point, under both global and ind. timesteps
   if (.not. ind_timesteps .or. istepfrac == 2**nbinmax) then
      call my_sync_routine(npart, xyzh, vxyzu, fxyzu, time)
   endif

The ``use dim, only: ind_timesteps`` guard ensures the same call site works
when the code is compiled without ``IND_TIMESTEPS``, where every step is
trivially a sync point (``nactive == npart`` always).

What is safe to read and modify at the sync point
--------------------------------------------------

At ``istepfrac == 2**nbinmax`` every particle's data is self-consistent at
time :math:`t`:

.. list-table::
   :header-rows: 1
   :widths: 30 15 55

   * - Array
     - Safe to modify?
     - Notes
   * - ``xyzh(4,npart)``
     - Yes
     - Positions and smoothing lengths all valid at :math:`t`
   * - ``vxyzu(4,npart)``
     - Yes
     - Velocities and specific internal energies valid at :math:`t`
   * - ``fxyzu(4,npart)``
     - Yes
     - Forces will be recomputed by ``derivs`` on the next step
   * - ``iphase(npart)``
     - No
     - Managed by ``set_active_particles``; do not set directly
   * - ``ibin(npart)``
     - No
     - Use the ``update_ibin`` machinery; do not assign directly
   * - ``istepfrac``, ``nbinmax``
     - No
     - Owned by ``timestep_ind``; modifying breaks the step hierarchy

.. seealso::

   :doc:`../api/main/utils_indtimesteps` — ``timestep_ind`` module: ``nbinmax``, ``istepfrac``, ``set_active_particles``.

   :doc:`../api/main/evolve` — ``evol_prestep`` and ``evol_poststep``, the recommended injection sites.
