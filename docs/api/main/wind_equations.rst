.. phantom-doc: hand-written

wind_equations
==============

Overview
--------

The ``wind_equations`` module defines and integrates the 1D ordinary
differential equations for the steady-state stellar wind velocity profile.
The public routine ``evolve_hydro`` advances the state vector
:math:`(r, T, v)` — radius, temperature, and radial velocity — from a given
inner boundary over a single timestep using a 4th-order Runge-Kutta (RK4)
integrator with adaptive step-size control. The module is called iteratively
by the ``wind`` module to construct the full wind profile from the stellar
surface to the outer injection boundary.

The ``init_wind_equations`` routine sets stellar parameters (mass, surface
temperature, :math:`u`-to-temperature ratio) before integration begins.
Step-size control monitors the relative change in the state vector per step
and scales the timestep using the standard safety-factor formula with
:math:`\beta = -0.25` (shrink) and :math:`\beta = -0.2` (grow). The code
signals the critical point (sonic transition) via the integer ``spcode``
output.

Physical & Mathematical Description
------------------------------------

The wind equation in the reference frame of the star is the radial momentum
equation

.. math::

   \frac{dv}{dr} = \frac{v^2 - c_s^2 + r \,Q(r)}{v(c_s^2/v - v) r} \cdot
   \frac{\text{numerator}}{\text{denominator}},

where :math:`c_s = \sqrt{\gamma R_g T / \mu}` is the local sound speed and
:math:`Q(r)` represents radiative and other body forces (gravity, radiation
pressure, etc.). At the sonic point the denominator vanishes and the
numerator must also vanish (the regularity condition), which fixes the sonic
radius. Mass conservation gives :math:`\rho \propto 1 / (v r^2)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/wind_equations.f90
