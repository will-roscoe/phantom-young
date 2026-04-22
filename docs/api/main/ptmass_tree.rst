.. phantom-doc: hand-written

ptmass_tree — KD-Tree for Sink Particle Neighbour Search
=========================================================

Overview
--------

The ``ptmass_tree`` module builds and queries a binary kd-tree over the set of sink
(point-mass) particles.  It is used to accelerate the accretion search in the
``substepping`` module: rather than looping over all :math:`N_{\rm sink}` sinks for
every candidate gas particle, a top-down tree traversal prunes branches whose
bounding spheres cannot overlap the search radius, reducing the cost from
:math:`\mathcal{O}(N_{\rm sink})` to :math:`\mathcal{O}(\log N_{\rm sink})` per
gas particle when the number of sinks is large.  The fast-accretion path is
activated when ``nptmass > nfastacc`` (currently 100).

The tree is stored in the module-level variable ``ptmasskdtree`` of type
``ptmasstree`` (defined in ``dtype_kdtree``).  Each node stores the index range of
its particles, a bounding-sphere centre ``xcen`` computed as the mass-weighted
centre of mass of the sinks in the node, a maximum-distance radius ``size``, and
left/right child indices.  Node splitting uses the longest bounding-box dimension
as the partition axis, with a pivot equal to the node centre of mass along that
axis.  A quicksort operating on the index array ``iptmassnode`` partitions sinks
about the pivot without allocating additional storage.  Tree construction is
parallelised with OpenMP tasks; atomic operations protect the shared node counter.

The neighbour search ``get_ptmass_neigh`` performs a depth-first traversal using an
explicit stack of size ``istacksize = 512``.  A node is entered only if the
squared distance from the query point to its bounding-sphere centre satisfies
:math:`d^2 < (r_{\rm search} + {\rm size})^2`; leaf nodes within the search
radius contribute their particle indices to the output list.

Physical & Mathematical Description
-------------------------------------

**Bounding sphere.**  For a node containing sink indices :math:`\{k_1, \dots, k_n\}`,
the centre of mass is

.. math::

   \mathbf{x}_{\rm cen} = \frac{\sum_k M_k\,\mathbf{x}_k}{\sum_k M_k}

and the bounding radius is

.. math::

   s = \max_k |\mathbf{x}_k - \mathbf{x}_{\rm cen}|

**Overlap test.**  The query point :math:`\mathbf{x}_q` and search radius
:math:`r_s` overlap with a node's bounding sphere if

.. math::

   |\mathbf{x}_q - \mathbf{x}_{\rm cen}|^2 < (r_s + s)^2

Nodes that fail this test are pruned entirely from the traversal.

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Symbol
     - Definition
   * - :math:`M_k`
     - Mass of sink :math:`k`, ``xyzmh_ptmass(4, k)``
   * - :math:`\mathbf{x}_k`
     - Position of sink :math:`k`, ``xyzmh_ptmass(1:3, k)``
   * - :math:`\mathbf{x}_{\rm cen}`
     - Mass-weighted centre of a tree node (``nodes%xcen``)
   * - :math:`s`
     - Bounding-sphere radius of a tree node (``nodes%size``)
   * - :math:`r_s`
     - Search radius passed to ``get_ptmass_neigh``
   * - ``nfastacc``
     - Threshold number of sinks above which tree search is used (= 100)
   * - ``nmaxleaf``
     - Maximum particles per leaf node (= 2)

References
----------

No entries from ``phantom.bib`` are directly cited by this module.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/ptmass_tree.f90
