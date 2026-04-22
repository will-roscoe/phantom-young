.. phantom-doc: hand-written

analysis_torus
==============

Overview
--------

``analysis_torus`` analyses the structure of a torus (or thick accretion disc) by binning particles in both cylindrical radius and azimuthal angle :math:`\theta`. Written by Rebecca Nealon, it uses ``nr = 300`` radial bins and ``ntheta = 45`` angular bins to produce 2D profiles of density, velocity, and thermodynamic quantities.

Output files record the azimuthal and radial profiles at each dump (named ``torusNNN_r`` and ``torusNNN_theta``), enabling the structure of the torus to be mapped in both dimensions. The sound speed is computed from the EOS via ``get_spsound``.

This routine is particularly suited to post-processing of tidal disruption event simulations where a thick torus forms around a black hole, and to studies of disc instabilities or jets emerging from a torus.

Physical & Mathematical Description
------------------------------------

A geometrically thick torus is characterised by the ratio :math:`H/R \sim 1`, where :math:`H` is the half-thickness and :math:`R` the cylindrical radius. The pressure profile follows :math:`P \propto \rho^\gamma`, and in the absence of magnetic fields the vertical equilibrium gives :math:`\partial P / \partial z = -\rho \partial \Phi / \partial z`, where :math:`\Phi` is the gravitational potential of the central mass.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_torus.f90`` for the complete source.
