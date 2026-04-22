.. phantom-doc: hand-written

analysis_collidingcloudhistograms
=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_collidingcloudhistograms`` produces histograms of velocity, mass, and density for converging flow simulations. It bins particles into ``nbins`` equal-width bins (configurable per resolution) and writes 2D histogram data of the velocity-mass-density phase space at each dump.

The routine is intended for studying the statistical properties of gas during cloud-cloud collisions, in particular the evolution of the velocity dispersion and density PDF as the clouds interact and fragment. Multiple resolutions ``nres`` can be used simultaneously for convergence testing.

Output files record the histogram bin centres and counts, enabling comparison of the density and velocity distributions across different dump times and simulation resolutions.

Physical & Mathematical Description
------------------------------------

The histogram bins span the range :math:`[v_\mathrm{min}, v_\mathrm{max}]` in velocity with bin width :math:`\Delta v = (v_\mathrm{max} - v_\mathrm{min}) / N_\mathrm{bins}`, and similarly for density and mass. The mass-weighted velocity dispersion is :math:`\sigma_v^2 = \langle v^2 \rangle_m - \langle v \rangle_m^2`, where angle brackets denote mass-weighted averages.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_collidingcloudhistograms.f90`` for the complete source.
