.. phantom-doc: hand-written

Subgroup Integrator Utilities
==============================

Overview
--------

The ``utils_subgroup`` module supplies the low-level building blocks used by the
``subgroup`` module to implement the Time-Transformed Leapfrog (TTL) integrator for
compact N-body subgroups. It contains the Yoshida sixth-order symplectic coefficients,
time-synchronisation routines, state save/restore utilities, and centre-of-mass helper
routines.

The symplectic coefficients ``cks`` and ``dks`` define the 8-stage Yoshida sequence that
drives the TTL drift and kick operators. A companion array ``cck_sorted`` and index mapping
``cck_sorted_id`` order the cumulative time fractions of the stages by increasing value;
this ordering is used by the synchronisation algorithm ``new_ds_sync_sup`` to identify
which stage boundary is closest to the external target time :math:`t_{\rm end}` and to
compute a corrected step size.

The time-synchronisation logic in ``converge_to_tend`` controls the adaptive stepping of
each subgroup: it decides whether to store the current state as a checkpoint, restore to a
previous checkpoint and retry with a smaller :math:`\mathrm{d}s`, or accept the step and
advance. Step adjustments follow a power-of-two rounding scheme (``regularstepfactor``) to
maintain numerical cleanliness of the regularised time variable.

The ``get_com`` and ``get_bin_com`` routines compute mass-weighted centre-of-mass positions
and velocities for a subgroup or a pair of particles. Coordinate transformations
``world_to_com`` and ``com_to_world`` convert between the global (world) frame and the
centre-of-mass frame in which the TTL integration is performed. Helper routines
``get_subgroup``, ``get_binary``, and ``get_nneigh`` extract group membership and binary
orbital parameters from the packed ``group_info`` and ``bin_info`` arrays.

Physical & Mathematical Description
-------------------------------------

**Yoshida coefficients.** The 8-stage sixth-order Yoshida symplectic coefficients are:

.. math::

   c_k : \quad 0.3923,\; 0.5100,\; -0.4711,\; 0.0688,\;
               0.0688,\; -0.4711,\; 0.5100,\; 0.3923

.. math::

   d_k : \quad 0.7845,\; 0.2356,\; -1.1777,\; 1.3152,\;
               -1.1777,\; 0.2356,\; 0.7845,\; 0.0000

The cumulative time fractions are :math:`\tilde{c}_k = \sum_{j=1}^{k} c_j / \sum c_j`,
stored sorted in ``cck_sorted``.

**Centre of mass.** For a subgroup of :math:`N` particles the centre-of-mass position
and velocity are:

.. math::

   \mathbf{x}_{\rm com} = \frac{\sum_a m_a \mathbf{x}_a}{\sum_a m_a}, \qquad
   \mathbf{v}_{\rm com} = \frac{\sum_a m_a \mathbf{v}_a}{\sum_a m_a}

**Synchronisation.** The target coordinate time is :math:`t_{\rm end}`. After each
TTL step the achieved time increment :math:`\Delta t` may overshoot :math:`t_{\rm end}`.
The synchronisation algorithm locates the stage boundary :math:`k^*` satisfying
:math:`\tilde{c}_{k^*-1} \leq t_{\rm end}/t_{\rm step} < \tilde{c}_{k^*}` and adjusts
:math:`\mathrm{d}s` so that the integrator lands exactly on :math:`t_{\rm end}` within
tolerance ``time_error = 2.5e-12``.

References
----------

Mikkola & Aarseth (2002) — not yet in phantom.bib.
Yoshida (1990), Phys. Lett. A 150, 262 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_subgroup.f90
