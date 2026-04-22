.. phantom-doc: hand-written

dust — Gas–Dust Drag
=====================

Overview
--------

The ``dust`` module implements the aerodynamic drag coupling between gas and dust
phases in the Phantom SPH code.  It provides the stopping-time calculation at the
heart of every dust–gas interaction and exposes the auxiliary routines required to
initialise, print, read, and write drag parameters.

The primary public routine, ``get_ts``, computes the local stopping time
:math:`t_s` for a gas–dust particle pair given the local grain size, intrinsic
grain density, gas and dust bulk densities, gas sound speed, and the square of
the differential velocity.  Four drag modes are supported and selected at runtime
via the integer flag ``idrag``: physical Epstein/Stokes drag with automatic
regime switching (``idrag = 1``), a constant drag coefficient :math:`K`
(``idrag = 2``), a constant prescribed stopping time (``idrag = 3``), and
drag disabled entirely (``idrag = 0``).

Regime switching within the physical drag option (``idrag = 1``) is governed by
the effective Knudsen number, derived from the local gas mean free path.  At low
grain Knudsen numbers the code transitions through three Stokes sub-regimes
matched to the local grain Reynolds number.  In the Epstein regime an optional
correction factor for supersonic relative motion following Kwok (1975) is applied
when the differential velocity significantly exceeds the sound speed.

The Ballabio et al. (2018) flux limiter, controlled by the flag
``ilimitdustflux``, suppresses spuriously large dust fluxes at the outer
boundaries of protoplanetary discs when the one-fluid (dust-fraction) formalism
is used.  An implicit time-integration scheme for the drag term is available for
the two-fluid formalism via the ``drag_implicit`` option, subject to the
restriction that individual timesteps (``IND_TIMESTEPS``) must be disabled.

Physical & Mathematical Description
-------------------------------------

**Stopping time.**  In the Epstein regime the drag force per unit mass exerted
on a dust grain moving at velocity :math:`\Delta\mathbf{v}` relative to the gas
is :math:`\mathbf{F}/m = -\Delta\mathbf{v}/t_s`.  The stopping time is

.. math::

   t_s = \frac{1}{C_E\,f(w)\,\rho_\mathrm{sum}},
   \qquad
   C_E = \sqrt{\frac{8}{\pi\gamma}}\,\frac{c_s}{\rho_\mathrm{grain}\,s},

where :math:`s` is the grain radius, :math:`\rho_\mathrm{grain}` the intrinsic
grain density, :math:`c_s` the isothermal sound speed, :math:`\gamma` the
adiabatic index, and
:math:`\rho_\mathrm{sum} = \rho_g + \rho_d` with :math:`\rho_g` and
:math:`\rho_d` the gas and dust bulk densities respectively.

**Kwok (1975) supersonic correction.**  The correction factor :math:`f(w)` for
supersonic drift velocity is

.. math::

   f(w) = \sqrt{1 + \frac{9\pi}{128}\,\frac{|\Delta\mathbf{v}|^2}{c_s^2}}.

The regime is flagged as supersonic (``iregime = 2``) when the Kwok parameter
:math:`9\pi|\Delta v|^2/(128 c_s^2)` exceeds 0.1.

**Regime switching: Epstein vs. Stokes.**  The effective mean free path of the
gas is

.. math::

   \lambda = \frac{\sigma_\mathrm{eff}}{\rho_g},
   \qquad
   \sigma_\mathrm{eff} = \frac{\pi\,m_\mathrm{mol}}{5\sqrt{2}\,\cdot\,
   \tfrac{64}{5}\,\sigma_{\mathrm{H}_2}},

where :math:`m_\mathrm{mol}` is the mean molecular mass of the gas and
:math:`\sigma_{\mathrm{H}_2}` is the H\ :sub:`2` collision cross-section.  The
effective Knudsen number is

.. math::

   K_n = \frac{9\lambda}{4\,s}.

When :math:`K_n \geq 1` the Epstein regime applies; otherwise the grain Reynolds
number

.. math::

   Re = \frac{2\,s\,|\Delta\mathbf{v}|}{\nu_\mathrm{mol}},
   \qquad
   \nu_\mathrm{mol} = \sqrt{\frac{2}{\pi\gamma}}\,\lambda\,c_s,

selects one of three Stokes sub-regimes:

.. list-table::
   :header-rows: 1
   :widths: 16 28 56

   * - ``iregime``
     - Condition
     - Drag coefficient
   * - 3 (Stokes I)
     - :math:`Re \leq 1`
     - :math:`C = 4.5\,\nu_\mathrm{mol}/(\rho_\mathrm{grain}\,s^2)`
   * - 4 (Allen / transitional)
     - :math:`1 < Re \leq 800`
     - :math:`C = 9/(\rho_\mathrm{grain}\,s\,Re^{0.6})`;  :math:`f = |\Delta v|`
   * - 5 (Newton / turbulent)
     - :math:`Re > 800`
     - :math:`C = 0.163/(\rho_\mathrm{grain}\,s)`;  :math:`f = |\Delta v|`

**Constant drag modes.**  For ``idrag = 2`` (constant :math:`K`) the stopping
time is

.. math::

   t_s = \frac{\rho_g\,\rho_d}{K\,(\rho_g + \rho_d)},

with :math:`K` supplied as ``K_code``.  For ``idrag = 3`` the stopping time is
the constant value ``K_code`` itself, independent of local conditions.

References
----------

Laibe, G. & Price, D. J. (2012a), MNRAS 420, 2345 [not yet in phantom.bib]

Laibe, G. & Price, D. J. (2012b), MNRAS 420, 2365 [not yet in phantom.bib]

Kwok, S. (1975), ApJ 198, 583 [not yet in phantom.bib]

Draine, B. T., et al. (2006), ApJ 636, 1114 [not yet in phantom.bib]

Ballabio, G., et al. (2018), MNRAS 477, 2766 [not yet in phantom.bib]

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/dust.f90
