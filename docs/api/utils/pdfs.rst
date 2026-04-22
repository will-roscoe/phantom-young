.. phantom-doc: hand-written

pdfs
====

Overview
--------

``pdfs`` is a module providing routines for computing and writing probability density functions from arrays of values. It is used by ``analysis_MWpdf``, ``grid2pdf``, and other utilities to bin scalar quantities (typically the logarithm of density) into a normalised histogram.

The ``get_pdf`` routine takes an array of particle or cell values ``xpart``, the number of bins ``nbins``, and the range ``[xmin, xmax]``, and returns the bin centres ``xbin`` and the normalised PDF values. Binning is in log-space by default (``logx = .true.``) unless switched off. The ``write_pdf`` routine writes the result to an ASCII file with appropriate headers.

Both the mass-weighted and volume-weighted PDFs of the log density :math:`s = \ln(\rho/\bar{\rho})` can be constructed using this module, by supplying either the mass-weighted or cell-volume-weighted values of :math:`s` as input.

Physical & Mathematical Description
------------------------------------

The PDF bin at :math:`s_k` contains the fraction of total weight in the interval :math:`[s_k, s_k + \Delta s]`: :math:`p(s_k) = \sum_{i: s_i \in [s_k, s_k+\Delta s]} w_i / (W_\mathrm{tot} \Delta s)`, where :math:`w_i` is either the particle mass (mass-weighted PDF) or the volume element (volume-weighted PDF). The output is normalised so that :math:`\int p(s) \, ds = 1`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/pdfs.f90
