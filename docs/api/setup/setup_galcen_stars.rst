.. phantom-doc: hand-written

setup_galcen_stars
==================

Overview
--------

``setup_galcen_stars`` initialises a galactic centre simulation in which a population of massive stars orbits a central supermassive black hole (Sgr A*) and injects stellar wind material into the interstellar medium. The stellar positions, masses, and velocities are read from an external data file (default: ``stars.m.pos.-vel.txt``) in the format used by Paumard et al. (2006). Each star becomes a sink particle with an accretion radius ``h_sink`` in arcseconds at 8 kpc.

Gas particles representing the stellar wind are injected at run time by the wind injection module. The gas mass resolution ``m_gas`` in solar masses controls the particle mass and hence the spatial resolution of the resulting wind nebula. The simulation uses parsec-scale units appropriate for the central parsec of the Milky Way.

This setup is used to model the complex interaction of the Sgr A* accretion flow with winds from the surrounding S-star and Wolf-Rayet stellar populations, a key driver of the observed X-ray emission from the galactic centre.

Physical & Mathematical Description
------------------------------------

Each stellar wind is injected at the stellar surface with a terminal velocity :math:`v_w` and a mass-loss rate :math:`\dot{M}_w`. The wind ram pressure :math:`P_w = \dot{M}_w v_w / (4\pi r^2)` competes with the gravity of Sgr A*, whose mass :math:`M_\bullet \approx 4 \times 10^6 M_\odot` sets the sphere of influence :math:`r_h = G M_\bullet / \sigma^2 \approx 3` pc. The gas temperature in the hot diffuse medium is set by the balance of stellar wind kinetic energy input and radiative cooling.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_galcen_stars.f90`` for the complete source.
