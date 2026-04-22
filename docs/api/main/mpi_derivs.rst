.. phantom-doc: hand-written

mpi_derivs
==========

Overview
--------

The ``mpiderivs`` module orchestrates the MPI communication during both the
density loop and the force (derivatives) loop. It implements a halo-exchange
scheme in which cells of SPH particles near domain boundaries are sent to
neighbouring MPI ranks, the remote ranks compute partial sums, and the
results are returned and accumulated. The module provides a generic interface
``init_cell_exchange`` / ``send_cell`` / ``recv_cells`` / ``combine_cells``
that dispatches to either the density-specific (``mpidens``) or
force-specific (``mpiforce``) implementations.

The module builds on the stack and cell types defined in ``mpidens`` and
``mpiforce``, and uses the communicators ``comm_cellexchange`` and
``comm_cellcount`` from ``mpiutils``. Non-blocking communication
(``MPI_Isend`` / ``MPI_Irecv``) is used throughout to allow overlap of
computation and communication, which is essential for performance at large
MPI task counts.

Physical & Mathematical Description
------------------------------------

The halo-exchange pattern is: (1) identify tree cells whose maximum
smoothing sphere extends across a domain boundary; (2) pack those cells into
send buffers and post non-blocking sends; (3) while sends are in flight,
complete local computations on the interior; (4) receive remote cells and
compute partial sums; (5) send partial sums back; (6) accumulate returned
partial sums into the main arrays. This approach scales as
:math:`O(N_\text{halo})` communication volume, where :math:`N_\text{halo}`
is the number of particles within one kernel radius of a domain boundary.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_derivs.F90
