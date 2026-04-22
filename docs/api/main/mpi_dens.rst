.. phantom-doc: hand-written

mpi_dens
========

Overview
--------

The ``mpidens`` module defines the ``celldens`` derived type and associated
stack infrastructure used to exchange density-loop data between MPI ranks
during the SPH density calculation. Each ``celldens`` struct packs together
the smoothing lengths, particle positions, and the partial density sums
(``rhosums``) for a group of ``minpart`` particles that form a k-d tree
cell, along with the cell's bounding-box position, search radius, and
maximum smoothing length. This allows a receiving rank to perform the
density summation for particles that are near the domain boundary without
needing the full global particle array.

The module provides ``get_mpitype_of_celldens`` and
``free_mpitype_of_celldens`` to register the ``celldens`` type as an MPI
derived type for transparent communication, and a ``stackdens`` type that
manages a LIFO stack of ``celldens`` objects awaiting transmission. The
data layout is carefully packed to a fixed byte size ``nbytes_celldens``
for efficient MPI transfers.

Physical & Mathematical Description
------------------------------------

In the parallel SPH density sum, particles near a domain boundary need
contributions from particles on neighbouring ranks. The halo-exchange
approach used in Phantom packs those boundary particles into ``celldens``
buffers which are sent to the neighbouring ranks. Each receiving rank then
performs the partial density sums :math:`\rho_i \mathrel{+}= m_j W(|r_i -
r_j|/h_i)` for the received particles and returns the accumulated
``rhosums`` to the originating rank, which completes the density normalisation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_dens.F90
