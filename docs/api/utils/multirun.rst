.. phantom-doc: hand-written

multirun
========

Overview
--------

``multirun`` generates a series of Phantom input files by systematically varying the artificial viscosity parameter :math:`\alpha` across a user-specified range, enabling parameter sweeps for disc viscosity studies. The program reads an existing ``.in`` file, modifies the ``alpha`` parameter for each run, writes a new ``.in`` file, and also generates a log file name for each run.

For each value of :math:`\alpha` the program writes a modified input file with the new viscosity setting and computes the corresponding Shakura-Sunyaev parameter :math:`\alpha_\mathrm{SS}` for reference. The number of runs ``nruns`` and the range ``[alphamin, dalpha]`` are set interactively.

This utility streamlines the setup of convergence studies and parameter surveys without requiring manual editing of input files for each run.

Physical & Mathematical Description
------------------------------------

The artificial viscosity parameter :math:`\alpha` in Phantom controls the strength of the Riemann dissipation term :math:`\Pi_{ij} \propto \alpha c_{ij} |v_{ij}|`, which mimics physical kinematic viscosity :math:`\nu = \alpha_\mathrm{SS} c_s H / 2` in the disc. For a Keplerian disc :math:`\alpha_\mathrm{SS} \approx \alpha (H/R)^2 / (10 \cdot (2h/H)^2)` at the disc midplane, providing the mapping between the SPH viscosity parameter and the disc alpha.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/multirun.f90
