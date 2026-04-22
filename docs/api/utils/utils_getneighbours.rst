.. phantom-doc: hand-written

utils_getneighbours
===================

Overview
--------

``utils_getneighbours`` (module ``getneighbours``) provides routines for generating, storing, and reading/writing complete neighbour lists for all SPH particles. The ``generate_neighbour_lists`` routine uses the Phantom kd-tree (via ``neighkdtree``) to find all particles within the kernel support of each particle, storing up to ``neighmax = 2000`` neighbours per particle.

The module maintains the global arrays ``neighcount`` (number of neighbours per particle), ``neighb`` (neighbour indices), and summary statistics ``meanneigh``, ``sdneigh``, and ``neighcrit``. Neighbour lists are written to binary files by ``write_neighbours`` and read back by ``read_neighbours``, enabling reuse across multiple analysis calls without repeating the expensive search.

This module is used by ``analysis_disc_stresses``, ``analysis_clumpfind``, ``analysis_velocityshear``, and ``analysis_velocitydispersion_vs_scale``, all of which require per-particle neighbour information for SPH gradient computations.

Physical & Mathematical Description
------------------------------------

The neighbour search identifies all particles :math:`j` satisfying :math:`|{\bf r}_j - {\bf r}_i| < \kappa h_i` where :math:`\kappa = 2` for the M4 kernel. The search uses the kd-tree cell structure to reduce the cost from :math:`\mathcal{O}(N^2)` to :math:`\mathcal{O}(N \log N)`, with a cell cache of size ``maxcellcache = 50000`` for efficiency. The mean neighbour count ``meanneigh`` is a diagnostic of the local resolution.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_getneighbours.F90
