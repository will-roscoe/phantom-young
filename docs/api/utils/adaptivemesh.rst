.. phantom-doc: hand-written

adaptivemesh
============

Overview
--------

``adaptivemesh`` is a module providing an octree-based adaptive mesh refinement (AMR) grid structure used for interpolating SPH particle data onto a hierarchical grid. The mesh is built dynamically by recursively subdividing cells that contain more than one particle, using a subdivision factor of :math:`n_\mathrm{sub} = 2` in each dimension to give eight children per parent cell.

The module stores cell connectivity in the ``gridnodes`` array, with each node recording its eight children. The root grid is defined at a resolution of :math:`(2^{l_\mathrm{first}})^3` and the tree can extend to a maximum of 20 levels. The ``build_mesh`` routine determines the bounding box of the particle distribution and then refines cells that are too coarsely resolved.

This module is used primarily by ``interpolate3D_amr`` and ``analysis_pdfs`` to produce volume-weighted probability density functions on an adaptive grid, improving accuracy relative to uniform-mesh interpolation for highly clustered data.

Physical & Mathematical Description
------------------------------------

Each leaf node covers a physical volume :math:`\Delta V = (L/2^l)^3`, where :math:`L` is the root-node edge length and :math:`l` is the refinement level. Refinement continues until the local particle density falls below the threshold set by ``overrefinefac``. The hierarchical structure enables :math:`\mathcal{O}(N \log N)` kernel summation by restricting neighbour searches to cells within the SPH smoothing radius :math:`h`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/adaptivemesh.f90
