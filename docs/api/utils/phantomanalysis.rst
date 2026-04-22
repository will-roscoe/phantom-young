.. phantom-doc: hand-written

phantomanalysis
===============

Overview
--------

``phantomanalysis`` is the main driver program for Phantom's post-processing analysis framework. It reads a sequence of Phantom dump files (or all dumps matching a pattern), calls the ``do_analysis`` routine from the linked ``analysis`` module for each dump, and manages I/O and EOS initialisation.

The program reads the Phantom input file (``.in``) to initialise the equation of state, kernel, and external force settings before processing. It handles both full dumps and small dumps (using ``read_smalldump`` for the latter), and automatically detects the dump type via ``is_small_dump``. The analysis type is selected at compile time by choosing which ``analysis_*.f90`` module to link against.

``phantomanalysis`` provides a clean framework for implementing new analysis routines: any routine following the standard interface ``do_analysis(dumpfile, num, xyzh, vxyzu, pmass, npart, time, iunit)`` can be used without modifying the driver.

Physical & Mathematical Description
------------------------------------

Each call to ``do_analysis`` receives the SPH particle arrays ``xyzh(4, npart)`` (positions and smoothing lengths) and ``vxyzu(maxvxyzu, npart)`` (velocities and internal energy) for ``npart`` particles, together with the particle mass ``pmass``, the dump time ``time``, and a file unit ``iunit`` for writing output. The kernel smoothing constant ``hfact`` and EOS parameters are set globally before the loop over dumps.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantomanalysis.f90
