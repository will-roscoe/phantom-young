.. phantom-doc: hand-written

analysis_getneighbours
======================

Overview
--------

``analysis_getneighbours`` is a post-processing routine that computes and writes the complete SPH neighbour list for all particles in a dump to a binary file. It delegates to ``generate_neighbour_lists`` from the ``getneighbours`` module, which uses the kd-tree to find all particles within the smoothing kernel support radius.

The resulting neighbour file can be reused by other analysis routines (such as ``analysis_disc_stresses`` and ``analysis_clumpfind``) to avoid recomputing neighbour lists at every dump. This is particularly valuable for large simulations where the neighbour search is expensive.

The output file is named using the dump filename and can be read back by any analysis routine that calls ``read_neighbours`` from the ``getneighbours`` module.

Physical & Mathematical Description
------------------------------------

For each particle :math:`i` with smoothing length :math:`h_i`, all particles :math:`j` satisfying :math:`|\mathbf{r}_i - \mathbf{r}_j| < \kappa h_i` (where :math:`\kappa = 2` for the M4 cubic spline kernel support radius) are stored as neighbours. The neighbour list contains up to ``neighmax = 2000`` entries per particle and is generated via the shared kd-tree cell structure.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_getneighbours.f90`` for the complete source.
