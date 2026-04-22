.. phantom-doc: hand-written

dtype_kdtree
============

Overview
--------

The ``dtypekdtree`` module defines the Fortran derived types used as the
building blocks of Phantom's k-d tree spatial data structure. The primary
type ``kdnode`` represents a single node of the binary tree: it stores the
centre-of-mass coordinates ``xcen(3)``, the bounding-cube half-width
``size``, the maximum smoothing length ``hmax`` of particles in the subtree,
the total ``mass``, and the indices of the left child, right child, and
parent nodes. When compiled with ``-DGRAVITY``, each node also stores the
six independent components of the quadrupole moment tensor ``quads(6)`` for
multipole gravity calculations.

The module also defines a ``ptmassnode`` type for the separate point-mass
(sink particle) tree and a ``ptmasstree`` type that wraps an allocatable
array of ``ptmassnode`` together with a permutation index array. A utility
subroutine ``get_mpitype_of_kdnode`` registers the ``kdnode`` type as an
MPI derived type so that tree nodes can be communicated between MPI ranks
during the parallel tree build in ``mpi_tree``.

Physical & Mathematical Description
------------------------------------

The ``kdnode`` type is the fundamental data structure enabling the Barnes-Hut
tree algorithm used for gravitational force computation in Phantom. The
quadrupole moments stored in ``quads(6)`` represent the symmetric traceless
quadrupole tensor :math:`Q_{ij} = \sum_k m_k (3x_i x_j - r^2 \delta_{ij})`
summed over all particles in the subtree. These are used in the multipole
expansion of the gravitational potential, extending accuracy beyond the
monopole (centre-of-mass) approximation of the Barnes-Hut algorithm.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/dtype_kdtree.F90
