.. phantom-doc: hand-written

dynamic_dtmax
=============

Overview
--------
The ``dynamic_dtmax`` module manages the adaptive adjustment of the maximum
allowed SPH timestep ``dtmax``. This parameter controls the frequency of dump
output and, when individual timesteps are used, the coarsest level of the
timestep hierarchy. In most simulations ``dtmax`` is fixed by the user; this
module provides two mechanisms for adjusting it automatically during a run
without user intervention.

The first mechanism monitors large changes in the maximum gas density between
successive steps. When the density ratio :math:`\rho_{\rm max}^{\rm
new}/\rho_{\rm max}^{\rm old}` exceeds a user-defined threshold
``dtmax_dratio``, the module decreases ``dtmax`` by a power of two to maintain
temporal resolution during collapse or accretion events. Conversely, when the
density stabilises or decreases, ``dtmax`` may be increased by up to a factor
of two per step, subject to the user-set ceiling ``dtmax_max``.

The second mechanism enforces a wall-clock time limit between dumps. If the
wall time per dump ``twallperdump`` exceeds ``dtwallmax`` (specified as
``hhh:mm`` in the input file), ``dtmax`` is halved enough times to bring the
output frequency within the wall-time budget. When the wall time per dump falls
below half of ``dtwallmax`` and there are currently multiple sub-dumps per user
dump, the module increases ``dtmax`` again. This mechanism allows long runs to
continue on HPC clusters with strict wall-time limits by writing intermediate
"restart" dumps at increased frequency.

Both mechanisms operate by setting the integer ``dtmax_ifactor``: positive
values indicate a decrease by that factor, negative values an increase by the
magnitude. The factor is always a power of two to keep the timestep hierarchy
consistent. The actual modification of ``dtmax`` is performed either immediately
(for global timestepping) or deferred to the next step (for individual
timestepping).

Physical & Mathematical Description
-------------------------------------
The density-based criterion tracks the logarithmic rate of change of the
maximum density:

.. math::
   :label: dtmax_density

   \delta = \log_{10}\!\left(\frac{\rho_{\rm max}^{\rm new}}
                                   {\rho_{\rm max}^{\rm old}}\right),
   \qquad
   p = -\left\lfloor \frac{\delta}{\log_{10}(\texttt{dtmax\_dratio})} \right\rfloor.

When :math:`p < 0` (density increasing faster than the threshold), ``dtmax``
is multiplied by :math:`2^p` (i.e. divided by :math:`2^{|p|}`), subject to the
lower limit ``dtmax_min`` and a maximum decrease factor of :math:`2^2 = 4` per
step to prevent sudden large reductions. When :math:`p > 0` (density decreasing
or stable), ``dtmax`` is multiplied by :math:`\min(2^p, 2)` provided
``dtmax_user * factor <= dtmax_max``.

The wall-time criterion computes the increase factor as

.. math::

   f = 2^{\,\lfloor \log_2(t_{\rm wall}/t_{\rm wall,max}) \rfloor + 1},

which is the smallest power of two sufficient to reduce the wall time per dump
below ``dtwallmax``.

The ``idtmax_n`` and ``idtmax_frac`` integers track the sub-dump structure:
``idtmax_n`` is the number of SPH steps per user dump, and ``idtmax_frac`` is
the current position within that cycle. The ``check_for_restart_dump`` routine
updates these counters after each step.

Derivations
-----------
Both criteria are straightforward from first principles and require no
non-trivial derivation. The density-based criterion is a direct application
of the logarithm of the density ratio to determine how many powers of two the
timestep should change; the formula in :eq:`dtmax_density` is the
closed-form expression of that integer floor operation. The wall-time criterion
is an analogous floor operation on the base-2 logarithm of the ratio of
actual to desired wall time per dump. The adaptive :math:`2^p` quantisation
ensures compatibility with the individual-timestep bin hierarchy, which
requires all timesteps to be powers of two times a base timestep. This module
is an internal Phantom convention with no corresponding external literature
reference.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/dynamic_dtmax.f90
