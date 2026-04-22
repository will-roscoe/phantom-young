.. phantom-doc: hand-written

utils_gravwave
==============

Overview
--------

``utils_gravwave`` (module ``gravwaveutils``) implements the gravitational wave strain calculation using the quadrupole formula, following the approach of Toscani et al. (2021, arXiv:2111.05145). The main routine ``calculate_strain`` computes the time derivative of the mass quadrupole tensor from the particle accelerations and positions, then projects to the transverse-traceless (TT) gauge to obtain :math:`h_+` and :math:`h_\times`.

The module provides read and write routines for the GW parameters (``read_options_gravitationalwaves``, ``write_options_gravitationalwaves``), enabling the sky direction angles ``theta_gw`` and ``phi_gw`` to be set via the Phantom input file. The helper routine ``get_strain_from_circular_binary`` computes the analytic GW strain for a circular binary, providing a reference solution.

Gravitational wave calculations are activated by setting ``calc_gravitwaves = .true.`` in the input file. The computation assumes a source distance of 1 Mpc and outputs the strain in dimensionless units.

Physical & Mathematical Description
------------------------------------

The quadrupole GW strain at distance :math:`d = 1` Mpc is :math:`h_{jk}^\mathrm{TT} = \frac{2G}{c^4 d} \ddot{I}_{jk}^\mathrm{TT}`, where the reduced quadrupole moment is :math:`I_{jk} = \sum_i m_i (r_{i,j} r_{i,k} - \frac{1}{3} r_i^2 \delta_{jk})`. The second time derivative is computed from particle accelerations via :math:`\ddot{I}_{jk} = 2\sum_i m_i (v_{i,j} v_{i,k} + r_{i,j} a_{i,k})`. The factor :math:`G/dc^4` is returned by ``get_G_on_dc4``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_gravwave.f90
