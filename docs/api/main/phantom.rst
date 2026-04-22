.. phantom-doc: hand-written

phantom
=======

Overview
--------

The ``phantom`` program is the main entry point for the Phantom SPH code. It
is a lean top-level driver that reads the name of the run's ``.in`` file from
the command line and delegates all real work to a small chain of subroutines:
``startrun`` (read options, allocate memory, set up the initial particle
configuration), ``evol`` (the main time-integration loop), and ``endrun``
(write the final dump and close output files).

On startup the program initialises the MPI environment with ``init_mpi``,
assigns Fortran I/O unit numbers, and optionally accepts a ``--maxp=``
command-line option that increases the memory allocation ceiling above the
number of particles already in the run file. This allows room for injected
particles without needing a recompile. A guard clause rejects ``.setup``
files on the command line with an informative message directing the user to
``phantomsetup`` instead.

The code is designed for minimal memory footprint: the target is to run
:math:`10^7`-particle simulations in under 1 GB of RAM. All physics is
therefore stored as compactly as possible, and the main program itself
contains no arrays or physics logic whatsoever.

Physical & Mathematical Description
------------------------------------

As a program driver, ``phantom.f90`` contains no physics or mathematics of
its own. The SPH evolution equations, force evaluations, and time-stepping
are handled by the modules called from within ``evol``. For mathematical
details see the documentation for ``evolve``, ``deriv``, ``step_leapfrog``,
and related modules.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/phantom.f90
