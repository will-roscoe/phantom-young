.. phantom-doc: hand-written

setup_testparticles
===================

Overview
--------

``setup_testparticles`` places a small number of massless tracer (test) particles on prescribed orbits around a central mass or in a prescribed gravitational field. The central object may be a black hole modelled by an external potential (including Kerr GR geodesics via the metric module). Orbit types selectable by ``orbtype`` include circular orbits, precessing orbits, epicyclic orbits, and vertical oscillations, as well as custom initial conditions specified by ``(x0, y0, z0)`` and ``(vx0, vy0, vz0)``.

Because the particles are massless they do not interact with each other or contribute to the SPH force calculation — they simply follow geodesics or Newtonian orbits in the prescribed potential. The black hole spin parameter ``spin`` controls the Kerr metric, and the number of orbits ``norbits`` and dumps per orbit ``dumpsperorbit`` control the output cadence.

This setup is used to test the geodesic integrator in Phantom's GR module, to verify orbital precession rates, and to place tracer particles in existing flow fields to visualise the Lagrangian structure of the flow.

Physical & Mathematical Description
------------------------------------

For a test particle in a Kerr spacetime the radial coordinate oscillates about the circular orbit at the epicyclic frequency :math:`\kappa^2 = \Omega_K^2 (1 - 6r_g/r + 8a r_g^{3/2}/r^{5/2} - 3a^2 r_g^2/r^4)` while the vertical oscillation frequency is :math:`\Omega_z^2 = \Omega_K^2 (1 - 4a r_g^{3/2}/r^{5/2} + 3a^2 r_g^2/r^4)`. The apsidal precession rate :math:`\Omega_p = \Omega_K - \kappa` diverges at the ISCO. In Newtonian gravity :math:`\kappa = \Omega_K` and there is no precession.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_testparticles.f90`` for the complete source.
