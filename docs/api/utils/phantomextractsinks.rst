.. phantom-doc: hand-written

phantomextractsinks
===================

Overview
--------

``phantomextractsinks`` reads the master sink particle data files generated at runtime by Phantom and writes one ASCII data file per sink particle. When multiple sink data files exist for a single sink (due to simulation restarts), the routine uses only the most recent file for each sink to avoid duplication.

The program scans the current directory for files matching the sink naming convention (using a user-supplied prefix), determines the number of sink particles and the time coverage of each file, and writes the merged per-sink data to ASCII files suitable for plotting or further analysis.

This utility is an alternative to using SPLASH to extract sink data, useful when the sink data files are large or when a simple ASCII table is required for analysis in Python or other scripting environments.

Physical & Mathematical Description
------------------------------------

Each row in the sink data files contains up to 17 columns of sink properties including the sink mass, position, velocity, spin, and accretion radius at each output time. The program selects the most recent file for each sink by comparing the starting times ``tstart(k)`` and keeping the file with the largest ``tstart`` that is less than the global time ``tnow``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantomextractsinks.f90
