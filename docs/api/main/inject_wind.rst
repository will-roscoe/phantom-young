.. phantom-doc: hand-written

inject_wind
===========

Overview
--------

The ``inject_wind`` module (module name ``inject``, ``inject_type = 'wind'``)
implements full stellar wind injection for AGB and evolved-star simulations,
developed by Lionel Siess. Particles are injected on concentric geodesic
spheres (icosahedron tessellations from the ``icosahedron`` module) at the
wind injection radius, with velocities, densities, and thermodynamic states
set from the ``wind`` and ``wind_equations`` modules. The module supports
transonic wind solutions (``sonic_type = 1``) and fixed-velocity injection
(``sonic_type = 0``), pulsating winds driven by a piston at the stellar
surface, and an optional background density profile filled by ``nfill_domain``
spheres at initialisation.

Key runtime parameters include ``wind_mass_rate`` (Msun/yr), ``wind_inject_radius``
(au), ``wind_temperature`` (K), ``wind_velocity`` (km/s, for non-transonic
solutions), ``iboundary_spheres`` (number of held boundary shells),
``iwind_resolution`` (geodesic level setting the number of particles per
sphere), ``wind_shell_spacing`` (ratio of sphere spacing to particle spacing),
``outer_boundary`` (au, beyond which particles are removed), and ``B_r``
(radial magnetic field at injection in Gauss). Pulsation is controlled by
``pulsation_period_days`` and ``piston_velocity_km_s``.

Physical & Mathematical Description
------------------------------------

The number of particles per geodesic sphere at resolution level :math:`n` is
:math:`10 \times 4^n + 2`. The inter-sphere spacing is set equal to the
inter-particle spacing on the sphere, :math:`\Delta r = \Delta s`, where
:math:`\Delta s \approx \sqrt{4\pi r_\text{inj}^2 / N_\text{sphere}}`.
The time between successive sphere injections is therefore

.. math::

   \Delta t_\text{sphere} = \frac{\Delta r}{v_\text{wind}(r_\text{inj})},

ensuring a uniform mass flux. For the transonic solution, the wind velocity
profile :math:`v(r)` is obtained by integrating the wind ODE from
``wind_equations`` and the injection speed is read from this profile at
:math:`r = r_\text{inj}`. The density at injection follows from mass
conservation:

.. math::

   \rho(r_\text{inj}) = \frac{\dot{M}}{4\pi r_\text{inj}^2 v(r_\text{inj})}.

For pulsating winds, the piston displacement :math:`\delta R_\text{osc}`
oscillates sinusoidally with the pulsation period, providing a time-variable
injection radius and velocity boundary condition.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
