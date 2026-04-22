.. phantom-doc: hand-written

get_struct_slope
================

Overview
--------

``get_struct_slope`` is a command-line utility that reads a structure function file (in ``.sfn``, ``.struct``, or ``_sf_*.dat`` format) and fits a power-law slope to each order of the longitudinal and transverse velocity structure functions over a user-specified lag range. It uses the least-squares fitting routine from the ``leastsquares`` module.

The program reads the structure function data via ``read_structurefn`` from ``io_structurefn``, then calls ``fit_slope`` to fit the function :math:`\log S_p(\ell) = p_0 + \zeta_p \log \ell` over the fitting range :math:`[\ell_\mathrm{min}, \ell_\mathrm{max}]`. Results are written to an output file recording the scaling exponent :math:`\zeta_p` and its statistical error for each order :math:`p`.

The scaling exponents :math:`\zeta_p` characterise intermittency in turbulence: for Kolmogorov turbulence :math:`\zeta_p = p/3`, while the She-Leveque model gives :math:`\zeta_p = p/9 + 2[1 - (2/3)^{p/3}]`.

Physical & Mathematical Description
------------------------------------

The :math:`p`-th order structure function scaling exponent is fitted as :math:`\zeta_p` in :math:`S_p(\ell) \propto \ell^{\zeta_p}`. The least-squares fit minimises :math:`\chi^2 = \sum_{k: \ell_k \in [\ell_\mathrm{min}, \ell_\mathrm{max}]} [\log S_p(\ell_k) - (p_0 + \zeta_p \log \ell_k)]^2` over the fitting range, with error estimates from the diagonal of the normal equations matrix inverse.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/get_struct_slope.f90
