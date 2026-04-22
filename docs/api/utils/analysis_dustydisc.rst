.. phantom-doc: hand-written

analysis_dustydisc
==================

Overview
--------

``analysis_dustydisc`` is a comprehensive post-processing routine for dusty protoplanetary disc simulations, maintained by Mark Hutchison. It computes radial profiles of both gas and dust quantities in ``nr = 50`` annuli, including surface density for each dust species, the dust-to-gas ratio, scale height, angular momentum, tilt, twist, and drift velocities.

The routine uses the least-squares and linear system solvers from the ``leastsquares`` and ``solvelinearsystem`` modules to fit power-law profiles to the radial surface density data. Grain size information is read from the ``dust`` module (``grainsizecgs``), and dust settling diagnostics are computed for each grain species separately.

Output files are labelled with column descriptions for up to ``maxdusttypes`` dust species, providing a complete structural picture of the multi-species dusty disc at each dump.

Physical & Mathematical Description
------------------------------------

The dust settling scale height for grain species :math:`k` is :math:`H_{d,k} = H_g / \sqrt{1 + \mathrm{St}_k / \alpha_\mathrm{turb}}`, where the Stokes number :math:`\mathrm{St}_k = \pi \rho_\mathrm{grain} s_k / (2 \Sigma_g)`, :math:`s_k` is the grain radius, and :math:`\alpha_\mathrm{turb}` is the turbulent viscosity parameter. The radial drift velocity of species :math:`k` is :math:`v_{r,k} = -2 \mathrm{St}_k \eta v_K / (1 + \mathrm{St}_k^2)`, where :math:`\eta v_K` is the sub-Keplerian lag.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_dustydisc.f90`` for the complete source.
