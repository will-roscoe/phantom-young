.. phantom-doc: hand-written

phantomsetup
============

Overview
--------

The ``phantomsetup`` program is the main executable for generating Phantom
initial condition files.  It reads command-line arguments to determine the
problem name, calls the appropriate compile-time-selected ``setup``
subroutine to populate the particle arrays, and then writes the initial
dump file (``.tmp`` or ``.sphng``) and the runtime parameter file
(``.in``) to disk.  If the ``relax`` option is enabled it also runs the
``relax_star`` iteration loop before writing the final dump.

The program provides a unified entry point for all Phantom problem setups:
the specific physics is selected at compile time via the ``SETUP`` make
variable, which determines which ``setup_*.f90`` file is compiled in.
The ``phantomsetup`` driver then handles the common operations — unit
initialisation, MPI setup, dump I/O, and parameter file generation —
so that individual ``setup`` routines can focus purely on the particle
placement physics.

Physical & Mathematical Description
------------------------------------

The ``phantomsetup`` workflow proceeds in four stages.  First, code units
are set by calling ``set_units`` so that all subsequent computations are
in dimensionless code units.  Second, the problem-specific ``setup``
subroutine is called; it fills the position array ``xyzh``, the velocity
array ``vxyzu``, and the sink-particle arrays ``xyzmh_ptmass`` and
``vxyz_ptmass``.  Third, global quantities such as the total particle
number, the smoothing length, and the equation-of-state parameters are
validated and written to the ``header`` structure of the dump file.
Finally, the dump file is written using the Phantom HDF5 (or legacy
Fortran binary) I/O library, producing a file that can be read directly
by the ``phantom`` time-integration executable.

The ``.in`` parameter file is also written (or updated) at this stage,
using the ``infile_utils`` module to produce a human-readable ASCII file
with one parameter per line in ``key = value  ! comment`` format.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/phantomsetup.F90
