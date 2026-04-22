.. phantom-doc: hand-written

datafiles
=========

Overview
--------

The ``datafiles`` module provides the Phantom-specific interface to the
generic ``datautils`` module for locating and downloading external data
files (opacity tables, molecular cooling tables, EOS tables, etc.) at
runtime. It exposes a single function ``find_phantom_datafile`` that
constructs the expected local path (``data/<loc>/<filename>``), checks
whether the file exists, and if not attempts to download it automatically
from the Phantom data repository via ``datautils``.

On MPI runs only the master rank performs the search and potential download;
a ``barrier_mpi`` call then ensures all ranks wait until the file is
available before proceeding. This avoids multiple simultaneous download
attempts to the same file. The environment variable ``PHANTOM_DIR`` can be
set to point to an alternative data directory, allowing offline use or
shared installations.

Physical & Mathematical Description
------------------------------------

This module is purely an I/O and filesystem utility with no physics content.
The underlying data files it locates (EOS tables, opacity grids, cooling
curves) contain the physics; this module only ensures they can be found at
runtime. See the relevant EOS, cooling, or opacity modules for the
mathematical description of the data they consume.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/datafiles.f90
