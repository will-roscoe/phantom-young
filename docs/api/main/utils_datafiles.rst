.. phantom-doc: hand-written

utils_datafiles
===============

Overview
--------

The ``datautils`` module provides the generic infrastructure for locating
and downloading external data files at runtime. It is the underlying
implementation used by the Phantom-specific wrapper in ``datafiles``. The
public function ``find_datafile`` searches for a named file in a sequence
of standard locations: the current working directory, a directory specified
by an environment variable, and the ``data/`` subdirectory of the code
tree. If the file is not found locally and a URL is provided, it attempts
to download it using a system ``wget`` or ``curl`` call.

The ``download_datafile`` subroutine performs the actual download by
constructing a shell command and calling the Fortran intrinsic
``execute_command_line``. This mechanism allows Phantom runs to
self-configure by fetching opacity tables, EOS data, and molecular line
data from the Phantom data server without manual user intervention,
provided internet access is available.

Physical & Mathematical Description
------------------------------------

This module performs no physics calculations. It is a filesystem and
network I/O utility. The data files it locates contain the physics (tabulated
opacities, EOS tables, molecular cooling curves); this module only ensures
they are present at the expected path before the code attempts to read them.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_datafiles.f90
