.. phantom-doc: hand-written

eos — Master Equation-of-State Dispatcher
==========================================

Overview
--------

The ``eos`` module is the central equation-of-state (EOS) dispatcher for the Phantom
smoothed particle hydrodynamics code.  It provides a single unified interface —
``equationofstate`` — through which every other module in the code requests
thermodynamic state information for a fluid particle.  Given a density, position,
and (where applicable) a specific internal energy or temperature, the routine returns
the pressure-to-density ratio :math:`P/\rho`, the adiabatic sound speed :math:`c_s`,
and the temperature.  All other EOS-related diagnostics (mean molecular weight,
effective adiabatic index :math:`\gamma`, entropy, specific heat) are also routed
through wrapper functions defined here.

The module supports twenty-two distinct EOS choices, selectable at run time via the
integer parameter ``ieos``.  These range from simple analytic prescriptions
(isothermal, polytropic) to fully tabulated microphysical equations of state for
stellar interiors and nuclear matter.  Two choices (``ieos = 18, 19``) are reserved
but not implemented.  Options ``ieos = 21`` and ``ieos = 22`` implement the HII-region
two-temperature prescription from :doc:`eos_HIIR`.  The module manages initialisation
and finalisation of all EOS sub-modules, reads and writes runtime parameters to input
files, and persists header quantities (``gamma``, ``polyk``, ``qfacdisc``) in dump-file
headers for reproducibility.

Within the simulation pipeline, ``equationofstate`` is called by the force-evaluation
kernel, by the energy-equation integrator, and by any analysis routine that requires
thermodynamic quantities not stored directly in the dump file.  The module depends on all
specialised EOS sub-modules: :doc:`eos_barotropic`, :doc:`eos_gasradrec`,
:doc:`eos_helmholtz`, :doc:`eos_idealplusrad`, :doc:`eos_mesa`, :doc:`eos_piecewise`,
:doc:`eos_shen`, :doc:`eos_stamatellos`, :doc:`eos_stratified`, :doc:`eos_tillotson`,
and :doc:`eos_HIIR`.

The module also exposes entropy functions, an entropy-based density inversion
(``get_rho_from_p_s``), a Newton–Raphson pressure solver (``get_p_from_rho_s``), and
query predicates (``eos_is_non_ideal``, ``eos_outputs_mu``, ``eos_requires_isothermal``,
etc.) that allow higher-level code to adapt its behaviour according to the active EOS
without duplicating the selection logic.

Physical & Mathematical Description
-------------------------------------

The fundamental output of ``equationofstate`` is the dimensionless ratio
:math:`P/\rho` and the adiabatic sound speed

.. math::

   c_s = \sqrt{\left.\frac{\partial P}{\partial\rho}\right|_s}.

A temperature :math:`T` is also returned as a diagnostic.  The governing relations
depend on ``ieos``; all twenty-two options are documented in the table below.

**EOS index summary**

