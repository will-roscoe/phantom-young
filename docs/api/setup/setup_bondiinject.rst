.. phantom-doc: hand-written

setup_bondiinject
=================

Overview
--------

``setup_bondiinject`` extends the basic Bondi setup with continuous particle injection at the outer boundary to maintain a steady-state accretion flow over arbitrarily long run times. It is based on the GR Bondi wind scenario of Liptai & Price (2019). At startup the domain may optionally be pre-filled with particles out to the accretion radius (``filldomain = .true.``), reducing the time needed to reach quasi-steady state.

The particle mass is set by the parameter ``pmassi``, which also determines the mass resolution of the simulation. Injection of new particles at the outer boundary at each time step replaces mass lost through the inner accretion radius, ensuring the far-field density and velocity remain at the prescribed Bondi boundary values throughout the run.

This setup is particularly useful for studying transient accretion episodes and the approach to steady-state in both Newtonian and GR regimes, as well as for validating the particle injection algorithm against the analytic Bondi solution.

Physical & Mathematical Description
------------------------------------

Particles are injected at the outer boundary with density and velocity matching the analytic Bondi profile :math:`\rho(r) \propto r^{-n}` and :math:`v_r(r)` from the exact sonic-point solution. The injection rate is calibrated so that the mass flux :math:`\dot{M} = 4\pi r^2 \rho v_r` matches the target Bondi rate at all radii. The adiabatic index :math:`\gamma` controls both the sonic point location and the density profile slope.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_bondiinject.f90`` for the complete source.
