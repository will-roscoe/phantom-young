.. phantom-doc: hand-written

analysis_pdfs
=============

Overview
--------

``analysis_pdfs`` produces accurate volume-weighted probability density functions (PDFs) of gas density (and optionally magnetic energy) from SPH particle data, using interpolation onto an adaptive mesh rather than simple particle counting. Written to exploit the ``adaptivemesh`` module, it achieves much higher accuracy than binning approaches in regions of low particle number.

The routine reads runtime parameters ``rhologmin``, ``rhologmax``, and ``binspacing`` from the parameter file ``analysis_pdfs.params``, which can be created interactively. It builds an AMR mesh using ``build_mesh``, interpolates the density field onto the leaf cells, and then bins the resulting density values into logarithmically spaced PDF bins.

The output file contains the PDF of :math:`\ln \rho / \rho_0` (and optionally :math:`\ln B^2 / B_0^2`), normalised so that the integral over all bins is unity. This is a key diagnostic for turbulence studies.

Physical & Mathematical Description
------------------------------------

The volume-weighted PDF is :math:`p_V(s) = \sum_{\mathrm{cells}} V_\mathrm{cell} \delta(s_\mathrm{cell} - s) / V_\mathrm{tot}`, where :math:`s = \ln(\rho / \bar{\rho})` is the log-density and :math:`s_\mathrm{cell}` is the SPH-interpolated density at each adaptive mesh cell. The AMR interpolation uses the standard SPH kernel sum :math:`\rho(\mathbf{r}) = \sum_j m_j W(|\mathbf{r} - \mathbf{r}_j|, h_j)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_pdfs.f90`` for the complete source.
