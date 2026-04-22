.. phantom-doc: hand-written

grid2pdf
========

Overview
--------

``grid2pdf`` converts a 3D density (and velocity) grid stored in various file formats (ASCII, binary, HDF5, stream) into a probability density function. It reads the grid using ``io_grid``, extracts the density column, and computes both the volume-weighted PDF and various turbulence statistics including the RMS Mach number and log-density variance.

The program delegates PDF computation to ``pdf_calc`` and ``pdf_write`` from the ``pdfs`` module, and turbulence statistics to ``get_rhomach_grid`` and ``write_rhomach`` from the ``rhomach`` module. The output ``pdf.dat`` file contains the binned log-density PDF normalised to unit integral, suitable for comparison with analytic log-normal models.

Usage is ``grid2pdf format filename(s)``, where ``format`` specifies the grid file format. Multiple files can be processed in sequence, with output files indexed accordingly.

Physical & Mathematical Description
------------------------------------

The volume-weighted log-density PDF is :math:`p_V(s) = \int \delta[s - \ln(\rho/\bar{\rho})] \, dV / V`, discretised as :math:`p_V(s_k) = N_k V_\mathrm{cell} / (V_\mathrm{tot} \Delta s)` where :math:`N_k` is the number of cells with :math:`\ln(\rho/\bar{\rho}) \in [s_k, s_k + \Delta s]`. For driven supersonic isothermal turbulence the variance of the log-normal PDF satisfies :math:`\sigma_s^2 = \ln(1 + b^2 \mathcal{M}^2)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/grid2pdf.f90
