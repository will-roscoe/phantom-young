.. phantom-doc: hand-written

analysis_dtheader
=================

Overview
--------

``analysis_dtheader`` is a minimal post-processing routine that prints the time interval :math:`\Delta t` between successive dumps. On each call it records the current dump time and prints the difference from the previous value, giving a quick check of the dump cadence without reading any particle data.

This utility is useful for verifying that dumps are being written at the expected interval, or for identifying anomalous time steps in a simulation log. It requires no configuration and has no dependencies other than the dump time variable itself.

Output is to standard output (the terminal) rather than a file, making it suitable for quick interactive inspection of a dump sequence.

Physical & Mathematical Description
------------------------------------

The time interval between dump :math:`n` and dump :math:`n-1` is simply :math:`\Delta t_n = t_n - t_{n-1}`, where :math:`t_n` is the simulation time stored in the dump header. For a uniform dump cadence set by ``dtmax``, all :math:`\Delta t_n` should be equal.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_dtheader.f90`` for the complete source.
