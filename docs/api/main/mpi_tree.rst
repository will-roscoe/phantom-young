.. phantom-doc: hand-written

mpi_tree
========

Overview
--------

The ``mpitree`` module handles MPI communication during the k-d tree build
and traversal in Phantom's parallel implementation. The tree must be built
globally (all particles from all ranks contributing) so that the domain
decomposition and neighbour searches work correctly. ``mpitree`` provides
``tree_sync`` which broadcasts newly built subtrees from each rank to all
other ranks, and ``tree_bcast`` for broadcasting the root of the assembled
global tree. The ``finish_tree_comms`` routine blocks until all pending
tree-communication requests have completed.

The ``get_group_cofm`` subroutine computes the centre of mass for a group
of tree nodes by gathering partial sums from all ranks. The ``reduce_group``
interface supports both real and integer reductions over subsets of MPI
ranks within a tree level, allowing collective operations on tree levels
during the multi-level tree construction algorithm.

Physical & Mathematical Description
------------------------------------

The Phantom parallel tree build proceeds level by level. At each level each
rank builds its portion of the tree independently, then the level is
synchronised by an all-to-all exchange so that every rank has the full set
of nodes at that level. The communication volume scales as
:math:`O(N_\text{nodes} / N_\text{ranks})` per level, and the number of
levels is :math:`O(\log N)`, so the total tree-build communication is
:math:`O(N \log N / N_\text{ranks})`. The ``globallevel`` variable tracks
the current synchronisation level across all participating ranks.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_tree.F90
