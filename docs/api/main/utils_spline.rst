.. phantom-doc: hand-written

utils_spline
============

Overview
--------

The ``splineutils`` module provides routines for fitting and evaluating
cubic splines to tabulated data. It was originally written by Simon Glover
and translated to Fortran 90 by Daniel Price for use in Phantom's cooling
and opacity table interpolation. The public routine ``spline_eval`` accepts
a set of :math:`n` data points :math:`(x_k, y_k)`, fits a natural cubic
spline to them, and evaluates the spline at a set of :math:`m` new abscissae,
returning the interpolated values.

Natural boundary conditions are used (second derivative = 0 at both
endpoints), which minimises the total curvature of the spline and avoids
unphysical oscillations near the endpoints. This is the standard choice for
interpolating smooth physical functions such as cooling curves, opacity
tables, and equation-of-state tables.

Physical & Mathematical Description
------------------------------------

A natural cubic spline through :math:`n` points satisfies the tridiagonal
linear system for the second derivatives :math:`y''_k`:

.. math::

   h_{k-1} y''_{k-1} + 2(h_{k-1}+h_k) y''_k + h_k y''_{k+1}
   = 6\!\left(\frac{y_{k+1}-y_k}{h_k} - \frac{y_k - y_{k-1}}{h_{k-1}}\right),

where :math:`h_k = x_{k+1} - x_k`. Once the :math:`y''_k` are known, the
spline is evaluated on each interval by the standard cubic formula. The
system is solved by Gaussian elimination in :math:`O(n)` operations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_spline.f90
