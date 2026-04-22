.. phantom-doc: hand-written

testsuite
=========

Overview
--------

The ``testsuite`` module is the master test runner for the Phantom SPH code. It provides
a single public subroutine ``testsuite`` that is called by the ``phantomtest`` program and
sequentially invokes every individual test module in a defined order, accumulating global
pass and fail counts. The module accepts an optional string argument to select a subset of
tests by name, enabling targeted regression testing during development.

All test modules registered here follow a consistent interface, receiving ``ntests``,
``npass``, and ``nfail`` counters that are incremented in place. After every module
completes, the running totals are printed to the standard output so that a developer can
identify which component first introduced a failure. The suite also initialises I/O
channels, MPI communicators, and memory allocations before any test logic runs.

The full list of modules exercised includes: derivative operators, the leapfrog integrator,
neighbour finding, the k-d tree, the Sedov blast wave, self-gravity, dust-gas drag, dust
growth, the Smoluchowski coagulation kernel, particle arrays, non-ideal MHD, adaptive
particle refinement, the SPH kernel, sink particles, general relativity, Newtonian gravity,
the corotating frame, external forces, individual timesteps, dump I/O, disc and star setup,
hierarchical systems, the equation of state, external MHD, cooling, units, luminosity, MPI
decomposition, radiation, orbits, wind injection, and particle origin tracking.

Physical & Mathematical Description
------------------------------------

The test suite does not itself compute any physical quantities; it orchestrates the
individual tests and collects scalar pass/fail counts from each. Tolerances and comparison
criteria are defined within each subordinate test module using the ``checkval`` and
``update_test_scores`` utilities from ``utils_testsuite``. The suite reports a global
summary of the form ``N tests, M passed, K failed`` at completion.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/testsuite.f90
