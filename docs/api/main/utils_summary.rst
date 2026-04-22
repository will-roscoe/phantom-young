.. phantom-doc: hand-written

utils_summary
=============

Overview
--------

The ``io_summary`` module collects and prints a detailed per-dump summary of
timestep-limiting criteria and diagnostic quantities across all SPH particles.
It tracks the minimum timestep from each physics module (force, drag, viscous,
cooling, Ohmic, Hall, ambipolar, dust, radiation, and cleaning timesteps),
the maximum density, the mass accreted onto each sink particle, and the APR
level distribution. At each full dump these are reported in a compact
multi-line table to the log file.

The module defines integer parameter indices (``iosumdtf``,
``iosumdtfng``, ``iosumdtd``, etc.) for each tracked quantity, up to
``maxrhomx`` density maxima, ``maxisink`` sink accretion histories, and
``maxiapr`` APR level counts. The ``print_apr`` and ``iosum_apr`` arrays
store per-level particle count histories for the APR system. This summary
is particularly valuable for diagnosing which physics process is limiting
the timestep and causing a simulation to run slowly.

Physical & Mathematical Description
------------------------------------

This module is a logging and diagnostic utility. The timestep criteria it
records are each of the form :math:`\Delta t \leq C \cdot \min_i(q_i)`,
where :math:`q_i` is a per-particle physical timescale (e.g.,
:math:`h_i/c_{s,i}` for the Courant criterion, :math:`t_{s,i}` for the
drag stopping time, :math:`h_i^2/\eta_i` for resistive MHD). Recording the
minimum across all particles and all timestep types helps identify
particles or physics processes that are unexpectedly constraining the run.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_summary.F90