.. list-table::
   :header-rows: 1
   :widths: 6 32 62

   * - ieos
     - Name
     - Governing relation
   * - 1
     - Isothermal
     - :math:`P = c_s^2\,\rho`,  :math:`c_s^2 = K` (constant stored in dump header)
   * - 2
     - Adiabatic / polytropic
     - :math:`P = (\gamma-1)\rho u`; or :math:`P = K\rho^\gamma` when ``ISOTHERMAL=yes``
   * - 3
     - Locally isothermal disc
     - :math:`c_s(r) = c_{s,0}\,r^{-q}`,  :math:`r = |{\bf x}|`  (Lodato & Pringle 2007)
   * - 4
     - GR isothermal (experimental)
     - Constant :math:`u_{\rm th}`: :math:`P = (\gamma-1)\rho u_{\rm th}`
   * - 5
     - Adiabatic, variable :math:`\mu` and :math:`\gamma` (H\ :sub:`2`)
     - :math:`P = (\gamma-1)\rho u`;  :math:`\mu`,  :math:`\gamma` updated for H\ :sub:`2` mass fraction
   * - 6
     - Locally isothermal, sink-centred
     - As ieos=3 but :math:`r` measured from a designated sink particle
   * - 7
     - Vertically stratified disc
     - :math:`c_s(R,z)` with midplane and atmosphere power laws; see :doc:`eos_stratified`
   * - 8
     - Barotropic
     - Piecewise polytrope; isothermal below :math:`\rho_{\rm crit}`, adiabatic above; see :doc:`eos_barotropic`
   * - 9
     - Piecewise polytrope (neutron stars)
     - :math:`P = K_i\rho^{\Gamma_i}` in successive density segments; see :doc:`eos_piecewise`
   * - 10
     - MESA EoS (tabulated)
     - Full stellar thermodynamics from MESA tables; see :doc:`eos_mesa`
   * - 11
     - Isothermal, zero pressure
     - :math:`P = 0` (test-particle dynamics); :math:`c_s = \sqrt{K}`
   * - 12
     - Ideal gas + radiation
     - :math:`P = \frac{\rho k_B T}{\mu m_H} + \frac{aT^4}{3}`;  see :doc:`eos_idealplusrad`
   * - 13
     - Farris et al. (2014) — hierarchical
     - Locally isothermal generalised to :math:`N` sink particles
   * - 14
     - Farris et al. (2014) — binary
     - Locally isothermal for exactly two sink particles
   * - 15
     - Helmholtz free energy
     - Timmes & Swesty (2000) tabulated EoS; see :doc:`eos_helmholtz`
   * - 16
     - Shen nuclear EoS
     - Tabulated nuclear matter (Shen et al. 1998/2011); see :doc:`eos_shen`
   * - 17
     - Adiabatic, variable :math:`\mu` only
     - As ieos=5 without :math:`\gamma` variation
   * - 18–19
     - (not implemented)
     - —
   * - 20
     - Gas + radiation + recombination (HORMONE)
     - Hirai et al. (2020); see :doc:`eos_gasradrec`
   * - 21
     - HII region isothermal
     - :math:`c_s` switched on ionisation flag; see :doc:`eos_HIIR`
   * - 22
     - HII region adiabatic
     - As ieos=21 with stored :math:`u`; see :doc:`eos_HIIR`
   * - 23
     - Tillotson EoS
     - Shock physics for solids/fluids; see :doc:`eos_tillotson`
   * - 24
     - Tabulated (Lombardi/Stamatellos)
     - Opacity/EoS table for ``icooling=9``; see :doc:`eos_stamatellos`

**Selected governing equations**

*Isothermal (ieos = 1):*

.. math::

   P = c_s^2\,\rho, \qquad c_s^2 \equiv K = \mathrm{const}.

*Adiabatic (ieos = 2, 5, 17):*

.. math::

   P = (\gamma - 1)\,\rho\,u

In the polytropic limit (no stored thermal energy):

.. math::

   P = K\,\rho^\gamma

*Locally isothermal disc (ieos = 3):*

.. math::

   c_s^2(r) = K\,r^{-2q}, \qquad r = \sqrt{x^2 + y^2 + z^2}

*Farris et al. hierarchical (ieos = 13):*

.. math::

   c_s^2 = K\!\left(\frac{\displaystyle\sum_{i=1}^{N_{\rm sink}}
   \frac{M_i}{r_i}}{M_{\rm tot}}\right)^{2q}

where :math:`r_i` is the distance from gas particle to sink :math:`i`.  For
two sinks this reduces identically to the Farris et al. (2014) binary
prescription (ieos = 14).

*Ideal gas + radiation (ieos = 12):*

.. math::

   u = \frac{3}{2}\frac{k_B T}{\mu m_H} + \frac{a T^4}{\rho}, \qquad
   P = \frac{\rho k_B T}{\mu m_H} + \frac{a T^4}{3}

