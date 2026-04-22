.. phantom-doc: hand-written

radiation_utils — Radiation Utility Routines
=============================================

Overview
--------

The ``radiation_utils`` module provides the foundational utility routines shared
across all radiation-related modules in Phantom.  It handles runtime configuration
of the radiation solver, opacity evaluation, gas–radiation energy exchange, and
the set of conversion functions between radiation energy density, radiation
temperature, gas internal energy, and gas temperature.  The module is the single
authoritative source for the parameters ``tol_rad``, ``itsmax_rad``, ``cv_type``,
``kappa_cgs``, and the logical flags that govern solver behaviour.

Three opacity types are supported, selected by the integer ``iopacity_type``:
type 0 sets :math:`\kappa` to a large sentinel value (effectively infinite opacity,
diffusion limit everywhere); type 1 looks up the Rosseland mean from MESA
microphysics tables as a function of density and temperature; type 2 uses a
user-specified constant value ``kappa_cgs`` in CGS units.  The special value
:math:`-1` is accepted as a directive to leave the existing opacity unchanged.
Similarly, ``cv_type`` selects the specific-heat prescription: 0 uses a
constant ideal-gas :math:`c_v`, while 1 queries MESA for a composition- and
temperature-dependent value.

The module's primary physics routine, ``update_radenergy``, performs a
fully implicit backward-Euler update of the gas–radiation energy exchange
for all SPH particles over a substep.  Several alternative integrators
(explicit Euler, explicit substeps, implicit substeps) are also provided
for testing and comparison.  The flux-limiter flag ``limit_radiation_flux``
controls whether the dimensionless ratio :math:`R` is computed and passed to
the Levermore–Pomraning limiter in the implicit solver; when disabled,
:math:`R = 0` and the diffusion coefficient reduces to :math:`\lambda = 1/3`.

Conversion utilities cover the full chain: radiation temperature to specific
radiation energy density (``radxi_from_Trad``), the inverse (``Trad_from_radxi``),
gas temperature to specific internal energy (``ugas_from_Tgas``), and its
inverse (``Tgas_from_ugas``).  A convenience routine
``set_radiation_and_gas_temperature_equal`` initialises the radiation field by
setting the radiation temperature equal to the gas temperature at each particle,
which is the standard starting condition for collapse calculations.

Physical & Mathematical Description
-------------------------------------

**Radiation equation of state.**  The radiation pressure is related to the
specific radiation energy by

.. math::

   P_{\rm rad} = \frac{1}{3}\,\rho\,\xi

where :math:`\xi` is the specific radiation energy density (energy per unit mass)
and :math:`\rho\xi = E` is the radiation energy density (energy per unit volume).
This is the isotropic (optically thick) limit of the full Eddington tensor.

**Radiation energy density and temperature.**  The equilibrium radiation energy
density equals the blackbody energy density:

.. math::

   E_{\rm rad} = a_{\rm rad}\,T_{\rm rad}^4

Hence the specific radiation energy and the radiation temperature are related by

.. math::

   \xi = \frac{a_{\rm rad}\,T_{\rm rad}^4}{\rho},
   \qquad
   T_{\rm rad} = \left(\frac{\rho\,\xi}{a_{\rm rad}}\right)^{1/4}.

**Gas internal energy and temperature.**  For an ideal gas with mean molecular
weight :math:`\mu` and adiabatic index :math:`\gamma`:

.. math::

   c_v = \frac{(\gamma - 1)\,\mu\,R_g}{\mathcal{R}},
   \qquad
   u = \frac{T_{\rm gas}}{c_v}

where :math:`\mathcal{R}` is the universal gas constant.  In code units the
conversion includes the factor ``unit_ergg``.

**Gas–radiation energy exchange.**  The energy exchange rate per unit volume
between gas and radiation is

.. math::

   \dot{q}_{\rm exch} = c\,\kappa\,\rho
   \left(a_{\rm rad}\,T_{\rm gas}^4 - E_{\rm rad}\right)

where :math:`c` is the speed of light and :math:`\kappa` is the opacity.  The
implicit backward-Euler update for the gas internal energy satisfies

.. math::

   u^{n+1} - u^n - \Delta t\,\dot{u}_{\rm hydro}
   = \Delta t\,c\kappa\!
   \left(\frac{\rho\,(e_{\rm tot} - u^{n+1})}{a_{\rm rad}}
   - \left(c_v\,u^{n+1}\right)^4\right)

where :math:`e_{\rm tot} = u^n + \xi^n` is the conserved total specific energy.
Newton–Raphson iteration (up to 10 steps) is used to solve this nonlinear
equation for :math:`u^{n+1}`.

**Dimensionless radiation-pressure ratio.**  The ratio

.. math::

   R = \frac{|\nabla(\rho\xi)|}{\kappa\,\rho^2\,\xi}

characterises the transition from diffusion (:math:`R \ll 1`) to free-streaming
(:math:`R \gg 1`) and is used as the argument of the Levermore–Pomraning flux
limiter in the implicit solver.

**Opacity models.** The supported models are:

.. list-table::
   :header-rows: 1
   :widths: 15 20 65

   * - ``iopacity_type``
     - Name
     - Description
   * - 0
     - Infinite opacity
     - :math:`\kappa = +\infty` (diffusion limit everywhere; no radiation transport)
   * - 1
     - MESA table
     - Rosseland mean :math:`\kappa(\rho, T)` from MESA microphysics tables
   * - 2
     - Constant
     - :math:`\kappa = \kappa_{\rm cgs}` (user-specified constant in cm\ :sup:`2` g\ :sup:`-1`)
   * - -1
     - Preserve
     - Leave existing opacity unchanged

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Symbol
     - Definition
   * - :math:`\xi`
     - Specific radiation energy density (radiation energy per unit mass)
   * - :math:`E = \rho\xi`
     - Radiation energy density (energy per unit volume)
   * - :math:`\kappa`
     - Rosseland mean opacity (cm\ :sup:`2` g\ :sup:`-1`)
   * - :math:`c_v`
     - Specific heat at constant volume
   * - :math:`a_{\rm rad}`
     - Radiation constant (:math:`7.565\times 10^{-15}` erg cm\ :sup:`-3` K\ :sup:`-4`)
   * - :math:`T_{\rm rad}`
     - Radiation temperature
   * - :math:`T_{\rm gas}`
     - Gas temperature
   * - :math:`R`
     - Dimensionless flux ratio for the Levermore–Pomraning limiter

References
----------

The radiation utility routines support the implicit FLD solver described in:

- Whitehouse, S. C., Bate, M. R. & Monaghan, J. J. 2005, MNRAS, 364, 1367 — implicit
  FLD scheme for which this module provides configuration and auxiliary functions
- Whitehouse, S. C. & Bate, M. R. 2004, MNRAS, 353, 1078 — flux-limiter and
  Eddington factor definitions used in ``get_rad_R``
- Bate, M. R. & Keto, E. R. 2015, MNRAS, 449, 2643 — updated FLD implementation
  motivating the MESA opacity and :math:`c_v` options

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/radiation_utils.f90
