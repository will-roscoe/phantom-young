.. phantom-doc: hand-written

setup_bondi
===========

Overview
--------

``setup_bondi`` configures spherical Bondi accretion onto a central point mass, supporting both Newtonian and general-relativistic (GR) variants as described by Liptai & Price (2019). Three solution types are available via ``isol``: a uniform-density sphere, a geodesic inflow, and an initialisation at the sonic point of the exact Bondi solution. The particles are placed using a stretch-mapping technique to reproduce the target density profile :math:`\rho(r)` with approximately the requested number of particles ``np``.

In the Newtonian case the central mass is applied via an external potential, while in the GR case the spacetime metric is specified through the ``metric`` module. Both inflow (accretion) and outflow (wind) boundary conditions are supported, controlled by the ``iswind`` logical parameter. The outer and inner radii of the particle distribution are set by ``rmax`` and ``rmin``.

This setup serves as a fundamental test of SPH's ability to maintain a steady spherically symmetric accretion flow, with the analytic Bondi solution providing the reference state for convergence studies.

Physical & Mathematical Description
------------------------------------

The classical Bondi accretion rate is :math:`\dot{M}_B = 4\pi \lambda_c G^2 M^2 \rho_\infty / c_{s,\infty}^3`, where :math:`\lambda_c \approx 0.25` for :math:`\gamma = 5/3`, :math:`M` is the central mass, :math:`\rho_\infty` is the ambient density, and :math:`c_{s,\infty}` is the ambient sound speed. The sonic radius :math:`r_c = GM / (2 c_{s,\infty}^2)` marks the location where the inflow velocity equals the sound speed. In GR the corresponding solution is obtained from the Tolman-Oppenheimer-Volkoff equations for the spacetime metric.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_bondi.f90`` for the complete source.
