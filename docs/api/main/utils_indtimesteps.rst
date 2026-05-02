.. phantom-doc: hand-written

utils_indtimesteps
==================

Overview
--------

The ``timestep_ind`` module provides the parameters, state variables, and
utility routines for Phantom's hierarchical individual-timestep scheme.
When compiled with ``-DIND_TIMESTEPS``, each SPH particle is assigned to a
timestep bin such that its timestep :math:`\Delta t_i = \Delta t_\text{max}
/ 2^{b_i}` is a power-of-two fraction of the global maximum timestep. Only
particles in the currently active bin are updated at each sub-step.

The module stores ``nbinmax`` (the maximum bin index in use), ``ibinnow``
(the current active bin), ``istepfrac`` (the current fraction of
:math:`\Delta t_\text{max}` elapsed), ``nactive`` and ``nactivetot`` (the
number of active particles in the current sub-step), and per-bin timing
statistics in ``timeperbin``. Utility routines include
``print_dtind_efficiency`` (reports the fraction of particles active at
each step), ``update_time_per_bin`` (accumulates CPU time per bin for
load-balance diagnostics), and ``print_dtlog_ind`` (formats the individual
timestep log summary).

Physical & Mathematical Description
------------------------------------

In the individual timestep scheme, particle :math:`i` is assigned to bin
:math:`b_i = \lfloor \log_2(\Delta t_\text{max} / \Delta t_i) \rfloor`,
so its timestep is :math:`\Delta t_i = \Delta t_\text{max} / 2^{b_i}`.
At the :math:`k`-th sub-step of bin :math:`b_i`, particles in bins
:math:`b \leq b_i` (i.e., coarser bins) are synchronised and their forces
recomputed. The efficiency gain over a global timestep is
:math:`\eta = N_\text{active}/N_\text{total}`, which can be large (factor
10–100) for simulations with a wide dynamic range in timesteps.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`../../developer-guide/ind-timesteps` — sync points, the ``istepfrac`` counter, and how to add a custom routine that runs when all particles are at the same time.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_indtimesteps.f90
