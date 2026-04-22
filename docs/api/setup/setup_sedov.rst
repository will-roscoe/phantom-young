.. phantom-doc: hand-written

setup_sedov
===========

Overview
--------

``setup_sedov`` sets up the Sedov-Taylor blast wave, one of the most widely used benchmarks in compressible hydrodynamics. A point explosion of energy :math:`E_0` is deposited in the centre of a uniform periodic box by raising the specific internal energy of the central particles. The surrounding medium has uniform density ``rhozero`` and zero pressure. Particles are placed on a close-packed, cubic, hexagonal close-packed (HCP), or random lattice as selected by the ``lattice`` parameter, and optional particle shuffling (``shuffle_parts``) can be applied to improve uniformity.

The Sedov blast wave has an analytic self-similar solution that gives the shock radius, velocity, and post-shock thermodynamic state as a function of time, providing a precise reference for convergence testing. The simulation is run until the shock has expanded to a significant fraction of the box, and the numerical shock position and density jump are compared with the analytic solution.

The resolution is set by ``npartx``, the number of particles in the x direction of the initial lattice. Both adiabatic and isothermal variants can be run by choosing the appropriate equation of state.

Physical & Mathematical Description
------------------------------------

The Sedov blast wave radius grows as :math:`R_s(t) = \xi_0 (E_0/\rho_0)^{1/5} t^{2/5}`, where :math:`\xi_0 \approx 1.033` for :math:`\gamma = 5/3` in 3D. The shock velocity is :math:`v_s = (2/5) R_s / t`. The peak post-shock density for an adiabatic shock is :math:`\rho_s = \rho_0 (\gamma+1)/(\gamma-1) = 4\rho_0` for :math:`\gamma = 5/3`. The energy is deposited so that the total enclosed energy in the Sedov solution matches :math:`E_0` at all times.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_sedov.f90`` for the complete source.
