.. phantom-doc: hand-written

utils_cpuinfo
=============

Overview
--------

The ``cpuinfo`` module extracts and prints information about the hardware on
which Phantom is running. The public routines ``print_cpuinfo`` and
``get_cpuinfo`` read the CPU model name, clock speed, number of physical and
logical cores, and cache size from the system (via ``/proc/cpuinfo`` on
Linux, or equivalent OS-specific interfaces) and format them for the run log
file.

This information is useful for performance analysis and reproducibility: by
recording the hardware in the log file, one can identify whether performance
differences between runs are due to code changes or hardware differences.
The module is called once during startup by the header-writing routines.

Physical & Mathematical Description
------------------------------------

This module performs no physics or numerical calculations. It is a pure
system-query utility. The CPU speed is extracted from the ``cpu MHz`` field
in ``/proc/cpuinfo`` and reported in GHz. The number of physical cores is
inferred from the number of unique ``core id`` entries.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_cpuinfo.f90
