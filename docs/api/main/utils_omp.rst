.. phantom-doc: hand-written

utils_omp
=========

Overview
--------

The ``omputils`` module provides utility subroutines and shared state for
Phantom's OpenMP parallelisation. It stores ``omp_num_threads`` (the actual
number of OpenMP threads active at runtime), the array of OMP lock variables
``ipart_omp_lock`` for per-sink-particle critical sections, and the
``info_omp`` subroutine that prints the thread count to the log at startup.

The lock array ``ipart_omp_lock(0:nlocks)`` has one entry per sink particle
(up to ``maxptmass``) plus one global entry at index 0. These locks are used
in the force loop when multiple threads compete to update the same sink
particle's force and accretion state. The module is only compiled with
actual OpenMP functionality when ``-fopenmp`` (or equivalent) is active;
otherwise all OpenMP constructs are stripped by the preprocessor.

Physical & Mathematical Description
------------------------------------

This module contains no physics equations. The OMP lock mechanism prevents
race conditions in the sink-particle accretion and force-accumulation
loops. Without locks, multiple threads updating sink forces simultaneously
would produce non-deterministic results due to the non-associativity of
floating-point addition. The lock granularity is per sink particle, which
allows threads operating on different sinks to proceed in parallel.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_omp.f90
