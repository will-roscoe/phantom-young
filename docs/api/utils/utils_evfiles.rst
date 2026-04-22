.. phantom-doc: hand-written

utils_evfiles
=============

Overview
--------

``utils_evfiles`` (module ``evutils``) provides utility routines for reading, parsing, and writing Phantom ``.ev`` evolution files. It is used by ``phantomevcompare`` and ``ev2mdot``/``ev2kdot`` to handle the common operations of reading column labels, merging file sequences, and writing standardised output.

Key routines include: ``read_evfile`` (reads one ``.ev`` file into memory), ``get_column_labels_from_ev`` (extracts the column header strings), ``write_columns_to_file`` (writes selected columns to a merged output file), ``read_evin_file`` / ``write_evin_file`` (reads/writes the ``.evin`` configuration file for ``phantomevcompare``), and ``find_column`` (searches for a column by label string).

The module supports up to ``max_columns = 150`` columns per file and handles the standard Phantom ``.ev`` column naming convention, making it straightforward to add new analysis quantities to the ``.ev`` file.

Physical & Mathematical Description
------------------------------------

Each ``.ev`` file begins with a header line of the form ``# [01 label] [02 label] ...`` listing the column number and name. The ``get_column_labels_from_ev`` routine parses these labels into character arrays, enabling column matching across files with different physics (and therefore different column orderings). Duplicate time entries (from overlapping ``.ev`` files at restart) are removed by keeping only the first occurrence of each time value.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_evfiles.f90
