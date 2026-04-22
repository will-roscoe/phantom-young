.. phantom-doc: hand-written

test_iorig
==========

Overview
--------

The ``test_iorig`` module (Fortran module ``testiorig``) tests the particle origin
tracking array ``iorig``, which records the original creation index of each particle
across injection events, kills, and shuffles. The test first injects 100 particles via
``add_or_update_particle``, checks that ``npart`` equals 100, and then performs a series
of kills and shuffles, verifying at each step that ``iorig`` remains consistent with the
expected particle-ID bookkeeping.

The kill sequence removes particles at specific indices (positions 12 and 3 in a loop of
ten iterations) and calls ``shuffle_part`` after each round of kills to compact the live
particle list. The test uses a buffered check over all particle pairs to verify that no
two live particles share the same ``iorig`` value and that no dead particle's ``iorig``
appears in the live list. This catches off-by-one errors and swapped-index bugs in the
bookkeeping logic.

Physical & Mathematical Description
------------------------------------

Particle origin tracking is a bookkeeping operation with no physical content. The
correctness criterion is uniqueness: the ``iorig`` array must be a bijection from live
particle indices to the set of original creation integers. The test checks this with a
double loop of :math:`O(N^2)` comparisons for :math:`N = 100` particles, using an integer
tolerance of zero (exact match required).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_iorig.f90
