.. phantom-doc: hand-written

setup_srpolytrope
=================

Overview
--------

``setup_srpolytrope`` builds a polytropic star in special-relativistic (Minkowski metric) equilibrium following Liptai & Price (2019). The stellar structure is computed by integrating the special-relativistic Lane-Emden equation with a polytropic equation of state :math:`P = K \rho^\gamma`. The resulting density profile is mapped to SPH particles in a sphere using the ``set_sphere`` routine with the ``nr`` parameter controlling the radial resolution.

After placement, the star is relaxed to remove any residual transients from the SPH particle arrangement by running the ``cons2prim`` and derivative routines iteratively. The code applies SR corrections through the ``metric_tools`` module operating in flat Minkowski spacetime, producing an equilibrium that can serve as a convergence test for the full GR star setup in ``setup_star`` or ``setup_grdisc``.

This setup is used to test the special-relativistic hydrodynamics module's ability to maintain hydrostatic equilibrium over many dynamical timescales, a demanding test of both the SPH scheme and the SR equation of state implementation.

Physical & Mathematical Description
------------------------------------

The SR Lane-Emden equation for a polytrope :math:`P = K\rho^\gamma` is :math:`d^2\theta/d\xi^2 + (2/\xi)d\theta/d\xi + \theta^n = 0` in the Newtonian limit, modified by relativistic pressure corrections proportional to :math:`P / \rho c^2`. The stellar radius and mass are determined by the polytropic index :math:`n = 1/(\gamma-1)`, the polytropic constant :math:`K`, and the central density. The relativistic correction factor :math:`\Gamma = 1/\sqrt{1 - v^2/c^2}` must be included in the momentum and energy equations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_srpolytrope.f90`` for the complete source.
