.. phantom-doc: hand-written

phantomevcompare
================

Overview
--------

``phantomevcompare`` is an interactive utility for comparing and merging Phantom ``.ev`` evolution files from multiple simulations. It has two primary modes: a multi-model mode that rewrites ``.ev`` files with a common set of column headers (enabling column-by-column comparison of different runs), and a single-model mode that merges all ``.ev`` files for one run into a single ``00.ev`` file, removing duplicate time entries.

In multi-model mode, the user (or a provided ``.evin`` input file) specifies which columns to include from each model and the output ordering. The routine uses the ``evutils`` module to read column labels, match columns across models, and write the combined file. Up to ``maxfiles = 100`` model files can be compared simultaneously.

This utility is essential for convergence studies and parameter sweeps where multiple ``.ev`` files need to be compared side by side, particularly when different simulation setups produce different column orderings.

Physical & Mathematical Description
------------------------------------

Column matching is performed by comparing the string labels from ``get_column_labels_from_ev`` across all input files, producing a mapping ``headerorder(k)`` of output column index :math:`k` to the corresponding column in each model's ``.ev`` file. When a column is absent from a model's file (because the physics was not active), the corresponding entry is set to zero or ``NaN`` to preserve the common column structure.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantomevcompare.f90
