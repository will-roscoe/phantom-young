.. phantom-doc: hand-written

setup_mhdvortex
===============

Overview
--------

``setup_mhdvortex`` initialises the MHD vortex test of Balsara (2004) and Dumbser et al. (2008). The vortex is a smooth, steady solution of the ideal MHD equations in which centrifugal and centripetal accelerations from the rotational velocity are balanced by magnetic tension, and thermal and magnetic pressure are in equilibrium. Because it is an exact stationary solution, the vortex should return to its original state after advection across the periodic domain at the background flow speed.

Particles are placed in a 2D slab using the ``set_slab`` module. The velocity and magnetic field profiles are set analytically at setup time. Numerical diffusion causes the vortex to spread and lose amplitude over time; the error in vortex shape and peak amplitude after one traversal period measures the numerical dissipation of the scheme.

This test is more demanding than the linear wave tests because the vortex structure involves large-amplitude variations in density, pressure, velocity, and magnetic field simultaneously.

Physical & Mathematical Description
------------------------------------

The MHD vortex has a velocity profile :math:`v_\phi(r) = \Gamma r e^{(1-r^2)/2} / (2\pi)` and magnetic field :math:`B_\phi(r) = \mu r e^{(1-r^2)/2} / (2\pi)` in cylindrical coordinates, with a pressure profile that ensures force balance. The temperature perturbation is :math:`\Delta T = -(\Gamma^2 - \mu^2) e^{1-r^2} / (8\pi^2)`. The vortex advects at velocity :math:`(u_0, v_0)` across the periodic box, returning to its initial position after time :math:`T = L / u_0`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_mhdvortex.f90`` for the complete source.
