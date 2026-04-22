.. phantom-doc: hand-written

analysis_dustywind
==================

Overview
--------

``analysis_dustydisc`` is a post-processing analysis routine for dusty AGB stellar wind simulations, maintained by Lionel Siess. It evaluates the dust properties along a radial ray through the wind by sampling the SPH particle data onto ``N = 1024`` grid points along a direction specified by angles :math:`\theta` and :math:`\phi`.

The routine reads dust temperatures from ``dust_temp`` and luminosity from ``xyzmh_ptmass``, computing dust formation diagnostics and the optical depth profile along the sampling direction. It uses the Bowen dust opacity to evaluate the radiative force on dust grains in the wind acceleration region.

Output files written at each dump record the radial profiles of density, velocity, temperature, and dust fraction along the chosen ray, enabling comparison with 1D stellar wind models.

Physical & Mathematical Description
------------------------------------

The radiation pressure acceleration on dust is :math:`a_\mathrm{rad} = \kappa_\mathrm{dust} L_* / (4\pi r^2 c)`, where :math:`\kappa_\mathrm{dust}` is the Bowen dust opacity, :math:`L_*` is the stellar luminosity read from the sink particle, and :math:`c` is the speed of light. Dust grains form where the temperature drops below the condensation temperature :math:`T_\mathrm{cond} \sim 1500` K.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_dustywind.f90`` for the complete source.
