.. phantom-doc: hand-written

wind
====

Overview
--------

The ``wind`` module is the top-level driver for integrating the 1D stellar
wind structure in Phantom's AGB/RSG wind simulations. It calls
``wind_equations`` to advance the radial wind profile from the stellar
surface outward, optionally finding the transonic sonic point if required.
The wind profile (radius, velocity, temperature, density, dust
nucleation/growth quantities) is stored in the 2D array ``trvurho_1D``
and the nucleation state in ``JKmuS_1D``, which are then used by the
injection module to set the properties of newly injected SPH particles.

The module also provides ``save_windprofile`` for writing the 1D wind
profile to a diagnostic file, ``interp_wind_profile`` for interpolating
the profile to an arbitrary radius, and the ``wind_state`` derived type
that encapsulates the full state of the 1D integrator (position, velocity,
temperature, dust opacity, Eddington ratio, etc.) at any point during the
wind integration. The wind model follows the framework of Lamers & Cassinelli
"Introduction to Stellar Winds", using either a beta-velocity law or
direct integration of the wind momentum equation.

Physical & Mathematical Description
------------------------------------

The stellar wind velocity profile is computed by integrating the wind
momentum equation (see ``wind_equations``). For a beta-velocity law the
profile is prescribed as

.. math::

   v(r) = v_\infty \left(1 - \frac{R_*}{r}\right)^\beta,

where :math:`v_\infty` is the terminal velocity, :math:`R_*` the stellar
radius, and :math:`\beta \approx 0.5`–3 a fit parameter. In the dust-driven
wind mode the velocity and dust nucleation/growth are integrated
self-consistently using a Runge-Kutta scheme in ``wind_equations``, with the
dust opacity :math:`\kappa` coupling the radiation pressure to the wind
dynamics through the Eddington factor :math:`\Gamma = L\kappa/(4\pi cGM)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/wind.F90
