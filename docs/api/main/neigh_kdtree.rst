.. phantom-doc: hand-written

neigh_kdtree
============

Overview
--------

The ``neighkdtree`` module performs the actual neighbour-search walk over the
k-d tree constructed by ``kdtree``. For each active particle :math:`i` the
public routine ``getneigh_pos`` descends the tree, testing each cell against
the particle's search sphere of radius :math:`2h_i`, and appends all particles
:math:`j` that fall within the sphere to the thread-private neighbour list
``listneigh``. Making ``listneigh`` thread-private (via OpenMP) eliminates all
write conflicts in the particle loop and allows the neighbour search to
parallelise with no synchronisation overhead.

The module exposes a boolean flag ``use_dualtree`` which, when enabled (as in
MHD runs), activates a dual-tree traversal strategy: rather than walking the
tree independently for each particle, pairs of cells are tested simultaneously,
reducing the number of bounding-box overlap tests by roughly a factor of two.
The array ``leaf_is_active`` marks which leaf cells contain at least one active
particle, allowing the outer loop over cells to skip inactive leaves entirely,
which is important in individual-timestep runs where only a fraction of
particles are updated each step.

The runtime parameter ``tree_accuracy`` controls the Barnes-Hut opening
criterion used by ``ptmass_tree`` for the gravity tree walk; it does not affect
the neighbour search, which is always exact. The module is designed to be
called from within the density and force loops in ``densityforce`` and
``forces``, and is the inner loop of Phantom's :math:`O(N \log N)` neighbour
algorithm.

Physical & Mathematical Description
------------------------------------

The neighbour search for particle :math:`i` collects all particles :math:`j`
satisfying :math:`|\mathbf{r}_i - \mathbf{r}_j| < 2h_i`. The k-d tree walk
achieves this efficiently by pruning cells that cannot contain any such
particle. A cell is pruned when the distance from :math:`\mathbf{r}_i` to the
nearest point of the cell's axis-aligned bounding box exceeds :math:`2h_i`:

.. math::

   \left|\mathbf{r}_i - \mathbf{r}_\mathrm{cell}^\mathrm{near}\right| > 2h_i
   \implies \text{skip cell},

where :math:`\mathbf{r}_\mathrm{cell}^\mathrm{near}` is the closest point of
the cell bounding box to :math:`\mathbf{r}_i`. For cells that pass this test
and are leaf nodes, all particles in the leaf are tested individually. For
internal nodes the two children are pushed onto a stack and tested in turn.
This gives an average cost of :math:`O(N_\mathrm{neigh} \log N)` per particle,
compared with :math:`O(N)` for a brute-force search.

The thread-private neighbour list ``listneigh`` is filled during the walk and
consumed immediately by the calling density or force loop. No global neighbour
list is stored, keeping the memory footprint per thread at
:math:`O(N_\mathrm{neigh,max})` rather than :math:`O(N)`. The maximum
neighbour count ``maxneigh`` is set at compile time and an error is raised if
it is exceeded, prompting the user to increase the value.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/neigh_kdtree.f90
