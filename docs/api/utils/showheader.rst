.. phantom-doc: hand-written

showheader
==========

Overview
--------

``showheader`` displays the full header of a Phantom dump file, including all metadata fields such as the number of particles, simulation time, unit conversions, equation of state parameters, and the build tag. It uses ``open_dumpfile_r``, ``read_header``, and ``print_header`` from the ``dump_utils`` module.

Usage is ``showheader file_00000``, accepting one or more dump files. For each file, the routine opens it in read mode, reads the header into a ``dump_h`` structure, prints a formatted table of all header fields using ``print_header``, and then frees the header memory.

This tool provides a quick overview of a dump's physical parameters without requiring SPLASH or a full post-processing pipeline, making it useful for checking that simulations are using the intended units and EOS settings.

Physical & Mathematical Description
------------------------------------

The Phantom dump header contains scalar fields including: ``npart`` (particle count), ``time`` (code time), ``hfact`` (kernel normalisation), ``utime``, ``udist``, ``umass`` (unit conversions to CGS), ``gamma`` (adiabatic index), ``polyk`` (polytropic constant), ``nptmass`` (sink count), and various physics flags. The file identifier string ``fileid`` records the Phantom version and build configuration.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/showheader.f90
