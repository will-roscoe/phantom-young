.. phantom-doc: hand-written

inject_windtunnel
=================

Overview
--------

The ``inject_windtunnel`` module (module name ``inject``,
``inject_type = 'windtunnel'``) injects a uniform wind into a cylindrical
wind-tunnel domain for BHL accretion studies, based on the setup of Mike Lau.
The default parameters match model MS6 of Ruffert and Arnett (1994): wind speed
``v_inf``, ambient density ``rho_inf``, and Mach number ``mach = 13.87``. The
wind flows in the +x direction and is injected at ``wind_injection_x``; a
sphere of particles (``Rstar`` and ``nstar``) at the domain centre represents
the accreting object. An optional ``hold_star`` flag subtracts the centre-of-mass
velocity of the stellar particles each timestep to prevent drift.

Runtime parameters include ``v_inf``, ``rho_inf``, ``mach``, the wind cylinder
radius ``BHL_radius`` (named ``wind_radius`` internally), the x-position of the
injection boundary ``wind_injection_x``, the approximate wind length
``wind_length`` (in star radii), the lattice type (0 = cubic, 1 = close-packed),
``handled_layers`` (number of boundary layers in memory), and the stellar sphere
radius ``Rstar`` and associated flags. The module allocates layer coordinate
arrays at initialisation and frees them at program exit.

Physical & Mathematical Description
------------------------------------

The wind is injected as successive parallel slabs of particles with
inter-particle separation ``psep`` determined by the particle mass and ambient
density :math:`\rho_\text{inf}`. For the close-packed lattice, alternating
layers are offset by :math:`\mathtt{psep}/2` in both y and z, approximating an
FCC packing. The layer injection cadence is

.. math::

   \Delta t_\text{layer} = \frac{\mathtt{psep}}{v_\text{inf}},

ensuring uniform inter-particle spacing in all directions. The sound speed and
internal energy at injection are:

.. math::

   c_s = \frac{v_\text{inf}}{\mathcal{M}}, \quad
   u = \frac{c_s^2}{\gamma(\gamma-1)}.

The Bondi-Hoyle-Lyttleton accretion radius is
:math:`r_\text{BHL} = 2 G M_\star / (v_\text{inf}^2 + c_s^2)`, which sets the
characteristic length scale of the problem. Particles that drift beyond
``wind_length`` upstream or outside the cylinder radius are killed each step.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
