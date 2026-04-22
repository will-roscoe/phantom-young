.. phantom-doc: hand-written

analysis_MWpdf
==============

Overview
--------

``analysis_MWpdf`` computes the mass-weighted probability density function (PDF) of the gas density from SPH particle data. Unlike volume-weighted PDFs (which require SPH-to-grid interpolation), the mass-weighted PDF is directly obtained by assigning each particle a contribution proportional to its mass, making it straightforward to compute from the particle data.

The routine uses ``get_pdf`` and ``write_pdf`` from the ``pdfs`` module to bin the density values into logarithmically spaced bins between ``rhologmin`` and ``rhologmax``, and writes the PDF to a file at each dump. The root-mean-square Mach number is also computed from the velocity dispersion.

The mass-weighted density PDF is a key diagnostic for supersonic turbulence, exhibiting a log-normal distribution with variance :math:`\sigma_s^2 = \ln(1 + b^2 \mathcal{M}^2)` that encodes the turbulent Mach number :math:`\mathcal{M}` and driving parameter :math:`b`.

Physical & Mathematical Description
------------------------------------

The mass-weighted PDF is :math:`p_m(s) ds = \sum_{i: s_i \in [s, s+ds]} m_i / M_\mathrm{tot}`, where :math:`s = \ln(\rho / \bar{\rho})` is the logarithmic density contrast. For driven supersonic turbulence the PDF is well described by the log-normal :math:`p_m(s) = (2\pi \sigma_s^2)^{-1/2} \exp[-(s - s_0)^2 / (2 \sigma_s^2)]` with :math:`s_0 = -\sigma_s^2 / 2`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_MWpdf.f90`` for the complete source.
