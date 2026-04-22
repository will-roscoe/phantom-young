.. phantom-doc: hand-written

memory
======

Overview
--------

The ``memory`` module provides the single entry point ``allocate_memory(ntot)``
for allocating all dynamically-sized arrays used in a Phantom simulation.
Rather than scattering ``allocate`` calls throughout the codebase, every
array allocation is routed through this one routine, which in turn calls
``part.allocate_part`` for particle arrays, ``neighkdtree.allocate_neigh`` for
the neighbour-list workspace, ``ptmass_tree.allocate_ptmasstree`` for sink-particle
tree structures, and the MPI auxiliary allocations in ``mpimemory``,
``mpibalance``, ``mpiderivs``, and ``mpitree``. After allocation completes, the
total memory usage is computed and printed to the log in human-readable form
(bytes, kilobytes, megabytes, or gigabytes as appropriate).

This centralised design has several practical advantages. First, it makes it
straightforward to report the total memory footprint of a run at startup, which
is valuable when optimising problem size to fit within a memory budget. Second,
it ensures that all arrays are sized consistently relative to ``maxp`` (the
compile-time maximum particle count) and ``ntot`` (the run-time requested
count), so that out-of-bounds writes due to mismatched array sizes are caught
in a single location. Third, it simplifies memory management on MPI-parallel
runs because the per-domain particle count and halo buffer sizes are all
computed once inside ``allocate_memory`` before any parallel communication begins.

Physical & Mathematical Description
------------------------------------

Phantom stores particle data in a structure-of-arrays (SoA) layout. Each
physical quantity has its own contiguous array of length ``maxp``, with the
particle index as the slow (outer) index and the vector component as the fast
(inner) index. For example, ``xyzh(4, maxp)`` stores four doubles per particle
with spatial components :math:`(x, y, z, h)` occupying the first dimension.
This layout is optimal for the neighbour loop because sequential particles are
accessed in order of increasing index, giving good spatial locality along the
slow index.

The total memory required scales as

.. math::

   M \sim N_\mathrm{fields} \times N_\mathrm{p} \times \mathrm{sizeof}(\mathtt{real}),

where :math:`N_\mathrm{fields}` is the number of arrays allocated (roughly
20–40 depending on compile-time physics options), :math:`N_\mathrm{p}` is the
particle count, and ``sizeof(real)`` is 8 bytes for double precision. A typical
production run with :math:`10^7` particles and 30 field arrays therefore
requires approximately 2.4 GB of particle storage, plus additional memory for
the k-d tree, MPI buffers, and radiation-field arrays.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/memory.f90
