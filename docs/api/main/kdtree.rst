.. phantom-doc: hand-written

kdtree
======

Overview
--------

The ``kdtree`` module builds and maintains a binary k-d tree over all SPH
particles, enabling :math:`O(N \log N)` neighbour finding and gravity tree
walks. The tree is a recursive binary partition of three-dimensional space: at
each internal node the set of particles is split along the coordinate axis
corresponding to the longest bounding-box dimension at the median particle
position, producing two child nodes. The tree structure is represented by the
arrays ``inoderange(2,ncells)``, which maps each tree cell to the contiguous
range of particle indices it contains, and ``inodeparts(maxp)``, which maps
each particle to its leaf cell. The public routine ``maketree`` rebuilds the
tree from the current particle positions every timestep (or every few steps in
individual-timestep mode, guided by the ``dtmax`` schedule).

The k-d tree implementation follows the approach of Gafton & Rosswog (2011,
MNRAS 418, 770–781), with additional algorithmic elements drawn from Benz,
Bowers, Cameron & Press (1990, ApJ 348, 647–667). It supports both neighbour
finding (via ``neighkdtree``) and the gravity tree walk for sink-particle
interactions (via ``ptmass_tree``). In parallel MPI runs, each domain builds
its own local subtree and communicates halo-particle information to
neighbouring domains before the tree walk begins.

The tree depth is :math:`O(\log_2 N)` for :math:`N` particles, and the
bounding box of each cell is stored explicitly to allow rapid overlap tests
during the walk. The root cell encompasses all particles and its bounding box
is updated automatically whenever the tree is rebuilt.

Physical & Mathematical Description
------------------------------------

A k-d tree partitions :math:`N` points recursively. At each node the longest
axis :math:`k \in \{x, y, z\}` of the bounding box is identified and the
particles are split at the median position along that axis, producing two
child nodes with approximately equal particle counts. The tree depth is
:math:`\lceil \log_2 N \rceil` and the number of cells is at most
:math:`2N - 1`.

For the gravity tree walk (used by ``ptmass_tree`` for sink-particle
self-gravity), a cell at distance :math:`d` from the query point with
bounding-sphere radius :math:`r_\mathrm{cell}` is accepted as a monopole
source if the Barnes-Hut opening criterion is satisfied:

.. math::

   \frac{r_\mathrm{cell}}{d} < \theta,

where :math:`\theta` is ``tree_accuracy``. Cells that do not satisfy this
criterion are opened and their children are tested recursively. The value
:math:`\theta = 0.5` gives a gravitational force error of order
:math:`O(\theta^2)`.

For the neighbour walk the criterion is geometric: a cell is skipped if the
distance from the query particle to the nearest point of the cell's axis-aligned
bounding box exceeds the search radius :math:`2h_i`. This guarantees that every
particle within the search sphere is found, with no approximation. The tree
walk therefore achieves exact neighbour completeness in
:math:`O(N_\mathrm{neigh} \log N)` operations per particle.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/kdtree.F90
