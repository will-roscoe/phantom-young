.. phantom-doc: hand-written

quitdump
========

Overview
--------

The ``quitdump`` module handles graceful termination of a Phantom run. When
Phantom receives an abnormal termination signal (SIGTERM, a fatal error, or a
similar stop condition), the single public subroutine ``quit`` is called. It
prints a final summary to the log file via ``summary_printout``, writes a
complete binary dump of the current simulation state to a file named
``phantom.debugdump``, and then closes all open Fortran I/O units (the
``.ev`` file, the log file, the sink-column files, and the kill-signal file)
before calling ``die`` to terminate the MPI job cleanly.

The ``quit`` subroutine is protected by an OpenMP critical region
``crit_quit_summary`` so that only one thread can execute it at a time even
if a fatal error is triggered from within a parallel region. This ensures
that the debug dump is written exactly once and without partial writes from
multiple threads.

Physical & Mathematical Description
------------------------------------

This module performs no physics calculations. Its purpose is safe termination:
ensuring that the current particle state is saved to disk so that a crashed
simulation can potentially be restarted or diagnosed. The ``write_fulldump``
call writes all evolved variables (positions, velocities, internal energies,
smoothing lengths, etc.) in the standard Phantom binary format, making the
debug dump readable by splash and phantomanalysis.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/quitdump.f90
