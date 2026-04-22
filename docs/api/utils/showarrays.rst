.. phantom-doc: hand-written

showarrays
==========

Overview
--------

``showarrays`` is a lightweight utility that lists all array tags and their sizes stored in a Phantom dump file, without loading the full particle data into memory. It delegates to ``print_arrays_in_file`` from the ``dump_utils`` module, which reads the block headers and prints a formatted table of array names, data types, and sizes.

Usage is ``showarrays file_00000``, accepting one or more dump files on the command line. For each file, the routine prints the array names (tags), the data type (real, real4, real8, int, etc.), and the number of elements, giving a complete catalogue of what data the dump contains.

This tool is useful for inspecting unfamiliar dump files, debugging missing arrays, or checking that new physics arrays (such as magnetic field or radiation) are correctly written.

Physical & Mathematical Description
------------------------------------

The Phantom dump format stores arrays as tagged blocks preceded by a block header containing the tag string (of length ``lentag``), the data type flag (``i_real``, ``i_int``, etc.), and the number of elements. ``print_arrays_in_file`` reads only these headers without loading data, making it fast even for very large dump files with millions of particles.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/showarrays.f90
