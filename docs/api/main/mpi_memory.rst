.. phantom-doc: hand-written

mpi_memory
==========

Overview
--------

The ``mpimemory`` module manages the stack memory used for the MPI halo
exchange during the SPH density and force loops. It provides a
``allocate_stack`` / ``push_onto_stack`` / ``get_cell`` interface that
dispatches to either the density-specific (``mpidens``) or force-specific
(``mpiforce``) implementations via generic interfaces. The module also
provides ``swap_stacks_dens`` for rotating between two stacks during the
cell exchange, allowing send and receive operations to proceed in parallel.

The module abstracts the low-level cell stack management so that the main
communication driver in ``mpiderivs`` can work with either density or force
cells through a single interface without knowing the internal layout of
each cell type. Stack sizes are determined by the expected number of
boundary cells per MPI rank and are allocated once at the start of the run.

Physical & Mathematical Description
------------------------------------

This module is a pure data-structure management utility with no physics
content. The stack abstraction is needed because cells are produced and
consumed asynchronously during the SPH neighbour loop: boundary cells are
generated faster than they can be transmitted over the network, so a LIFO
stack buffers them. The two-stack swap design allows one stack to be
transmitted while the other is being filled, hiding communication latency
and improving parallel efficiency.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mpi_memory.f90
