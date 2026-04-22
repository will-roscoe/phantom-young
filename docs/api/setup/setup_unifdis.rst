.. phantom-doc: hand-written

setup_unifdis
=============

Overview
--------

``setup_unifdis`` places particles on a uniform distribution (cubic or close-packed lattice) in a periodic box, serving as a multipurpose initialisation for tests requiring a uniform background medium. The box dimensions are set by ``xmin``/``xmax``, ``ymin``/``ymax``, ``zmin``/``zmax`` in code units, the density by ``rhozero``, and the isothermal sound speed by ``cs0``. An optional magnetic field ``Bzero`` and optional dust component with a dust-to-gas ratio are also configurable.

The setup supports multiple equations of state (``gamma`` for adiabatic, isothermal, or radiation-coupled), multiple lattice types (cubic or close-packed, selected by ``ilattice``), and dust-gas mixtures via the one-fluid ``use_dustfrac`` approach. It also checks whether radiation quantities need initialising (``exchange_radiation_energy``) and applies the flux limiter if needed.

This is one of the most flexible low-level setups in Phantom, used as the starting point for wave tests, MHD benchmarks, and any simulation requiring a homogeneous initial state.

Physical & Mathematical Description
------------------------------------

A close-packed (face-centred cubic) lattice of :math:`N` particles in a box of volume :math:`V` gives a mean inter-particle spacing :math:`\Delta x = (V/N)^{1/3}` and a smoothing length :math:`h = h_\mathrm{fact} (m/\rho)^{1/3}` where the factor :math:`h_\mathrm{fact} \approx 1.2` ensures adequate kernel coverage. The close-packed lattice reduces zeroth-order SPH errors compared to the cubic lattice by minimising the asymmetry in the particle distribution function. The uniform density :math:`\rho_0` gives a particle mass :math:`m = \rho_0 V / N`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_unifdis.f90`` for the complete source.
