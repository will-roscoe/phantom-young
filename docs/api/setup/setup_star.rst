.. phantom-doc: hand-written

setup_star
==========

Overview
--------

``setup_star`` is the primary single-star setup in Phantom. It calls the ``setstar`` module to build a spherically symmetric stellar model from a range of options: polytropes with specified :math:`n` and :math:`K`, or tabulated density/pressure/composition profiles from MESA or KEPLER stellar evolution models. A post-placement relaxation step can be applied to damp initial transients and bring the SPH particle arrangement into true hydrostatic equilibrium before the main simulation begins.

The setup supports general-relativistic configurations (compile flag ``gr``), enabling neutron star and white dwarf models in the Tolman-Oppenheimer-Volkoff equilibrium. Optional rotation and the adaptive particle refinement (APR) module are available. The external potential ``iext_densprofile`` can be used to stabilise the star against secular mass loss from SPH boundary effects.

This is the standard entry point for stellar merger, common envelope, supernova, and tidal disruption event simulations where a realistic stellar model is needed. It can also be used with the ``setup_binary`` module to build two stars in a binary system.

Physical & Mathematical Description
------------------------------------

A polytropic star satisfies the Lane-Emden equation :math:`(1/\xi^2) d/d\xi[\xi^2 d\theta/d\xi] + \theta^n = 0` where :math:`\xi = r/r_n` is the dimensionless radius and :math:`n = 1/(\gamma-1)` is the polytropic index. The central density and polytropic constant :math:`K = P/\rho^\gamma` determine the stellar mass :math:`M_*` and radius :math:`R_*` through :math:`M_* = -4\pi r_n^3 \rho_c \xi_1^2 (d\theta/d\xi)_{\xi_1}` where :math:`\xi_1` is the surface. For GR stars the Tolman-Oppenheimer-Volkoff equation replaces the Lane-Emden equation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_star.f90`` for the complete source.
