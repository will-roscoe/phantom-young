.. phantom-doc: hand-written

analysis_gws
============

Overview
--------

``analysis_gws`` computes the gravitational wave (GW) strain from a Phantom simulation in post-processing. It calls ``derivs`` to recompute accelerations at each dump, then uses ``calculate_strain`` from the ``gravwaveutils`` module to evaluate the quadrupole GW signal for all particle configurations.

The routine reads the Phantom input file to initialise external forces and units correctly, then loops over all dump files computing the GW strain tensor components :math:`h_+` and :math:`h_\times` projected along a user-specified line of sight. Output is written to a time series enabling direct comparison with gravitational wave detectors such as LIGO/Virgo.

This analysis is widely used in neutron star merger, common envelope, and binary white dwarf simulations to predict the GW signal from SPH simulations.

Physical & Mathematical Description
------------------------------------

The quadrupole gravitational wave strain at distance :math:`d` is :math:`h_{ij} = \frac{2G}{c^4 d} \ddot{I}_{ij}^\mathrm{TT}`, where :math:`I_{ij} = \sum_k m_k r_{k,i} r_{k,j}` is the mass quadrupole tensor and the superscript TT denotes the transverse-traceless projection. The :math:`+` and :math:`\times` polarisations are the two independent degrees of freedom of the TT tensor.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_gws.f90`` for the complete source.
