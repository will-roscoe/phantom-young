.. phantom-doc: hand-written

setup_grdisc
============

Overview
--------

``setup_grdisc`` builds an accretion disc around a Kerr or Schwarzschild black hole in full general relativity. The spacetime metric is specified via Phantom's metric module, and disc parameters — inner and outer radii, surface density and sound speed power-law indices, spin parameter, inclination, and disc mass — are all tunable at runtime. Particle positions are placed using the ``setdisc`` module adapted for Boyer-Lindquist coordinates, with radii measured in units of :math:`GM/c^2`.

The disc inclination relative to the black hole spin axis is set by ``theta`` in degrees, enabling frame-dragging (Lense-Thirring) precession studies. The accretion radius ``accrad`` sets the inner boundary where particles are removed. A reference radius ``r_ref`` provides the normalisation point for the aspect ratio ``honr`` and the sound speed profile. The GR pressure corrections to the rotation curve are included self-consistently.

This setup is the entry point for GR disc simulations in Phantom, including studies of warped disc evolution driven by the Bardeen-Petterson effect, inner boundary conditions near the innermost stable circular orbit, and GR magneto-rotational instability.

Physical & Mathematical Description
------------------------------------

In Boyer-Lindquist coordinates the innermost stable circular orbit (ISCO) radius for a Kerr black hole is :math:`r_\mathrm{ISCO} = r_g [3 + Z_2 \mp \sqrt{(3 - Z_1)(3 + Z_1 + 2Z_2)}]`, where :math:`r_g = GM/c^2`, the signs correspond to prograde/retrograde orbits, and :math:`Z_1, Z_2` are functions of the spin parameter :math:`a/r_g`. The Lense-Thirring precession rate of an inclined orbit at radius :math:`r` is :math:`\Omega_\mathrm{LT} = 2 G J / (c^2 r^3)` where :math:`J = aM c` is the black hole angular momentum.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_grdisc.f90`` for the complete source.
