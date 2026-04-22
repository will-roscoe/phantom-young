.. phantom-doc: hand-written

setup_taylorgreen
=================

Overview
--------

``setup_taylorgreen`` initialises the 3D Taylor-Green vortex, a standard benchmark for decaying incompressible turbulence used in the Phantom code paper (Price et al. 2017). The initial velocity field is the smooth Taylor-Green vortex: :math:`v_x = v_0 \sin(x)\cos(y)\cos(z)`, :math:`v_y = -v_0 \cos(x)\sin(y)\cos(z)`, :math:`v_z = 0`, and a corresponding pressure field that satisfies the incompressibility condition to leading order. Particles are placed on a 2D slab using the ``set_slab`` module with periodic boundaries.

The vortex decays through a turbulent cascade that converts large-scale kinetic energy to heat via numerical dissipation at the particle scale. The total kinetic energy as a function of time is compared with direct numerical simulation (DNS) reference data and spectral code results, providing a sensitive measure of the effective numerical Reynolds number of the SPH scheme.

This test is particularly useful for comparing the dissipation properties of different artificial viscosity switches, kernel functions, and SPH formulations, since the decay rate depends directly on how much energy is removed at the viscous scale.

Physical & Mathematical Description
------------------------------------

The Taylor-Green initial conditions in a box of side :math:`2\pi` are :math:`v_x = v_0 \sin x \cos y \cos z`, :math:`v_y = -v_0 \cos x \sin y \cos z`, :math:`v_z = 0`, :math:`P = P_0 + \rho_0 v_0^2 (\cos 2x + \cos 2y)(\cos 2z + 2)/16`. The total kinetic energy :math:`E_k(t) = \frac{1}{2}\rho_0 v_0^2 \exp(-2\nu k_0^2 t)` decays exponentially at early times for viscosity :math:`\nu` and wavenumber :math:`k_0 = 1`. The peak dissipation rate occurs around :math:`t \approx 9` in code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_taylorgreen.f90`` for the complete source.
