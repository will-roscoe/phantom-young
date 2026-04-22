.. phantom-doc: hand-written

setup_kh
========

Overview
--------

``setup_kh`` initialises the Kelvin-Helmholtz instability test of Robertson et al. (2010). Two fluid layers with different densities (:math:`\rho_1` and :math:`\rho_2`) and opposite horizontal velocities (:math:`v_1` and :math:`v_2`) are placed in a 2D periodic box. A sinusoidal velocity perturbation of small amplitude is added in the transverse direction at the two shear interfaces to seed the instability. The pressure is uniform throughout, so the two layers are in pressure equilibrium.

The density contrast between the layers, the Mach numbers, and the perturbation amplitude determine the growth rate of the Kelvin-Helmholtz roll-up. SPH codes historically struggle with this test due to the surface tension-like effect arising from the kernel interpolation at density discontinuities; comparing roll-up morphology and linear growth rate against reference solutions provides a stringent test of the interface treatment.

The box dimensions are set by ``xsize`` and ``ysize``, and resolution is controlled by ``nx``, the number of particles in the x direction. The central dense layer occupies a width ``dy2`` centred on the midplane.

Physical & Mathematical Description
------------------------------------

The linear Kelvin-Helmholtz growth rate for a sinusoidal perturbation of wavenumber :math:`k` at a density interface is :math:`\sigma = k |v_1 - v_2| \sqrt{\rho_1 \rho_2} / (\rho_1 + \rho_2)`, giving an e-folding time :math:`\tau_\mathrm{KH} = 1/\sigma`. In the compressible regime this rate is modified by the Mach number; for :math:`M \sim 1` the growth rate is suppressed relative to the incompressible limit. The seeded transverse velocity perturbation is :math:`\delta v_y = A \sin(2\pi x / L_x)` at each interface.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_kh.f90`` for the complete source.
