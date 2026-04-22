.. phantom-doc: hand-written

setup_windtunnel
================

Overview
--------

``setup_windtunnel`` sets up a Bondi-Hoyle-Lyttleton wind tunnel: a uniform supersonic wind is injected at one end of a cylindrical domain flowing past a fixed central object (star or compact body). Unlike ``setup_BHL`` (which starts with just a sink), the wind tunnel pre-fills the domain with a uniform wind and optionally adds a polytropic star (``add_star``) at the centre built with the ``setstar`` module. Particles are placed on a Cartesian lattice using ``set_unifdis`` to initialise the wind region.

Key runtime parameters include the wind density ``rho_inf`` in g/cm³, the wind speed ``v_inf`` in km/s, the Mach number ``mach``, and the injection radius ``wind_radius`` and length ``wind_length`` in code units. For the accretor-with-atmosphere case, a polytropic star of mass ``Mstar`` and radius ``Rstar`` replaces the point sink. Multiple handled layers of particles are maintained at the injection boundary to ensure smooth wind injection.

This setup is used to study the morphology of the accretion wake, the accretion rate as a function of Mach number and density, and the interaction of the accreted material with an extended stellar atmosphere.

Physical & Mathematical Description
------------------------------------

The Bondi-Hoyle accretion radius is :math:`R_\mathrm{BHL} = 2GM/(v_\infty^2 + c_s^2)` and the accretion rate is :math:`\dot{M}_\mathrm{BHL} = \pi R_\mathrm{BHL}^2 \rho_\infty v_\infty`. For a Mach number :math:`\mathcal{M} = v_\infty/c_s \gg 1` the accretion radius simplifies to :math:`R_\mathrm{BHL} \approx 2GM/v_\infty^2`. The deflection angle of the wind streamline past the accretor is :math:`\theta_\mathrm{def} = \arctan(R_\mathrm{BHL}/b)` for an impact parameter :math:`b`. The accretion efficiency :math:`\eta = \dot{M}_\mathrm{BHL} / (\pi R^2 \rho_\infty v_\infty)` depends on both :math:`\mathcal{M}` and the smoothing of the central potential.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_windtunnel.f90`` for the complete source.
