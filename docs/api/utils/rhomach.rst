.. phantom-doc: hand-written

rhomach
=======

Overview
--------

``rhomach`` computes density PDF statistics and the RMS Mach number from gridded density and velocity data. The primary routine ``get_rhomach_grid`` accepts a 4D array of density and velocity components on a 3D grid, and returns the linear and logarithmic density variance, the RMS velocity, and the density PDF array.

This module is used by ``grid2pdf`` to compute turbulence diagnostics from density grids produced by grid-based or SPH-to-grid simulations. The companion routine ``write_rhomach`` writes the computed statistics to a file in a standardised format for comparison across simulations.

The density PDF statistics (mean, variance) and Mach number from this module enable direct testing of the :cite:`pricefederrath10` density-Mach number relation and other turbulence theory predictions.

Physical & Mathematical Description
------------------------------------

The log-density contrast is :math:`s = \ln(\rho/\bar{\rho})` where :math:`\bar{\rho} = \langle \rho \rangle_V` is the volume-averaged density. The volume-weighted variance is :math:`\sigma_s^2 = \langle s^2 \rangle_V - \langle s \rangle_V^2`. The RMS Mach number is :math:`\mathcal{M} = v_\mathrm{rms} / c_s`, where :math:`v_\mathrm{rms} = \sqrt{\langle v_x^2 + v_y^2 + v_z^2 \rangle_V}` and :math:`c_s = 1` in isothermal code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/rhomach.f90
