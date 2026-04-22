.. phantom-doc: hand-written

utils_timing
============

Overview
--------

The ``timing`` module provides Phantom's wall-clock and CPU timing
infrastructure. It defines the ``timer`` derived type (with label, wall
time, CPU time, load-balance metric, and tree-display metadata) and a
global array of named timers (density loop, force loop, tree build, load
balance, cons2prim, radiation sub-steps, etc.). Public routines include
``getused`` / ``get_timings`` (read current times), ``printused`` /
``print_time`` (format and print timing summaries), ``log_timing``
(accumulate a timer entry), ``wallclock`` (return wall-clock time), and
``setup_timers`` / ``reset_timers`` / ``reduce_timers`` for timer management.

At the end of each run the module prints a hierarchical timing tree showing
the fraction of wall-clock time spent in each major computation phase, along
with the load-balance factor :math:`t_\text{max}/t_\text{mean}` across MPI
ranks. This is essential for diagnosing parallel performance bottlenecks.

Physical & Mathematical Description
------------------------------------

This module is a performance measurement utility with no physics content.
Wall-clock time is measured using Fortran's ``system_clock`` intrinsic
(nanosecond resolution on modern hardware), while CPU time uses
``cpu_time``. The load balance factor is computed as the ratio of the maximum
wall-clock time on any rank to the mean, which equals 1 for perfect
load balance and grows with imbalance. The module is designed to have
negligible overhead (a few nanoseconds per timing call) so it can be called
at the per-cell level without affecting simulation performance.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_timing.f90
