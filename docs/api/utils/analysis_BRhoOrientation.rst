.. phantom-doc: hand-written

analysis_BRhoOrientation
================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_BRhoOrientation`` computes the orientation between the magnetic field vector :math:`\mathbf{B}` and the density gradient :math:`\nabla \rho` for all SPH particles in a magnetohydrodynamic simulation. Written by Boden Simpson under the guidance of James Wurster, it provides a statistical measure of magnetic field alignment in star-forming regions or turbulent MHD flows.

At each post-processing dump the routine calculates the angle :math:`\theta_{B\rho}` between :math:`\mathbf{B}` and :math:`\nabla \rho` for each particle, using the SPH kernel to estimate the density gradient. The distribution of angles is then written to file, providing information on whether the magnetic field tends to be parallel or perpendicular to density structures.

This analysis is relevant to studies of magnetic support against gravitational collapse, where the relative orientation of :math:`\mathbf{B}` and :math:`\nabla \rho` distinguishes magnetically supercritical from subcritical regions.

Physical & Mathematical Description
------------------------------------

The angle between the magnetic field and the density gradient is :math:`\cos\theta_{B\rho} = (\mathbf{B} \cdot \nabla\rho) / (|\mathbf{B}|\,|\nabla\rho|)`. The density gradient is estimated from the SPH kernel: :math:`\nabla\rho_i = \sum_j m_j \nabla W(|\mathbf{r}_i - \mathbf{r}_j|, h_i)`, with the gradient of the cubic spline kernel :math:`W` evaluated at particle separations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_BRhoOrientation.F90`` for the complete source.
