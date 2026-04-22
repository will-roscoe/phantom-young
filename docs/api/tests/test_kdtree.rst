.. phantom-doc: hand-written

test_kdtree
===========

Overview
--------

The ``test_kdtree`` module (Fortran module ``testkdtree``) contains unit tests specific
to the k-d tree construction routines in Phantom, complementing the more general neighbour
tests in ``test_neigh``. The module sets up a random uniform particle distribution with
:math:`N \approx 10^6` particles, calls ``maketree`` to build the k-d tree, and then
verifies properties of the tree structure via the ``node`` array: that every cell contains
the correct number of particles, that bounding boxes are correctly nested, and that leaf
cells are correctly identified.

A key sub-test exercises the ``revtree`` (reverse-tree) routine, which is used during
MPI domain decomposition to map leaf cells back to a coarser level. The test saves the
tree structure, calls ``revtree``, and checks that the resulting coarser tree covers the
same set of particles. Timing measurements are recorded via ``print_time`` so that
performance regressions in the tree build can be detected from the test log. The test is
compatible with both periodic and non-periodic boundary conditions.

Physical & Mathematical Description
------------------------------------

The tree correctness criteria are: (i) the number of particles in each internal node
equals the sum of its children's particle counts, and (ii) the axis-aligned bounding box
of each node contains all particle positions assigned to it. These geometric invariants
are checked with a zero-tolerance integer comparison for the particle counts and a small
absolute tolerance of :math:`10^{-10}` in code-unit distances for the bounding boxes.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_kdtree.F90
