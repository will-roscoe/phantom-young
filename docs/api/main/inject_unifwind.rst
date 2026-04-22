.. phantom-doc: hand-written

inject_unifwind
===============

Overview
--------

The ``inject_unifwind`` module (module name ``inject``,
``inject_type = 'unifwind'``) injects a uniform wind flowing in the
x-direction through the simulation domain. Particles are placed on successive
planar walls at the x = ``xmin`` boundary, each wall being a uniform grid in
the y-z plane. The wind density, velocity, and temperature are set by runtime
parameters, making this module suitable for wind-tunnel and bow-shock
benchmarks such as the dusty wind tests of Bowen (1988).

Runtime parameters are the wind resolution ``wind_resolution`` (number of
particles per side of the injection plane, which must not be changed after
setup) and ``wind_temperature`` (K). The wind density and velocity are
set in the source code defaults as
``wind_density = 7.2e-16`` (g/cm\ :sup:`3`) and
``wind_velocity = 29`` (km/s), matching the Bowen (1988) AGB wind benchmark.
The mean molecular weight :math:`\mu = 1.26` is hardcoded following Bowen (1988).

Physical & Mathematical Description
------------------------------------

The injection plane spans :math:`[y_\text{min}, y_\text{max}] \times [z_\text{min}, z_\text{max}]`
with uniform grid spacing :math:`\delta = (y_\text{max} - y_\text{min})/N`
where :math:`N = \mathtt{wind\_resolution}`. The time between successive walls
is :math:`\Delta t = \delta / v_\text{wind}`, so particles are spaced equally
in all three dimensions. The internal energy per unit mass is

.. math::

   u = \frac{R_g T}{\mu (\gamma - 1)},

where :math:`R_g` is the gas constant, :math:`T` is ``wind_temperature``, and
:math:`\mu` is the mean molecular weight. Walls already inside the domain
(``outer_wall`` and ``inner_wall`` indices) serve as boundary layers that
provide a pressure support buffer; only the innermost ``handled_walls = 3``
walls are held as active boundaries. Particles beyond the live domain boundary
are activated as gas particles subject to SPH forces.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
