.. phantom-doc: hand-written

mpi_force
=========

Overview
--------

The ``mpiforce`` module defines the ``cellforce`` derived type and associated
stack infrastructure for exchanging SPH force-loop data between MPI ranks,
analogous to what ``mpidens`` does for the density loop. Each ``cellforce``
struct packs the particle positions, the partial force sums (``fsums``), the
gravitational multipole array (``fgrav``), the cell bounding-box data,
minimum timestep ``tsmin`` per particle, and maximum signal velocity
``vsigmax`` per particle for the ``minpart`` particles in a k-d tree cell.

The ``get_mpitype_of_cellforce`` and ``free_mpitype_of_cellforce`` routines
register and free the corresponding MPI derived type, and the ``stackforce``
type provides a LIFO stack for queuing cells awaiting transmission. The fixed
byte size ``nbytes_cellforce`` ensures that all ranks allocate consistent
buffer sizes regardless of compile-time options.

Physical & Mathematical Description
------------------------------------

During the parallel SPH force loop, boundary cells are exchanged between
ranks in the same halo-exchange pattern as the density loop. Each receiving
rank computes the partial force sums :math:`\mathbf{f}_i \mathrel{+}=
\sum_j m_j \Pi_{ij} \nabla W_{ij}` for the received particles and returns
the accumulated ``fsums`` to the originating rank. The additional fields
``tsmin`` and ``vsigmax`` allow the global minimum timestep criterion to be
computed in the same pass without a separate reduction.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_force.F90
