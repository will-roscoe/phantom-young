.. phantom-doc: hand-written

analysis_write_kdtree
=====================

Overview
--------

``analysis_write_kdtree`` builds the Phantom kd-tree from the particle positions and writes it to a binary file for use in external post-processing tools. It provides public routines ``write_kdtree_file`` and ``read_kdtree_file`` enabling other analysis programs or SPLASH to load the precomputed tree.

The routine calls ``build_tree`` from ``neighkdtree`` on all active particles, then serialises the tree structure (cell bounds, cell populations, and leaf particle lists) to file. The output file name is derived from the dump file name. This is particularly useful when many analyses are run on the same dump, avoiding repeated tree builds.

When ``gravity`` is active (compiled with the ``GRAVITY`` flag) the gravitational tree is built in addition to the neighbour-finding tree.

Physical & Mathematical Description
------------------------------------

The kd-tree subdivides the particle domain by alternating spatial cuts along the coordinate of maximum extent, producing a binary tree of depth :math:`\lceil \log_2 N \rceil`. Each leaf cell contains at most a fixed number of particles and stores the cell bounding box :math:`[x_{\min}, x_{\max}] \times [y_{\min}, y_{\max}] \times [z_{\min}, z_{\max}]`. Neighbour searches require only :math:`\mathcal{O}(\log N)` cell-level comparisons before the final particle-level kernel test.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_write_kdtree.f90`` for the complete source.
