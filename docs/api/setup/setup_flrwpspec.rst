.. phantom-doc: hand-written

setup_flrwpspec
===============

Overview
--------

``setup_flrwpspec`` extends the basic FLRW cosmological setup with realistic initial conditions generated from a matter power spectrum. Rather than a simple sinusoidal perturbation, it reads velocity displacement fields derived from a cosmological power spectrum using the Zel'dovich approximation, allowing cosmological structure formation to be simulated from near-linear initial conditions.

The particles are placed on a regular lattice and then displaced according to the Zel'dovich displacement field from pre-computed velocity cube files. The setup shares the same basic FLRW parameters as ``setup_flrw`` (density, sound speed, lattice type, box size, radiation-dominated flag) but requires the external velocity cube files to provide the power-spectrum perturbations.

This setup is the starting point for cosmological SPH simulations aimed at testing structure formation in GR, complementing grid-based cosmological codes such as RAMSES or Gadget.

Physical & Mathematical Description
------------------------------------

In the Zel'dovich approximation the comoving position of a fluid element is :math:`\mathbf{x}(\mathbf{q}, t) = \mathbf{q} + D_+(t) \boldsymbol{\Psi}(\mathbf{q})`, where :math:`\mathbf{q}` is the Lagrangian (initial) position and :math:`D_+(t)` is the linear growth factor. The displacement field :math:`\boldsymbol{\Psi}` is related to the matter power spectrum :math:`P(k)` by :math:`|\tilde{\Psi}(\mathbf{k})|^2 = P(k)/k^2`. The peculiar velocity is :math:`\mathbf{v} = \dot{D}_+ \boldsymbol{\Psi}`, with :math:`\dot{D}_+ = H f D_+` where :math:`f \approx \Omega_m^{0.55}` is the growth rate.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_flrwpspec.f90`` for the complete source.