where :math:`a` is the radiation constant.  Given :math:`(\rho, u)`, the
temperature is found by Newton–Raphson iteration on the quartic equation
above; :math:`\gamma_{\rm eff}` is then an output.

*Mean molecular weight (fully ionised plasma):*

.. math::

   \mu = \frac{1}{2X + \tfrac{3}{4}Y + \tfrac{1}{2}Z}

where :math:`X`, :math:`Y = 1 - X - Z`, :math:`Z` are the hydrogen, helium, and
metal mass fractions.

*Entropy:*

Gas only (``ientropy = 1``):

.. math::

   s = \frac{k_B}{\mu m_H}\ln\!\left(\frac{T^{3/2}}{\rho}\right)

Gas plus radiation (``ientropy = 2``):

.. math::

   s = \frac{k_B}{\mu m_H}\ln\!\left(\frac{T^{3/2}}{\rho}\right)
     + \frac{4\,a\,T^3}{3\,\rho}

Derivations
-----------

**Temperature coefficient.**  The conversion from :math:`P/\rho` (code units) to
temperature (K) is

.. math::

   T = \mu \cdot \frac{P}{\rho} \cdot \text{temperature\_coef},
   \qquad
   \text{temperature\_coef} = \frac{v_{\rm unit}^2}{R_g}

where :math:`R_g` is the gas constant in cgs units and :math:`v_{\rm unit}` is the
code velocity unit.  This is set once in ``init_eos`` and does not change
thereafter.

**Entropy-based density inversion.**  ``get_rho_from_p_s`` applies Newton–Raphson
iteration on :math:`\sigma \equiv \sqrt{\rho}` rather than :math:`\rho` directly, to
prevent the logarithm accepting a negative argument during the root search:

.. math::

   \sigma_{n+1} = \sigma_n - \frac{s(\sigma_n^2, P) - s_{\rm target}}
                                  {\mathrm{d}s/\mathrm{d}\sigma}

where the derivative is evaluated by finite differencing.  Convergence is declared
when :math:`|\sigma_{n+1} - \sigma_n| < 10^{-9}|\sigma_n|`.

**Pressure from entropy.**  ``get_p_from_rho_s`` inverts the entropy expression to
obtain pressure.  For the pure ideal-gas case (ieos = 2) this is analytic; for
ieos = 12 (gas + radiation) a Newton–Raphson iteration is performed on temperature,
with the step clamped to :math:`[0.8\,T_n,\,1.2\,T_n]` per iteration to prevent
divergence.

References
----------

The locally isothermal disc prescription (ieos = 3, 6) follows Lodato & Pringle
(2007).  The Farris et al. generalisations (ieos = 13, 14) are from Farris,
Duffell, MacFadyen & Haiman (2014).  The HORMONE gas+radiation+recombination EoS
(ieos = 20) is from Hirai et al. (2020).

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Lodato, G. & Pringle, J. E. 2007, MNRAS, 381, 1287 — locally isothermal disc EoS
- Farris, B. D., Duffell, P., MacFadyen, A. I. & Haiman, Z. 2014, ApJ, 783, 134 — binary/hierarchical locally isothermal
- Hirai, R., Müller, B., Laplace, E. & Heger, A. 2020, MNRAS, 499, 1154 — HORMONE gas+rad+rec EoS
- Timmes, F. X. & Swesty, F. D. 2000, ApJS, 126, 501 — Helmholtz free energy EoS
- Shen, G., Horowitz, C. J. & Teige, S. 2011, Phys. Rev. C, 83, 035802 — nuclear matter EoS table
- Tillotson, J. H. 1962, GA-3216, General Atomic — hypervelocity impact EoS for solids
- Lombardi, J. C. et al. 2015, MNRAS, 447, 25 — tabulated opacity/EoS table for icooling=9

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos.f90
