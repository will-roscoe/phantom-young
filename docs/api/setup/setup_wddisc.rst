.. phantom-doc: hand-written

setup_wddisc
============

Overview
--------

``setup_wddisc`` initialises a simulation of a disc formed from a tidally disrupted asteroid orbiting a white dwarf. An asteroid of mass ``m2`` and radius ``rasteroid`` (in kilometres) is placed on an orbit with periapsis ``rp`` (in solar radii) and semi-major axis ``semia`` around a white dwarf of mass ``m1``. The orbital period and Keplerian speed are computed, and disc particles are generated from the tidally disrupted body.

The white dwarf is modelled as a sink particle with accretion radius ``hacc1``. The number of orbits ``norbits`` and dumps per orbit ``dumpsperorbit`` control the output cadence. This setup complements ``setup_asteroidwind`` by modelling the disc-forming stage rather than the continuous wind-injection stage of white dwarf pollution.

This configuration is used to study the formation and evolution of eccentric debris discs around white dwarfs, the accretion of metals onto the white dwarf surface, and the role of disc viscosity in spreading the debris into a circularised disc.

Physical & Mathematical Description
------------------------------------

The tidal disruption radius for an asteroid of bulk density :math:`\bar{\rho}` is :math:`r_\mathrm{Roche} = R_\mathrm{WD} (2 \rho_\mathrm{WD} / \bar{\rho})^{1/3}`, where :math:`R_\mathrm{WD}` and :math:`\rho_\mathrm{WD}` are the white dwarf radius and density. The orbital period of the asteroid at periapsis :math:`r_p` is :math:`T = 2\pi\sqrt{a^3/GM_\mathrm{WD}}`. The specific orbital energy spread of the tidally disrupted debris is :math:`\Delta E \approx G M_\mathrm{WD} R_\mathrm{ast} / r_p^2`, leading to a fallback timescale :math:`t_\mathrm{fb} \propto (\Delta E)^{-3/2}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_wddisc.f90`` for the complete source.
