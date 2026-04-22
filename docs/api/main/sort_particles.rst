.. phantom-doc: hand-written

sort_particles
==============

Overview
--------

The ``sort_particles`` module reorders the SPH particle arrays so that
particles that are spatially close to each other also have nearby indices in
memory. This improves cache performance in the SPH density and force loops,
where the inner neighbour loop accesses particle data by index. Two public
subroutines are provided: ``sort_part_radius`` sorts particles by distance
from the origin (useful for disc simulations where most neighbour pairs are
at similar radii), and ``sort_part_id`` sorts particles by their original
identifier ``iorig`` (useful for restoring a canonical ordering for
comparison or analysis).

Both routines use the quicksort-based index sorter ``indexxfunc`` or
``indexx`` from ``sortutils`` to construct a reordering permutation
``ll``, then call ``reorder_particles`` (from the ``part`` module) to
apply the permutation simultaneously to all particle arrays — positions,
velocities, internal energies, smoothing lengths, particle types, and
original identifiers. The sort time is reported to the log file.

Physical & Mathematical Description
------------------------------------

Sorting SPH particles by tree-cell index (equivalent to a space-filling
curve ordering such as Morton or Hilbert ordering) reduces cache miss rates
in the SPH kernel evaluations. If particle :math:`i`'s nearest neighbours
have indices within a few hundred of :math:`i`, their data fit into the CPU's
L1 or L2 cache during the inner loop, reducing DRAM accesses. The radius
sort approximates this for spherically symmetric problems by ensuring that
particles within the same radial shell are contiguous in memory.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/sort_particles.f90
