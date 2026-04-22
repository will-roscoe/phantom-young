.. phantom-doc: hand-written

moddump_extenddisc
==================

Overview
--------

``moddump_extenddisc`` radially extends an existing accretion disc by adding new particles in the outer region beyond the current disc edge, matching the surface density, tilt, and twist profiles of the existing disc. Written by Rebecca Nealon, it uses ``setdisc`` and ``partinject`` to add particles in a way that is consistent with the existing disc structure.

The routine reads the disc parameters (inner and outer radii, surface density profile, etc.) from the existing disc, extrapolates these profiles outward to the new outer radius, and adds particles according to the extrapolated profiles. The tilt and twist of the new particles are set to match the locally measured values from the existing disc.

This moddump is useful for extending a disc simulation that was originally set up with a smaller outer radius, avoiding the need to restart from scratch with new initial conditions.

Physical & Mathematical Description
------------------------------------

The surface density is assumed to follow a power law :math:`\Sigma(R) \propto R^{-p}` in the added region, extrapolated from the existing disc edge. New particles are added at positions :math:`(R, z) = (R, h \xi)` where :math:`h = H(R)` is the disc scale height at radius :math:`R` and :math:`\xi` is a random number drawn from a Gaussian distribution, with velocities set for Keplerian circular orbits corrected for pressure support.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_extenddisc.f90`` for the complete source.
