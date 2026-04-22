.. phantom-doc: hand-written

test_mpi
========

Overview
--------

The ``test_mpi`` module (Fortran module ``testmpi``) tests the MPI memory management
and domain-decomposition communication routines used in parallel Phantom runs. The
module is intentionally lightweight so that it can be compiled and run even in serial
(non-MPI) builds, where the MPI wrappers reduce to no-ops. Units are set to
:math:`10^6 M_\odot`, :math:`G=1`, :math:`c=1` consistent with the GR test environment.

The primary sub-test ``test_increase_mpi_memory`` exercises the dynamic memory stack
used for the MPI force exchange. It deallocates the stack, reallocates it at a small
size (100 entries), pushes a known pattern of cell-force data onto the stack, then calls
``increase_mpi_memory`` to grow the stack beyond its initial capacity, and verifies that
all previously pushed entries are preserved correctly after the reallocation. This catches
off-by-one errors in the stack grow logic and ensures that the memory management is safe
under repeated reallocation.

Physical & Mathematical Description
------------------------------------

The correctness criterion is exact: after reallocation the position vector of cell
:math:`i` on the stack must equal :math:`i \times (1, 2, 3)`, which was the pattern
written before the stack expansion. Integer and floating-point comparisons use a zero
absolute tolerance and a relative tolerance of :math:`10^{-14}` respectively, verifying
that no data corruption occurs during the memory copy.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_mpi.f90
