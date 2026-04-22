.. phantom-doc: hand-written

leastsquares
============

Overview
--------

``leastsquares`` provides a routine for fitting a linear function :math:`y = a + b x` to data by least squares, optionally in log-log space (for power-law fitting) and with optional range restrictions. The module is used by ``get_struct_slope`` and ``analysis_dustydisc`` for fitting power-law slopes to turbulence structure functions and disc surface density profiles.

The ``fit_slope`` routine accepts ``nvals`` data points :math:`(x_i, y_i)`, optional ``xmin``/``xmax`` range limits, an optional ``logplot`` flag (to fit in log-log space), and an optional ``fixslope`` flag (to fit only the intercept). It returns the slope :math:`b`, intercept :math:`a`, RMS residual error, and individual slope and intercept uncertainties.

The fitting is done by direct solution of the 2x2 normal equations, without matrix inversion, making it efficient for the small data sets typically encountered in structure function fitting.

Physical & Mathematical Description
------------------------------------

The least-squares slope and intercept are obtained by minimising :math:`\chi^2 = \sum_i (y_i - a - b x_i)^2`, giving the normal equations :math:`b = (n \sum x_i y_i - \sum x_i \sum y_i) / (n \sum x_i^2 - (\sum x_i)^2)` and :math:`a = (\sum y_i - b \sum x_i) / n`. The slope error is :math:`\sigma_b^2 = n \sigma_y^2 / (n \sum x_i^2 - (\sum x_i)^2)` where :math:`\sigma_y^2 = \chi^2_\mathrm{min} / (n-2)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/leastsquares.f90
