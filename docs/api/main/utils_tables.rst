.. phantom-doc: hand-written

utils_tables
============

Overview
--------

The ``table_utils`` module provides low-level utilities for working with
tabulated one-dimensional data in Phantom. It supports linear interpolation,
the construction of uniformly spaced (``linspace``) and logarithmically
spaced (``logspace``) grids, finite-difference differentiation
(``differentiate``), array operations (``diff``, ``flip_array``), and
several interpolation interfaces of varying generality
(``yinterp``, ``interp_1d``, ``linear_interpolator_one_d``,
``interpolate_1d``, ``interpolator``).

The module is used throughout Phantom wherever tabulated data must be
interpolated at runtime: opacity tables, equation-of-state tables,
cooling functions, stellar wind profiles, and dust properties. The
``find_nearest_index`` subroutine performs a binary search on a sorted
array to find the bracketing index for a query value.

Physical & Mathematical Description
------------------------------------

The core interpolation function ``yinterp`` performs piecewise linear
interpolation: given a query :math:`x` and tabulated arrays ``xtab`` and
``ytab``, it finds the interval :math:`[x_k, x_{k+1}]` containing :math:`x`
by binary search and evaluates

.. math::

   y(x) = y_k + (x - x_k) \frac{y_{k+1} - y_k}{x_{k+1} - x_k}.

Extrapolation beyond the table bounds returns the endpoint values. The
``differentiate`` routine computes numerical first derivatives using
second-order central differences in the interior and first-order forward
or backward differences at the endpoints.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_tables.f90
