.. phantom-doc: hand-written

libphantom-splash
=================

Overview
--------

``libphantom-splash`` (module ``libphantomsplash``) provides an SPH interpolation routine optimised for cross-section rendering in the SPLASH visualisation tool. The key routine ``interpolate3D_fastxsec`` interpolates SPH particle data onto a 2D pixel grid at a fixed :math:`z`-slice, computing the column-integrated projection with normalisation.

The routine loops over all SPH particles within the kernel support of the :math:`z`-slice plane and accumulates their kernel-weighted contributions to the 2D pixel array. A separate normalisation array ``datnorm`` is maintained to allow the unnormalised sum to be divided by the kernel integral for a proper SPH estimate.

This module is compiled as part of the SPLASH library that links to Phantom, enabling real-time or post-processing visualisation of SPH fields directly from Phantom particle data.

Physical & Mathematical Description
------------------------------------

The cross-section interpolation at position :math:`(x_p, y_p, z_0)` is :math:`f(x_p, y_p) = \sum_{b: |z_b - z_0| < \kappa h_b} w_b f_b W(r_{bp}, h_b)`, where :math:`r_{bp}^2 = (x_p - x_b)^2 + (y_p - y_b)^2 + (z_0 - z_b)^2`. The pixel widths are ``pixwidthx`` and ``pixwidthy`` in code length units, and the loop only covers the pixel range :math:`[i_\mathrm{min}, i_\mathrm{max}] \times [j_\mathrm{min}, j_\mathrm{max}]` within the kernel support.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/libphantom-splash.f90
