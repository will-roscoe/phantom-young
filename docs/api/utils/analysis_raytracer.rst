.. phantom-doc: hand-written

analysis_raytracer
==================

Overview
--------

``analysis_raytracer`` computes optical depths throughout an AGB stellar wind simulation using adaptive ray-tracing, following the method of Esseldeurs et al. (2023, A&A 674, A122). It supports outward, inward, and adaptive ray-tracing schemes from the ``raytracer_all`` module, computing the optical depth :math:`\tau` from the stellar surface to each SPH particle.

The routine uses a kd-tree (``build_tree``) and neighbour lists to efficiently evaluate the opacity-weighted path length along rays, using the Bowen dust opacity model for dust-gas coupling. Parameters for the gas and dust opacity are read from the particle data and the dust formation module.

Output files record the optical depth of each particle, enabling synthetic observables (spectral energy distributions, molecular line profiles) to be computed in post-processing for comparison with radio and infrared observations of AGB stars.

Physical & Mathematical Description
------------------------------------

The optical depth to particle :math:`i` along the radial ray from the star is :math:`\tau_i = \int_0^{r_i} \kappa(\rho, T) \rho \, ds`, where the Bowen dust opacity is :math:`\kappa = \kappa_\max / (1 + e^{(T - T_\mathrm{cond})/\Delta T})` with :math:`\gamma_\mathrm{gas} = 1.2` and mean molecular weight :math:`\mu = 2.381`. Ray integration uses SPH kernel-weighted contributions from neighbouring particles.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_raytracer.f90`` for the complete source.
