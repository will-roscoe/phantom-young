.. phantom-doc: hand-written

utils_filenames
===============

Overview
--------

The ``fileutils`` module provides a comprehensive set of utility routines for
file name manipulation, file I/O, and string processing in Phantom. Key
capabilities include: ``getnextfilename`` (increment the numeric suffix of a
dump file name), ``numfromfile`` (extract the number from a file name),
``basename`` (strip directory path), ``get_ncolumns`` / ``get_nlines``
(count columns/lines in a text file), ``read_column_labels`` (parse column
headers), ``split`` (tokenise a string), ``strip_extension`` (remove file
extension), ``ucase``/``lcase`` (convert case), and ``make_tags_unique``
(append numeric suffixes to duplicate strings).

The module also provides ``load_data_file`` for reading an ASCII data table
into an array, ``files_are_sequential`` for testing whether a set of dump
files are consecutive, and ``is_digit`` for character classification. These
utilities are used throughout Phantom for reading column-format data files,
constructing output file names, and parsing command-line options.

Physical & Mathematical Description
------------------------------------

This module is a pure string and I/O utility with no physics content. The
``getnextfilename`` function is particularly important for Phantom's output
scheme: dump files are named ``<prefix>_XXXXX`` where ``XXXXX`` is a
zero-padded integer, and ``getnextfilename`` increments this integer to
generate the next output file name without requiring the user to track the
current file number.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_filenames.f90
