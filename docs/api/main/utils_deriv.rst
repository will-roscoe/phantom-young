.. phantom-doc: hand-written

utils_deriv
===========

Overview
--------

The ``derivutils`` module provides a single interface routine ``do_timing``
that wraps Phantom's timing infrastructure for the derivative computation
pipeline. It is called at the start and end of the density loop, force loop,
tree build, and load-balance step to accumulate wall-clock and CPU time into
the named timers defined in the ``timing`` module (``itimer_dens``,
``itimer_force``, ``itimer_tree``, ``itimer_balance``,
``itimer_cons2prim``, and the radiation sub-timers).

On MPI runs, ``do_timing`` calls ``reduce_mpi`` to gather the maximum and
minimum times across all ranks, enabling load-balance diagnostics. The
separation of this timing infrastructure into its own module avoids a
circular dependency between the ``deriv`` module (which calls timing) and
the ``timing`` module.

Physical & Mathematical Description
------------------------------------

This is a pure infrastructure utility module with no physics content. It
measures real elapsed time via Fortran's ``cpu_time`` and ``system_clock``
intrinsics and accumulates totals across the simulation for the timing report
printed at the end of each run. The information is used to identify
performance bottlenecks and MPI load imbalance.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_deriv.f90
