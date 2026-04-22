.. phantom-doc: hand-written

eos_gasradrec — Gas + Radiation + Recombination Equation of State
=================================================================

Overview
--------

The ``eos_gasradrec`` module implements the equation of state from the HORMONE code
(Hirai et al. 2020), which accounts for the internal energy contributions of an
ideal gas, radiation, and the recombination of molecular hydrogen (H\ :sub:`2`),
atomic hydrogen (H), and helium (He).  This EOS is suited to stellar evolution and
common-envelope calculations, where the energy released by recombination as gas
expands can drive outflows and significantly alter the outcome of mass-transfer
episodes.

This EOS is selected via ``ieos = 20`` in the Phantom input file.  Ionisation and
dissociation fractions are computed by the companion module ``ionization_mod``, which
provides tabulated recombination energies and the effective specific heat at constant
volume :math:`c_{v,\rm eff}` as functions of density, temperature, and composition.
The ``irecomb`` runtime parameter controls which recombination channels are active:
all (H\ :sub:`2` + H + He), H and He only, He only, or none.

Within the simulation pipeline the module is called from ``equationofstate`` in
:doc:`eos` (``ieos = 20``).  It is also used by the stellar structure analysis
routines and by the entropy and specific-heat query functions in the master EOS
module.  Radiation transport via the ``do_radiation`` flag may suppress the
radiation-pressure contribution so that it is not double-counted when a separate
radiation-hydrodynamics module handles that term.

Physical & Mathematical Description
-------------------------------------

The total internal energy per unit volume is

.. math::

   e_{\rm int} = \rho\!\left[R_g\,c_{v,\rm eff}(T)\,T + e_{\rm rec}(\rho, T)\right]
               + a_{\rm rad}\,T^4

where :math:`R_g` is the gas constant, :math:`c_{v,\rm eff}` is the effective
specific heat (incorporating partial ionisation), :math:`e_{\rm rec}` is the
recombination energy per unit mass, and :math:`a_{\rm rad}` is the radiation
constant.  When ``do_radiation = .true.`` the radiation term is omitted (it is
handled separately), giving

.. math::

   e_{\rm int} = \rho\!\left[R_g\,c_{v,\rm eff}(T)\,T + e_{\rm rec}(\rho, T)\right].

The pressure is

.. math::

   P =
   \begin{cases}
     \left(R_g\,\mu^{-1}(\rho,T)\,\rho + \dfrac{a_{\rm rad}\,T^3}{3}\right)T
     & \text{(radiation included)}\\[8pt]
     R_g\,\mu^{-1}(\rho,T)\,\rho\,T
     & \text{(radiation excluded)}
   \end{cases}

where :math:`\mu^{-1}(\rho,T)` is the inverse mean molecular weight returned by
``ionization_mod``.

The effective adiabatic index is defined from the sound speed:

.. math::

   \gamma_{\rm eff} = \frac{\rho\,c_s^2}{P}, \qquad
   c_s^2 = R_g\!\left(\mu^{-1} + \frac{\partial\ln\mu^{-1}}{\partial\ln\rho}\right)T
         + \frac{\left[R_g\!\left(\mu^{-1}
           + \frac{\partial\ln\mu^{-1}}{\partial\ln T}\right)\right]^2 T}
                {R_g\!\left(c_{v,\rm eff} + \frac{\partial c_{v,\rm eff}}{\partial\ln T}\right)
                 + \frac{\partial e_{\rm rec}}{\partial T}}

(radiation-excluded form; additional :math:`\partial P_{\rm rad}/\partial T` terms
appear in the radiation-included case).

Derivations
-----------

**Temperature iteration.**  Given :math:`(\rho, e_{\rm int})`, the temperature is
found by a Newton–Raphson-like iterator with a Wisdom–Wisdom-4 (W4) step-size
control.  Let

.. math::

   f(T) = e_{\rm int} - \rho\!\left[R_g\,c_{v,\rm eff}\,T + e_{\rm rec}\right] - a_{\rm rad}\,T^4.

The Newton correction is :math:`\delta T = -f(T)/f'(T)`.  When
:math:`|\delta T| > 0.01\,T`, a second-order accelerated scheme is used:

.. math::

   T_{n+1} = T_n + \dot{T}_n\,\Delta t, \qquad
   \dot{T}_{n+1} = (1 - 2\Delta t)\,\dot{T}_n - \Delta t\,\delta T_n,

with :math:`\Delta t = 0.9` initially, reducing to 0.5 after 50 iterations and
0.25 after 100.  A guard is applied to prevent the temperature increasing by more
than a factor of ten in a single step.

**Pressure from density and temperature.**  ``calc_uT_from_rhoP_gasradrec``
inverts the pressure relation to find :math:`T` given :math:`(\rho, P)` using the
same W4 iterator, then calls ``calc_uP_from_rhoT_gasradrec`` to obtain :math:`u`
and :math:`\mu`.

References
----------

The HORMONE EoS is described in detail in Appendix C of Hirai et al. (2020).

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Hirai, R., Müller, B., Laplace, E. & Heger, A. 2020, MNRAS, 499, 1154 — HORMONE gas+radiation+recombination EoS (Appendix C)
- Lau, M. Y. M. et al. 2022, MNRAS, 512, 5462 — application of the HORMONE EoS in Phantom common-envelope simulations

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_gasradrec.f90
