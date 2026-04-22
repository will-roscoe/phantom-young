.. phantom-doc: hand-written

setup_radiativebox
==================

Overview
--------

``setup_radiativebox`` initialises a uniform gas box for radiation-hydrodynamics tests. Particles are placed on a cubic or close-packed lattice with density ``rhozero``, sound speed ``cs0``, and a uniform radiation field. The setup supports multiple radiation test configurations (controlled by the ``iradtype`` internal flag) including radiation diffusion, radiation pressure, and flux-limited diffusion tests. The box geometry is fully configurable via ``xmin``/``xmax``, ``ymin``/``ymax``, ``zmin``/``zmax`` parameters.

The radiation energy density and gas temperature are initialised in a specified state (optionally in thermal equilibrium with the radiation field). Opacity :math:`\kappa` is set as a uniform constant. The setup uses Phantom's radiation utilities module to exchange radiation energy between the gas and radiation field at startup, ensuring consistent initial conditions for the chosen radiation-gas coupling regime.

This setup is used to validate Phantom's radiation transport implementation against analytic solutions for radiation diffusion, radiation pressure acceleration, and the approach to radiative equilibrium in an optically thick medium.

Physical & Mathematical Description
------------------------------------

In the optically thick diffusion limit the radiation flux is :math:`\mathbf{F} = -c / (3\kappa\rho) \nabla E_\mathrm{rad}`, where :math:`E_\mathrm{rad} = a_\mathrm{rad} T^4` is the radiation energy density. The radiation diffusion timescale across a box of size :math:`L` is :math:`t_\mathrm{diff} = 3 \kappa \rho L^2 / c`. The radiation pressure is :math:`P_\mathrm{rad} = E_\mathrm{rad}/3`, and the ratio of radiation to gas pressure is :math:`\beta_\mathrm{rad} = P_\mathrm{rad} / P_\mathrm{gas} = a_\mathrm{rad} T^3 / (3 \rho k_B / (\mu m_p))`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_radiativebox.f90`` for the complete source.
