.. phantom-doc: hand-written

einsteintk_utils
================

Overview
--------

``einsteintk_utils`` provides grid data storage and initialisation utilities for coupling Phantom to the Einstein Toolkit (ET) numerical relativity framework. Maintained by Spencer Magnall, it manages the grid arrays required to communicate the stress-energy tensor :math:`T^{\mu\nu}`, rest-mass density :math:`\rho_*`, and four-momentum :math:`p^i` between Phantom's SPH particles and the ET Cactus grid.

The module allocates and manages arrays ``tmunugrid``, ``rhostargrid``, ``pxgrid``, and ``entropygrid`` on a Cartesian grid specified by ``gridsize``, ``dxgrid``, and ``gridorigin``. The ``init_etgrid`` subroutine initialises the grid parameters from the ET grid driver, while ``exact_rendering`` controls whether particle-to-grid mapping uses exact SPH kernel evaluation.

Persistent storage of the log, ev, dump, and input file paths (``logfilestor``, etc.) ensures that Phantom can correctly manage I/O when called repeatedly from within the ET time-stepping loop.

Physical & Mathematical Description
------------------------------------

The stress-energy tensor components :math:`T^{\mu\nu}` on the ET grid are computed by SPH interpolation of the particle stress-energy tensor :math:`T^{\mu\nu}_i = \rho_i u^\mu_i u^\nu_i + (P_i + e_i) u^\mu_i u^\nu_i / c^2 - P_i g^{\mu\nu}_i`, where :math:`u^\mu` is the four-velocity, :math:`P` the pressure, and :math:`e` the specific internal energy. Grid interpolation uses the SPH kernel: :math:`T^{\mu\nu}(\mathbf{x}) = \sum_i (m_i / \rho_i) T^{\mu\nu}_i W(|\mathbf{x} - \mathbf{r}_i|, h_i)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/einsteintk_utils.f90
