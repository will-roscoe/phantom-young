.. phantom-doc: hand-written

analysis_tde
============

Overview
--------

``analysis_tde`` computes distributions of orbital energy, angular momentum, radial distribution, velocity, and luminosity from an ongoing tidal disruption event simulation. It produces histograms of the debris distribution in these quantities, enabling the mass return rate :math:`dM/dt` and luminosity distribution to be computed as a function of time.

The routine reads configurable parameters (energy range, angular momentum range, bin count, black hole mass) from a ``.params`` file, allowing the analysis to be adapted to different TDE systems. It uses a random number generator to sub-sample particle pairs for efficiency when computing angular momentum correlations.

Output files include time, return time, energy, velocity, and angular momentum distributions, enabling direct comparison with observed TDE light curves through the relation :math:`L(t) \propto dM/dt \propto t^{-5/3}`.

Physical & Mathematical Description
------------------------------------

For a star of mass :math:`M_*` disrupted by a black hole of mass :math:`M_\mathrm{BH}` at the tidal radius :math:`r_t = R_* (M_\mathrm{BH}/M_*)^{1/3}`, the orbital energy of debris spans :math:`\Delta E \sim G M_\mathrm{BH} R_* / r_t^2`. The mass return rate is :math:`dM/dt = (dM/dE)(dE/dt) \propto t^{-5/3}`, with the orbital period :math:`t = 2\pi (G M_\mathrm{BH})^{1/2} (-2E)^{-3/2} / (2\pi)` for bound debris with energy :math:`E < 0`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_tde.f90`` for the complete source.
