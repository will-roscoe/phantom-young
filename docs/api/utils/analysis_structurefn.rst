.. phantom-doc: hand-written

analysis_structurefn
====================

Overview
--------

``analysis_structurefn`` computes velocity structure functions directly from SPH particle data, using the ``structurefn_part`` module. Structure functions are statistical measures of velocity correlations at different separation scales and are fundamental diagnostics of turbulence.

The routine computes the :math:`p`-th order structure function :math:`S_p(\ell) = \langle |\Delta v|^p \rangle` for ``norder = 10`` orders and ``nbins = 1024`` logarithmic lag bins, with separate longitudinal and transverse components. Results are written using the ``io_structurefn`` module which supports multiple file formats.

Structure functions characterise the scaling properties of turbulence: for Kolmogorov turbulence the second-order structure function scales as :math:`S_2(\ell) \propto \ell^{2/3}`, while supersonic turbulence shows steeper scaling.

Physical & Mathematical Description
------------------------------------

The :math:`p`-th order longitudinal velocity structure function is :math:`S_p^L(\ell) = \langle |\delta v_L(\ell)|^p \rangle`, where :math:`\delta v_L = (\mathbf{v}_i - \mathbf{v}_j) \cdot \hat{\mathbf{r}}_{ij}` is the longitudinal velocity difference at separation :math:`\ell = |\mathbf{r}_{ij}|`. The transverse component uses the velocity component perpendicular to :math:`\hat{\mathbf{r}}_{ij}`. Averaging is over random particle pairs in the lag bin :math:`\ell \in [\ell_k, \ell_k + \Delta\ell]`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_structurefn.f90`` for the complete source.
