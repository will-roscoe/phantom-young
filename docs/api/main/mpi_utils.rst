.. phantom-doc: hand-written

mpi_utils
=========

Overview
--------

The ``mpiutils`` module provides the core MPI infrastructure for Phantom's
parallel implementation. It exposes a set of generic Fortran interfaces that
wrap MPI collective operations — ``reduce_mpi``, ``reduceall_mpi``,
``bcast_mpi``, and ``barrier_mpi`` — in a way that makes the calling code
cleaner and handles both the MPI and non-MPI (single-rank) cases
transparently. Without MPI all reduction calls return the input value
unchanged, so no conditional ``#ifdef MPI`` guards are needed at call sites.

The ``reduce_mpi`` and ``reduceall_mpi`` interfaces accept scalar or array
arguments of integer (4-byte and 8-byte), real (4-byte and 8-byte), and
logical types, with reduction operators ``'+'``, ``'max'``, and ``'min'``
specified as character strings. ``bcast_mpi`` broadcasts a scalar or array
from the master rank to all other ranks. The module also defines MPI
communicator handles (``comm_balance``, ``comm_cellexchange``,
``comm_cellcount``) and a custom ``MPI_DEFAULT_REAL`` type matching
Phantom's default floating-point precision.

Physical & Mathematical Description
------------------------------------

This module is purely an MPI infrastructure layer with no physics content.
It ensures that global reductions such as :math:`\sum_i m_i` or
:math:`\max_i \rho_i` across all MPI ranks are computed correctly regardless
of whether the code is compiled with MPI. The generic interface design
prevents type errors in MPI calls at compile time while keeping the physics
code free of MPI-specific syntax.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_utils.F90
