.. phantom-doc: hand-written

setup_cluster
=============

Overview
--------

``setup_cluster`` prepares a star-forming molecular cloud simulation following the approach of Bate, Bonnell & Bromm (2003). A spherical gas cloud of mass ``M_cloud`` (in solar masses) and radius ``R_cloud`` (in parsecs) is placed on an open boundary domain (not periodic), making it suitable for purely hydrodynamic but not MHD calculations. The cloud is populated with SPH particles using ``set_sphere`` and a supersonic turbulent velocity field is imposed from pre-computed velocity cubes read by the ``velfield_fromcubes`` routine.

The equation of state is selectable: isothermal (ieos=1), barotropic (ieos=8), or HII region (ieos=21). Sink particles can be created on the fly when local density exceeds the Jeans density, with sink accretion radius ``Rsink_au`` in astronomical units. An optional relaxation step removes the most extreme particle overlaps before the turbulent velocity field is applied.

This setup is used extensively for studying competitive accretion, the initial mass function, binary star formation, and the role of radiation and feedback in star cluster formation.

Physical & Mathematical Description
------------------------------------

The Jeans mass and radius at the initial mean density :math:`\bar{\rho}` are :math:`M_J = (\pi / G)^{3/2} c_s^3 / \bar{\rho}^{1/2}` and :math:`R_J = c_s / \sqrt{G \bar{\rho}}`. The turbulent velocity field has a power spectrum :math:`P(k) \propto k^{-4}` (Burgers turbulence) or :math:`k^{-11/3}` (Kolmogorov), normalised so that the rms Mach number equals the target value. The free-fall time :math:`t_\mathrm{ff} = \sqrt{3\pi / 32 G \bar{\rho}}` sets the dynamical timescale.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_cluster.f90`` for the complete source.
