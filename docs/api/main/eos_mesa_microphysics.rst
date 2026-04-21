.. phantom-doc: hand-written

eos_mesa_microphysics — MESA Microphysics Table Engine
======================================================

Overview
--------

The ``mesa_microphysics`` module is the low-level engine that reads, stores, and
interpolates the MESA equation-of-state and opacity tables used by the Phantom EOS
(``ieos = 10``) and the radiation-transport opacity module (``iopacity_type = 1``).
It is declared entirely ``public`` and acts as a shared data store: all table
arrays are allocated here and accessed directly by the higher-level ``eos_mesa``
and opacity modules.

The EOS tables are indexed on a uniform grid in :math:`(\log_{10}\varepsilon,
\log_{10}V)` — where :math:`\varepsilon` is the specific internal energy and
:math:`V = 1/\rho` is the specific volume — for each combination of hydrogen
mass fraction :math:`X` and metallicity :math:`Z` on a coarse composition grid.
Opacity tables are indexed on a :math:`(R, T)` grid (where :math:`R =
\rho/T_6^3` in the standard OPAL parameterisation) and stored similarly.

Both EOS and opacity tables are distributed as binary datafiles in the
``eos/mesa`` and ``eos/mesa`` (``opacs``) subdirectories of the Phantom data
repository.  Paths are resolved at run time using the ``find_phantom_datafile``
utility in the ``datafiles`` module, and the location can be overridden by the
``MESA_DATA_DIR`` environment variable.

Physical & Mathematical Description
-------------------------------------

**EOS table layout.**  The EOS data for each :math:`(X, Z)` pair are tabulated on
a uniform grid

.. math::

   \log_{10}\varepsilon_k = \varepsilon_1 + (k-1)\,\Delta\varepsilon, \quad k = 1,\ldots,N_\varepsilon

   \log_{10}V_j = V_1 + (j-1)\,\Delta V, \quad j = 1,\ldots,N_V

At each grid point the following quantities are stored: pressure :math:`P`,
temperature :math:`T`, entropy :math:`s`, :math:`\Gamma_1`, and their first
derivatives with respect to the table variables.  Bicubic spline coefficients
are precomputed and stored for efficient two-dimensional interpolation.

**Opacity table layout.**  The Rosseland-mean opacity :math:`\kappa_R(\rho, T)` is
tabulated on a grid :math:`(R_i, T_j)` where :math:`R \equiv \rho/T_6^3` (CGS,
:math:`T_6 = T/10^6\ \mathrm{K}`).  The module stores derivatives
:math:`\kappa_\rho` and :math:`\kappa_T` for interpolation.

**Interpolation.**  ``getvalue_mesa`` performs bilinear (or bicubic) interpolation
in :math:`(\log_{10}\rho, \log_{10}\varepsilon)` space, with linear interpolation
in :math:`X` and :math:`Z` between table entries, via ``eos_cubic_spline_mesa``
and ``cubic_spline_mesa``.

Derivations
-----------

The cubic-spline interpolation scheme used is the standard one-dimensional natural
cubic spline applied successively along each table axis.  For a function
:math:`f(x)` tabulated at :math:`\{x_i\}` the interpolant in interval
:math:`[x_i, x_{i+1}]` is:

.. math::

   f(x) = a_i + b_i(x - x_i) + c_i(x - x_i)^2 + d_i(x - x_i)^3

with coefficients :math:`\{a_i, b_i, c_i, d_i\}` determined by continuity of
:math:`f`, :math:`f'`, and :math:`f''` at the knots.  The two-dimensional
extension evaluates the one-dimensional spline along one axis at each grid line
and then splines the resulting values along the other axis.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Paxton, B. et al. 2011, ApJS, 192, 3 — MESA I: tables and microphysics
- Paxton, B. et al. 2013, ApJS, 208, 4 — MESA II
- Paxton, B. et al. 2015, ApJS, 220, 15 — MESA III

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_mesa_microphysics.f90
=====================

Overview
--------

.. todo:: Add overview narrative.

Physical & Mathematical Description
-------------------------------------

.. todo:: Add mathematical description with ``.. math::`` blocks.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_mesa_microphysics.f90
