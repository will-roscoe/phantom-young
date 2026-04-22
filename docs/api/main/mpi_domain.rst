.. phantom-doc: hand-written

mpi_domain
==========

Overview
--------

The ``mpidomain`` module manages the MPI domain decomposition for Phantom's
parallel SPH. It stores the ``ibelong`` array (imported from the ``part``
module) which records, for each particle, which MPI rank should own it.
After each tree build, the domain boundaries are implicit in the tree
structure and ``ibelong`` is updated by the tree module; ``mpidomain``
provides the ``init_domains`` and ``assign_to_domain`` routines that
initialise this mapping and update it as the particle distribution evolves.

The module also stores the ``isperiodic`` flag array (one per spatial
dimension) that tells the MPI communication routines whether periodic ghost
particles are needed across a given boundary. This is controlled by the
``-DPERIODIC`` preprocessor flag. The helper functions ``i_belong`` and
``i_belong_i4`` return the owning rank for a given particle in 8-byte and
4-byte integer flavours respectively.

Physical & Mathematical Description
------------------------------------

Domain decomposition in Phantom is tree-based rather than Cartesian-box
based. The k-d tree naturally partitions the particle distribution into
spatially compact subtrees; each MPI rank owns one subtree. This approach
avoids the load-imbalance problems of fixed Cartesian grids for clustered
particle distributions such as star-forming molecular clouds. The
decomposition satisfies :math:`N_i \approx N_\text{total}/N_\text{ranks}`
and is updated every tree build to follow the evolving particle distribution.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_domain.F90
