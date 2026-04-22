.. phantom-doc: hand-written

mpi_balance
===========

Overview
--------

The ``mpibalance`` module handles the redistribution of SPH particles across
MPI ranks when the load becomes unbalanced. After each tree build, Phantom
uses a domain decomposition based on the k-d tree to assign equal numbers of
particles (or equal computational work) to each rank. When the assignment
changes, ``balancedomains`` migrates the affected particles by packing them
into send buffers and exchanging them with the target ranks using non-blocking
MPI point-to-point communication.

The module provides ``allocate_balance_arrays`` and
``deallocate_balance_arrays`` to manage the temporary buffers used during
the exchange, and ``balancedomains`` which performs the actual particle
migration. The exchange is based on the ``ibelong`` array (set by
``mpi_domain``) which records the target rank for each particle. A
``comm_balance`` communicator is used for the transfers, distinct from the
default world communicator to allow overlap with other MPI operations.

Physical & Mathematical Description
------------------------------------

Load balancing in Phantom is based on the principle that each MPI rank should
own an equal share of the SPH particles so that the density and force loops
take equal wall-clock time. The domain boundaries are implicit in the k-d
tree structure: rank :math:`p` owns the particles in the subtree below the
:math:`p`-th leaf of the global tree. The balancing criterion minimises the
maximum number of particles on any single rank, which is equivalent to
minimising the parallel inefficiency :math:`\eta = N_\text{max} / (N_\text{total}/N_\text{ranks})`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_balance.F90
