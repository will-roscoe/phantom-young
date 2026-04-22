.. phantom-doc: hand-written

diffdumps
=========

Overview
--------

``diffdumps`` is a code verification utility that compares two Phantom dump files and reports differences in particle positions, velocities, and smoothing lengths. It reads both dumps using ``read_dump``, sorts particles by their unique origin identifier ``iorig`` to match them between dumps, then calls ``checkval`` to evaluate the relative difference in each array element.

The program accepts an optional tolerance argument (default :math:`10^{-12}`) and counts the number of components that differ by more than this threshold. It is primarily used in the Phantom test suite to verify that different code versions or parallelisation strategies produce bit-identical or near-identical results.

Command-line usage is ``diffdumps firstdumpfile seconddumpfile [tolerance]``, with differences reported by quantity (x, y, z, h, vx, vy, vz, u) and the number of differing particles printed for each.

Physical & Mathematical Description
------------------------------------

The relative difference between corresponding array elements is :math:`\epsilon_{ij} = |a_{ij}^{(1)} - a_{ij}^{(2)}| / \max(|a_{ij}^{(1)}|, |a_{ij}^{(2)}|, \epsilon_\mathrm{tiny})`, where :math:`\epsilon_\mathrm{tiny}` prevents division by zero. Particle matching is achieved by sorting both dumps by the ``iorig`` identifier (the original particle number assigned at initialisation) before comparison.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/diffdumps.f90
