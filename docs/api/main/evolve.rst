.. phantom-doc: hand-written

evolve
======

Overview
--------

The ``evolve`` module contains the master time-stepping loop ``evol`` that
advances the Phantom simulation through successive timesteps from the initial
time to the final time specified in the ``.in`` parameter file. It orchestrates
calls to force evaluation (via ``deriv``), timestepping (``step_lf_global`` for
global timesteps, or the individual-timestep scheme when ``ind_timesteps`` is
enabled), output writing (``evwrite``, ``write_fulldump``), and all diagnostic,
checkpoint, and restart checks. Persistent state such as output counter
``noutput``, full-dump counter ``ncount_fulldumps``, next print time
``tprint``, and next checkpoint time ``tcheck`` are stored as private module
variables so that they survive across calls.

The module provides four public entry points. ``evol_init`` initialises the
output schedule and clears the step counters; ``evol_prestep`` performs any
actions required before the force evaluation of a given step (e.g. injecting
new particles, rebalancing MPI domains); ``evol_poststep`` performs
post-step diagnostics, conservation checks, and output; and ``evol`` calls
all three in the standard sequential loop. Exposing these three phases
separately allows external codes such as AMUSE to drive Phantom one step at a
time as a library without relinquishing control of the outer time loop.

The module imports timing utilities from ``timing`` and I/O control from
``io_control`` and ``io_summary``. It also calls ``checkconserved`` to
monitor global conservation of energy, momentum, and angular momentum, and
``energies`` to accumulate kinetic, thermal, gravitational, and magnetic
energies for output.

Physical & Mathematical Description
------------------------------------

The standard integration scheme is the global leapfrog implemented in
``step_lf_global``. In the drift-kick-drift (DKD) leapfrog the positions are
first advanced by half a timestep, forces are evaluated at the resulting
mid-step positions, and then both positions and velocities are updated by the
second half-step. When individual timesteps are enabled, particles are
advanced with their own per-particle :math:`\Delta t_i` using the block
timestep hierarchy.

The global timestep is limited by the Courant-Friedrichs-Lewy condition

.. math::

   \Delta t \le C_\mathrm{CFL}\,\frac{h_\mathrm{min}}{v_\mathrm{sig,max}},

where :math:`h_\mathrm{min}` is the smallest smoothing length over all
particles, :math:`v_\mathrm{sig,max}` is the maximum pairwise signal speed,
and :math:`C_\mathrm{CFL}` is the Courant number (typically 0.3). Additional
constraints are applied for sink-particle dynamics, external forces, and
particle injection rates, and the timestep is taken as the minimum over all
such limits.

Output is triggered when the simulation time reaches the next scheduled dump
time :math:`t_\mathrm{print}` or checkpoint time :math:`t_\mathrm{check}`.
The loop logs CPU and wall time consumed per step via the ``timing`` module
and prints running totals to the standard output so that users can monitor
simulation progress.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/evolve.f90
