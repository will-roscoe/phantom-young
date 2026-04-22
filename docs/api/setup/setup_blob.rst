.. phantom-doc: hand-written

setup_blob
==========

Overview
--------

``setup_blob`` initialises the evaporating-blob hydrodynamics test of Agertz et al. (2007). A cold, dense spherical cloud is embedded in a hot, low-density ambient medium flowing at a supersonic bulk velocity. The density contrast :math:`\chi = \rho_\mathrm{cloud}/\rho_\mathrm{ambient}` is large (typically :math:`\chi = 10`–1000), and both the cloud and ambient are initialised in pressure equilibrium. Particles in the ambient region and inside the sphere are placed on separate uniform Cartesian lattices via ``set_unifdis``.

The test is widely used to benchmark how well an SPH code handles the Kelvin-Helmholtz instability that develops along the cloud boundary as the wind shreds the cloud, and the Rayleigh-Taylor instability that develops at the leading edge. At late times the cloud is ablated and mixed into the hot medium; the timescale for this process is measured against the cloud-crushing time.

Because the test has no analytic solution, comparison with high-resolution adaptive-mesh-refinement simulations provides the reference. This setup has no runtime parameter file — all parameters are hard-coded in the source.

Physical & Mathematical Description
------------------------------------

The cloud-crushing time is :math:`t_\mathrm{cc} = \chi^{1/2} R_\mathrm{cloud} / v_\mathrm{wind}`, where :math:`\chi = \rho_\mathrm{cloud}/\rho_\mathrm{ambient}` is the density contrast, :math:`R_\mathrm{cloud}` is the cloud radius, and :math:`v_\mathrm{wind}` is the bulk wind speed. The Kelvin-Helmholtz growth rate at the cloud surface scales as :math:`\tau_\mathrm{KH}^{-1} \propto k v_\mathrm{wind} / (1 + \chi^{1/2})` for a wavenumber :math:`k`. The cloud is considered disrupted when its mass drops below a fraction of its initial value over a few :math:`t_\mathrm{cc}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_blob.f90`` for the complete source.
