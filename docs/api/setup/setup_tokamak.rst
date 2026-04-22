.. phantom-doc: hand-written

setup_tokamak
=============

Overview
--------

``setup_tokamak`` initialises a toroidal MHD equilibrium in tokamak geometry, originally written by D. Price and C. Toniolo. The density and pressure profiles are set using a prescribed current distribution and toroidal geometry, with parameters ``atorus`` (the minor radius), ``currj0_torus`` (the central current density), ``polyk_torus`` (the sound speed parameter), and ``gamma_torus`` (the adiabatic index). Particles are placed in a toroidal volume using the geometry and stretchmap modules.

A toroidal magnetic field is imposed through an external field module (``extern_Bfield``), and an azimuthal current profile creates a poloidal field that together with the toroidal field gives the helical field configuration characteristic of tokamak equilibria. Random perturbations of particle positions are applied to avoid resonant lattice artefacts.

This setup is a non-astrophysical application of Phantom that tests the code's ability to handle toroidal geometry and MHD equilibria relevant to plasma physics, providing a bridge between astrophysical SPH and laboratory plasma simulation.

Physical & Mathematical Description
------------------------------------

The Grad-Shafranov equation for an axisymmetric MHD equilibrium is :math:`R \partial/\partial R (1/R \partial\Psi/\partial R) + \partial^2\Psi/\partial z^2 = -\mu_0 R^2 dP/d\Psi - F dF/d\Psi`, where :math:`\Psi` is the poloidal flux function and :math:`F = R B_\phi`. The safety factor :math:`q = r B_\phi / (R_0 B_\theta)` measures the winding ratio of field lines on a flux surface. MHD stability requires :math:`q > 1` everywhere to avoid the internal kink (Kruskal-Shafranov) mode.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_tokamak.f90`` for the complete source.
