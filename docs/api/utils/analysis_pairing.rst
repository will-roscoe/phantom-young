.. phantom-doc: hand-written

analysis_pairing
================

Overview
--------

``analysis_pairing`` checks for particle pairing — the pathological state in which two particles have a very close separation (much less than their smoothing length) — which can cause problems in post-processing visualisation and analysis with SPLASH or other tools. It uses the kd-tree via ``build_tree`` to efficiently find all particle pairs within a small fraction of the smoothing length.

The routine builds a histogram of nearest-neighbour separations in units of :math:`h`, counting particles with separations in the ranges ``sep_hist = [0.0001, 0.001, 0.01, 0.1, 0.3, 1.0, 2.0]``. Particles with extremely close neighbours (separation :math:`< 0.01 h`) trigger a warning. The total number of neighbour pairs is also reported.

This diagnostic is primarily useful for quality control of particle distributions and for debugging setup routines that may inadvertently place particles too close together.

Physical & Mathematical Description
------------------------------------

Two particles :math:`i` and :math:`j` are considered paired if their separation :math:`r_{ij} = |\mathbf{r}_i - \mathbf{r}_j|` satisfies :math:`r_{ij} / h_i < \epsilon` where :math:`\epsilon \ll 1`. For the M4 cubic spline kernel, particles closer than :math:`0.01 h` can cause numerical inaccuracies in the kernel gradient and force evaluation. The routine counts paired particles in logarithmically spaced separation bins.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_pairing.f90`` for the complete source.
