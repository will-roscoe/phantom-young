.. phantom-doc: hand-written

setup_asteroidwind
==================

Overview
--------

``setup_asteroidwind`` initialises a simulation of an evaporating or disintegrating asteroid orbiting a white dwarf, following the scenario studied by Trevascus et al. (2021). A white dwarf is represented either as a sink particle or as an external gravitational potential, and the asteroid is placed on a Keplerian orbit defined by a semi-major axis ``semia``, eccentricity ``eccentricity``, and the orbital period computed from Kepler's third law. Gas particles representing sublimated asteroid material are continuously injected at run time via the injection module.

Key runtime parameters include the white dwarf mass ``m1``, the asteroid mass ``m2``, and the mass injection rate ``mdot``. The injection radius ``rinject`` sets the effective size of the asteroid, and ``npart_at_end`` specifies the total number of injected particles after a prescribed number of orbits to allow convergence studies. Optionally, frame-dragging corrections may be included via the Lense-Thirring precession module.

This setup is used to investigate how debris from tidally disrupted or thermally ablated asteroids builds an eccentric gas disc around a white dwarf — a mechanism widely proposed to explain the photospheric metal pollution observed in a significant fraction of white dwarf spectra.

Physical & Mathematical Description
------------------------------------

The asteroid orbital period follows Kepler's third law, :math:`T_\mathrm{orb} = 2\pi\sqrt{a^3 / GM_\mathrm{WD}}`, where :math:`a` is the semi-major axis and :math:`M_\mathrm{WD}` is the white dwarf mass. Gas is injected from the asteroid surface with a thermal sound speed :math:`c_s = \sqrt{k_B T / (\mu m_p)}`, where the gas temperature ``gastemp`` is specified at setup time. Distances are set in solar radii and masses in solar masses.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_asteroidwind.f90`` for the complete source.
