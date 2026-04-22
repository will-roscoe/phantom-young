.. phantom-doc: hand-written

interpolate3D
=============

Overview
--------

``interpolate3D`` is an SPH-to-grid interpolation module that maps particle data onto a regular 3D Cartesian grid. Maintained by Spencer Magnall and originally based on the SPLASH interpolation library, it implements the ``interpolate3D`` routine for standard kernel interpolation and ``interpolate3D_vecexact`` for exact rendering using the Einstein Toolkit metric.

For each grid point the routine sums the weighted kernel contribution from all SPH particles within the kernel support radius, using the standard SPH interpolation formula :math:`f(\mathbf{x}) = \sum_b (m_b / \rho_b) f_b W(|\mathbf{x} - \mathbf{r}_b|, h_b)`. The Einstein Toolkit coupling uses the ``exact_rendering`` flag from ``einsteintk_utils`` to select between standard and exact interpolation modes.

This module is used by ``einsteintk_utils`` to map the SPH stress-energy tensor onto the ET grid, and can be used standalone for any SPH-to-grid mapping task.

Physical & Mathematical Description
------------------------------------

The SPH kernel interpolation to a grid point :math:`\mathbf{x}` is :math:`f(\mathbf{x}) = \sum_b w_b f_b W(|\mathbf{x} - \mathbf{r}_b|, h_b)` where the weight for a standard SPH estimate is :math:`w_b = m_b / \rho_b`. The kernel :math:`W(r, h) = \sigma_3 h^{-3} w(r/h)` is the M4 cubic spline (or other compiled kernel) with normalisation ``cnormk3D``. Only particles within ``radkern2 * h_b^2`` of the grid point contribute.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/interpolate3D.f90
