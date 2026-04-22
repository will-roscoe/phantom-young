.. phantom-doc: hand-written

io
==

Overview
--------

The ``io`` module provides the foundational input/output infrastructure for the Phantom
SPH code. It defines all Fortran logical unit numbers used throughout the codebase,
sets the verbosity level, and exposes the MPI rank (``id``) and process-count
(``nprocs``) variables that are required in both serial and parallel builds.

The module supplies a tiered diagnostic interface — ``comment``, ``warning``, ``error``,
and ``fatal`` — all implemented via the single internal routine ``warn``, which dispatches
on a severity level (1–4). Non-fatal warnings are de-duplicated and buffered in an
internal database of up to ``maxwarningdb = 20`` distinct entries; ``flush_warnings``
prints accumulated occurrence counts at the end of a step or on demand.

Utility routines ``formatreal`` and ``formatint`` produce human-readable string
representations that adapt their format (fixed or scientific notation) to the magnitude
of the value. The generic interface ``real4`` converts ``real(kind=8)`` or integer
values to ``real(kind=4)`` for compact output, and ``cstring`` appends a C null
terminator for interoperability with C or HDF5 library calls.

The ``set_io_unit_numbers`` subroutine assigns fixed Fortran logical unit numbers to
all file handles used by the code (e.g. ``idump = 12`` for binary dump files,
``ievfile = 13`` for energy/diagnostic files, ``iwritein = 22`` for writing the
``.in`` parameter file). In MPI builds ``iprint`` is forced to unit 6 (stdout) since
per-thread log files are not supported.

Physical & Mathematical Description
------------------------------------

No physical computation is performed by this module. The only numerically significant
decision is the severity-based dispatch in ``warn``. The four severity levels are
defined operationally as:

.. math::

   \mathrm{level} \in \{1,\,2,\,3,\,4\}
   \;\Longleftrightarrow\;
   \{\mathrm{comment},\;\mathrm{warning},\;\mathrm{error},\;\mathrm{fatal}\}

Level-4 (fatal) messages invoke ``die``, which calls ``MPI_Abort`` in parallel builds
before exiting with status 1. Warnings at level 2 are buffered; after
``maxcount = 10`` occurrences the message is suppressed and the total count is
reported on the next call to ``flush_warnings``.

The ``formatreal`` subroutine selects among fixed-point and scientific-notation formats
by comparing the magnitude of the input value against successive powers of ten:

.. math::

   \mathrm{format}(v) =
   \begin{cases}
   \texttt{es10.3} & |v| \ge 10^{99} \\
   \texttt{es9.2}  & |v| < 10^{-3}\;\text{or}\;|v| \ge 10^{4} \\
   \texttt{f10.4}  & |v| < 10^{-2} \\
   \texttt{f9.3}   & |v| < 10^{-1} \\
   \texttt{f8.2}   & |v| < 1 \\
   \texttt{f8.1}   & |v| < 10 \\
   \texttt{f8.0}   & \text{otherwise}
   \end{cases}

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/io.F90
