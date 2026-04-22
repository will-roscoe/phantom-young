.. phantom-doc: hand-written

setup_collidingclouds
=====================

Overview
--------

``setup_collidingclouds`` initialises N converging ellipsoidal gas flows in a box, following Wurster & Bonnell (2023). Each flow is an elliptical cloud with individually configurable density, temperature, and velocity, set up to collide with its counterpart(s) near the centre of the domain. The background medium has a separately specified temperature ``Temperature_medium`` and density determined by a density contrast parameter.

The setup supports both hydrodynamic and magnetohydrodynamic runs (controlled by the ``mhd`` compile flag), with a uniform magnetic field strength ``Bzero`` applied in Gauss. Sink particle creation is enabled when the local density exceeds ``rho_crit_cgs``, with accretion radius ``h_acc`` and sink-sink softening ``h_soft_sinksink``. Dynamic boundary conditions can be activated to allow the box to expand or contract with the flow.

This scenario is used to model cloud-cloud collisions that trigger star formation, particularly in galactic spiral arms where supersonic turbulence drives head-on encounters between molecular clouds.

Physical & Mathematical Description
------------------------------------

The shock velocity at the collision interface scales with the relative inflow speed :math:`v_\mathrm{rel}`, giving a post-shock density :math:`\rho_s = \rho_0 (\gamma+1)/(\gamma-1)` in the strong-shock limit. For magnetised collisions, the plasma beta :math:`\beta_p = 8\pi \rho c_s^2 / B^2` determines the relative importance of magnetic pressure to ram pressure. The Jeans criterion at post-shock densities determines whether the compressed layer fragments into stars.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_collidingclouds.f90`` for the complete source.
