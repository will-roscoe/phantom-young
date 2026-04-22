.. phantom-doc: hand-written

initial
=======

Overview
--------

The ``initial`` module orchestrates the complete startup and orderly shutdown
of a Phantom simulation. It exports four public routines: ``initialise``,
``startrun``, ``endrun``, and ``finalise``. The ``initialise`` routine must be
called before any other Phantom routine; it sets up I/O unit numbers, queries
the number of available OpenMP threads, initialises MPI communicators, installs
default option values, and configures boundary conditions. Calling any
derivative or force routine before ``initialise`` has returned is undefined
behaviour.

The ``startrun`` routine performs the problem-specific startup. It reads the
``.in`` parameter file via ``readwrite_infile``, overwriting the defaults set
by ``initialise`` with the values specified by the user. It then reads the
initial particle dump via ``readwrite_dumps``, which populates the ``part``
arrays with positions, velocities, smoothing lengths, and all other stored
fields. After particle memory has been allocated by ``memory.allocate_memory``,
``startrun`` calls the derivative evaluation routine to compute self-consistent
densities and forces at :math:`t = 0`, and writes the run header to the log.
``endrun`` flushes all open output files and finalises MPI on exit.

The separation between ``initialise`` (environment setup) and ``startrun``
(problem setup) allows Phantom to be embedded as a library in external
frameworks such as AMUSE: the calling environment calls ``initialise`` once at
library load time, then calls ``startrun`` for each new simulation without
reinitialising the MPI layer. Similarly, ``endrun`` and ``finalise`` are
separated so that MPI can remain alive while multiple sequential runs are
performed within a single MPI job.

Physical & Mathematical Description
------------------------------------

The startup sequence defines the state of the simulation at :math:`t = 0`. The
key steps are: (1) set default options from compile-time and module-level
defaults; (2) read the ``.in`` file to override defaults with user-specified
values; (3) read the dump file, loading particle positions
:math:`\mathbf{r}_i`, velocities :math:`\mathbf{v}_i`, smoothing lengths
:math:`h_i`, and internal energies :math:`u_i`; (4) compute the initial
derivative, which iterates :math:`h_i` to self-consistency and evaluates all
forces; and (5) write the header and hand control to the evolution loop.

Step (4) — the initial derivative evaluation — is essential because the dump
file may not encode a consistent set of :math:`(\rho_i, h_i, \mathbf{a}_i)`:
the stored :math:`h_i` values are only approximate until the Newton-Raphson
density iteration has converged on the :math:`t = 0` particle distribution.
Computing the derivative before the first leapfrog half-step ensures that the
accelerations :math:`\mathrm{d}\mathbf{v}_i/\mathrm{d}t` are consistent with
the current positions and smoothing lengths, so that no spurious impulse is
introduced at the start of the integration.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/initial.F90
