.. phantom-doc: hand-written

inject_BHL
==========

Overview
--------

The ``inject_BHL`` module (module name ``inject``, ``inject_type = 'BHL'``)
implements particle injection for Bondi-Hoyle-Lyttleton (BHL) accretion
simulations. A uniform supersonic wind is injected upstream of a central
point mass, and the interaction of the wind with the gravitational field of
the mass drives accretion. The default parameters follow model MS6 of
Ruffert & Arnett (1994): Mach number 3, adiabatic index 5/3.

Particles are injected on the inflow face of a cylinder of radius
``BHL_radius`` (in units of the accretion (Bondi) radius :math:`R_a = 1`) at
the upstream boundary ``BHL_wind_injection_x``. Either a cubic lattice or a
close-packed arrangement of particles is supported via the flag
``BHL_closepacked``. The module pre-computes ``max_layers`` injection layers
and the corresponding even/odd layer templates, then adds one new layer per
call to ``inject_particles`` to maintain a continuous inflow at velocity
``v_wind = BHL_mach * c_inf``.

Physical & Mathematical Description
------------------------------------

In the BHL problem, the wind has uniform density :math:`\rho_\infty = 1`,
sound speed :math:`c_\infty = 1`, and velocity :math:`v_\infty = M c_\infty`
where :math:`M` is the Mach number. The accretion radius (the natural length
scale) is

.. math::

   R_a = \frac{2GM}{v_\infty^2 + c_\infty^2}.

Particles are injected with this velocity and density at the upstream
boundary. The specific internal energy of injected particles is
:math:`u_\infty = c_\infty^2 / (\gamma(\gamma-1))`. The injection layer
spacing equals the inter-particle separation, so the mass flux is continuous
and uniform.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/inject_BHL.f90
