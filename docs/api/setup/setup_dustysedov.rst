.. phantom-doc: hand-written

setup_dustysedov
================

Overview
--------

``setup_dustysedov`` configures a Sedov-Taylor blast wave in a two-fluid dusty medium, following Laibe & Price (2012a, b). Gas and dust particles are both placed on uniform Cartesian lattices in a periodic box; a point explosion deposits a finite energy :math:`E_0` into the gas particles in the centre of the domain by raising their specific internal energy. The subsequent blast wave sweeps both gas and dust outward, and the drag coupling between the two species modifies the dust distribution compared to a pure-gas Sedov blast.

This setup tests the consistency of the SPH dust-gas drag implementation in the presence of strong shocks. The analytic Sedov solution for the gas-only case provides the outer boundary condition, while the dust distribution inside the blast wave tests whether drag correctly transfers momentum from the shocked gas to the dust grains on the stopping-time timescale.

No runtime parameter file is required; all parameters (box size, particle number, explosion energy, dust-to-gas ratio) are hard-coded in the source.

Physical & Mathematical Description
------------------------------------

The Sedov blast wave radius grows as :math:`R(t) = \xi_0 (E_0 / \rho_0)^{1/5} t^{2/5}`, where :math:`\xi_0 \approx 1.033` is a dimensionless constant for :math:`\gamma = 5/3` and :math:`\rho_0` is the ambient density. Dust grains inside the shock are accelerated by Epstein drag; grains with stopping time :math:`t_s \ll t` are well coupled and track the gas, while grains with :math:`t_s \gg t` remain near their pre-shock positions. The blast wave energy is deposited so that the total explosion energy :math:`E_0 = 1` in code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_dustysedov.f90`` for the complete source.
