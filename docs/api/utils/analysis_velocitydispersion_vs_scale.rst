.. phantom-doc: hand-written

analysis_velocitydispersion_vs_scale
====================================

Overview
--------

``analysis_velocitydispersion_vs_scale`` computes the velocity dispersion of SPH particles as a function of spatial scale, providing the turbulent velocity power spectrum in physical space. It generates a series of spherical regions of increasing radius ``rscale`` and computes the velocity dispersion of particles within each sphere.

For each scale the routine uses neighbour lists to efficiently identify particles within the specified radius, computing the mass-weighted mean velocity and its squared deviation (the velocity dispersion :math:`\sigma_v^2`). The kinetic, gravitational, thermal, and magnetic energies within the sphere are also computed, enabling the virial state at each scale to be assessed.

Output files record :math:`\sigma_v(\ell)`, the energies, and the number of particles as a function of scale :math:`\ell`, directly comparable to the observed Larson's law :math:`\sigma_v \propto \ell^{0.38}` for molecular clouds.

Physical & Mathematical Description
------------------------------------

The mass-weighted velocity dispersion within a sphere of radius :math:`\ell` centred on a reference particle is :math:`\sigma_v^2(\ell) = \langle v^2 \rangle_m - |\langle \mathbf{v} \rangle_m|^2`, where :math:`\langle \cdot \rangle_m` denotes a mass-weighted average over all particles within radius :math:`\ell`. The virial parameter is :math:`\alpha_\mathrm{vir} = 5 \sigma_v^2 \ell / (G M_\ell)`, with :math:`\alpha_\mathrm{vir} < 2` indicating gravitational boundedness.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_velocitydispersion_vs_scale.f90`` for the complete source.
