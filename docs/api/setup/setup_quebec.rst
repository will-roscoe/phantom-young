.. phantom-doc: hand-written

setup_quebec
============

Overview
--------

``setup_quebec`` sets up a specific blast wave problem used as a convergence test in collaborations with Thierry Tricco and the Quebec group (as noted in the source comments). A uniform gas sphere of ``np`` particles is initialised at high density and temperature (with critical values ``rho_crit = 10 g/cm^3`` and ``temp_crit = 1e7 K`` hard-coded in the source) to serve as the initial conditions for a spherical explosion.

The sphere is built using the ``set_sphere`` routine with particles in a uniform distribution. The extreme thermodynamic conditions — comparable to those in a core-collapse supernova or inertial confinement fusion context — make this a challenging test of the code's ability to handle high-energy events with large density and pressure contrasts. The adiabatic index and equation of state are set to standard values.

The test is used to verify convergence of the shock morphology and post-shock thermodynamic state as a function of particle number, complementing the simpler 1D Sedov blast wave test with a self-contained spherical geometry.

Physical & Mathematical Description
------------------------------------

The sphere is initialised with density :math:`\rho_0 = 10\ \mathrm{g/cm}^3` and temperature :math:`T_0 = 10^7\ \mathrm{K}`, giving an internal energy per unit mass :math:`u_0 = k_B T_0 / (\mu m_p (\gamma-1))`. The total thermal energy :math:`E_\mathrm{therm} = M u_0` drives the subsequent explosion. The blast wave radius grows as :math:`R(t) \propto (E/\rho_0)^{1/5} t^{2/5}` in the Sedov self-similar regime.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_quebec.f90`` for the complete source.
