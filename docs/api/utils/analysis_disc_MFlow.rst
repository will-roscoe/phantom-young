.. phantom-doc: hand-written

analysis_disc_MFlow
===================

Overview
--------

``analysis_disc_MFlow`` computes the radial mass flow rate through a disc as a function of radius, providing a measure of the disc accretion rate :math:`\dot{M}(R)` at each radial bin. It uses ``nr = 400`` radial bins spanning ``rmin`` to ``rmax`` and is implemented using the ``discanalysisutils`` module.

The routine measures the radial velocity component :math:`v_r` for particles in each annulus and multiplies by the surface density to obtain the accretion rate profile. This enables identification of regions where the disc accretes or outflows, and comparison with the viscous evolution expected from the :math:`\alpha`-disc model.

Output files record the radial mass flux profile at each dump, allowing the disc accretion rate to be tracked as a function of time and position.

Physical & Mathematical Description
------------------------------------

The local radial mass flux through an annulus of width :math:`\Delta R` is :math:`\dot{M}(R) = 2\pi R \Sigma(R) v_r(R)`, where :math:`v_r` is the mass-weighted mean radial velocity in the bin and :math:`\Sigma` is the surface density. For a steady-state viscous disc, :math:`\dot{M}` is independent of radius except near boundaries.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_disc_MFlow.f90`` for the complete source.
