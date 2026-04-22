.. phantom-doc: hand-written

moddump\_tidal
==============

Overview
--------

``moddump_tidal`` places a previously relaxed stellar SPH dump on a Keplerian orbit around a massive black hole (or black-hole binary) to initialise a tidal disruption event simulation. It was written by Megha Sharma. The orbit is fully specified by the penetration factor :math:`\beta`, eccentricity, inclination, and starting distance, all supplied as runtime parameters.

The routine handles both single and binary black-hole configurations. For binary setups (``iorigin`` selects which sink or the binary centre of mass as origin), the secondary black hole is added with its own orbital elements. The stellar spin can also be set relative to the orbital plane via ``theta``.

External forces are configured to use the metric appropriate for the black-hole spin parameter ``a`` (Kerr or Schwarzschild), and the centre of mass is reset before writing. The resulting dump is ready to evolve under the Phantom GR tidal-disruption external-force module.

Physical & Mathematical Description
------------------------------------

For a parabolic orbit (:math:`e = 1`), the stellar centre is placed at distance :math:`r_0` with velocity :math:`v = \sqrt{2 G M_\bullet / r_0}` directed along the infall trajectory. The tidal radius :math:`r_t = r_\star (M_\bullet / m_\star)^{1/3}` and penetration factor :math:`\beta = r_t / r_\mathrm{peri}` together define the pericentre :math:`r_\mathrm{peri} = r_t / \beta`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_tidal.f90`` for the complete source.
