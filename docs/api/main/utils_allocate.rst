.. phantom-doc: hand-written

utils_allocate
==============

Overview
--------

The ``allocutils`` module provides a unified interface for all dynamic memory
allocation in Phantom. The generic ``allocate_array`` interface wraps
``allocate`` for arrays of real (4-byte and 8-byte), integer (4-byte and
8-byte), and logical type in 1D to 4D, adding bounds checking, a running
total of allocated bytes (``nbytes_allocated``), and informative error
messages on failure. All allocations are logged to the I/O unit at
``iverbose >= 2``.

The ``bytes2human`` utility converts a byte count to a human-readable string
with appropriate SI prefix (kB, MB, GB, TB). This is used by the memory
module to report the total memory footprint of the simulation at startup.
The module also declares the ``kdnode_bytes`` and ``ptmassnode_bytes``
constants imported from ``dtypekdtree`` for use in computing tree memory
requirements.

Physical & Mathematical Description
------------------------------------

This module is a pure I/O and memory management utility. The running total
``nbytes_allocated`` is maintained as a real variable to avoid integer
overflow for simulations approaching 1 GB. Memory allocation failures in
SPH codes are often silent (the OS may over-commit), so the module checks the
Fortran ``stat`` return from each ``allocate`` call and calls ``fatal`` if
it indicates failure.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_allocate.f90
