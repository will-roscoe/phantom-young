.. phantom-doc: hand-written

interpolate3D_amr
=================

Overview
--------

``interpolate3D_amr`` provides SPH-to-grid interpolation onto an adaptive mesh refinement (AMR) grid built by the ``adaptivemesh`` module. The key routine ``interpolate3D_amr`` loops over all SPH particles and contributes their kernel-smoothed values to the AMR leaf cells within the particle's smoothing radius, using OpenMP parallelisation for thread safety.

Unlike regular-grid interpolation, the AMR approach adapts the cell resolution to the local particle density, providing accurate representation of the density field in both low- and high-density regions. The module uses ``ilock`` (an OpenMP lock array) to prevent race conditions when multiple threads update the same cell.

The module is used primarily by ``analysis_pdfs`` to produce volume-weighted PDFs from the AMR-interpolated density field, and is faster and more accurate than regular grid interpolation for highly inhomogeneous distributions.

Physical & Mathematical Description
------------------------------------

The SPH interpolation to AMR leaf cell :math:`c` is :math:`f_c = \sum_{b: |{\bf r}_b - {\bf x}_c| < \kappa h_b} w_b f_b W(|{\bf x}_c - {\bf r}_b|, h_b)`, where :math:`{\bf x}_c` is the cell centre. Cell sizes vary by level as :math:`\Delta x = L / (n_\mathrm{sub}^l)`, where :math:`L` is the root cell size and :math:`l` is the refinement level. Thread safety for shared cell writes is ensured by OpenMP locks on the cell index array.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/interpolate3D_amr.F90
