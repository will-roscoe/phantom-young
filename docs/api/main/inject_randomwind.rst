.. phantom-doc: hand-written

inject_randomwind
=================

Overview
--------

The ``inject_randomwind`` module (module name ``inject``,
``inject_type = 'randomwind'``) injects wind particles from the surface of an
orbiting body such as an asteroid, planet, or star, as used in Trevascus et al.
(2021). Particles are launched from random positions on a sphere of radius
``r_inject`` centred on the orbiting body with a velocity equal to the body's
velocity plus an outward wind component. Three wind modes are available:
asteroid-style isotropic wind (``wind_type = 0``), random wind from a tracked
sink particle (``wind_type = 1``), and boil-off evaporation (``wind_type = 2``).

The surface distribution is either uniform random (``random_type = 0``) or
Gaussian-concentrated toward the sub-stellar point (``random_type = 1``), with
standard deviation ``delta_theta``. A ``vlag`` parameter allows the injected
wind speed to lag behind the Keplerian orbital speed by a specified fraction.
The mass injection rate ``mdot`` can be constant (``mdot_type = 0``) or
radially dependent as :math:`\dot{M} \propto r^{-2}` (``mdot_type = 2``).

Physical & Mathematical Description
------------------------------------

The number of particles injected per timestep is determined by
:math:`\Delta N = \lfloor \dot{M}_\text{eff} \Delta t / m_\text{SPH} \rfloor`,
where :math:`\dot{M}_\text{eff}` is evaluated at the current orbital radius
for ``mdot_type = 2``:

.. math::

   \dot{M}_\text{eff}(r) = \dot{M}_0 \left(\frac{r_\text{ref}}{r}\right)^2.

Each particle is placed at a random position on the injection sphere. For
uniform injection, positions are drawn using ``get_random_pos_on_sphere``; for
Gaussian injection, positions are drawn using ``get_gaussian_pos_on_sphere``
with spread ``delta_theta`` around the specified tilt direction
(:math:`\theta`, :math:`\phi`). The wind speed is set to a factor
``wind_speed_factor`` times the local Keplerian speed (for ``wind_type = 1``)
minus the ``vlag`` fraction, giving
:math:`v_\text{wind} = (1 - \mathtt{vlag}) \cdot \mathtt{wind\_speed\_factor} \cdot v_K`.
For boil-off (``wind_type = 2``), the sink pressure is used to compute the
escape velocity.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
