.. phantom-doc: hand-written

cooling_koyamainutsuka
======================

Overview
--------

The ``cooling_koyamainutsuka`` module implements the two-phase ISM thermal
equilibrium curve of Koyama & Inutsuka (2002). This cooling function is
designed for simulations of the warm and cold neutral ISM, where the balance
between the photoelectric heating rate :math:`\Gamma_\mathrm{KI}` and a
piecewise analytic cooling function :math:`\Lambda_\mathrm{KI}(T)` produces
a bistable thermal structure: a stable warm neutral medium (WNM) at
:math:`T \sim 8000` K and a stable cold neutral medium (CNM) at
:math:`T \sim 60` K, separated by a thermally unstable branch.

Two integration schemes are provided: an explicit rate calculation
(``cooling_KoyamaInutsuka_explicit``, used by ``icooling = 5``) and an
implicit relaxation scheme (``cooling_KoyamaInutsuka_implicit``, used by
``icooling = 6``). Typographical errors in the original Koyama & Inutsuka
(2002) expression are corrected following Vazquez-Semadeni et al. (2007).

Initialisation (``init_cooling_KI02``) builds a table of the thermal
equilibrium temperature as a function of density by solving the balance
equation :math:`n\,\Lambda_\mathrm{KI}(T) = \Gamma_\mathrm{KI}` iteratively
using Newton–Raphson iteration for 1000 logarithmically spaced density values
in the range :math:`10^{-30}` to :math:`10^{-14}` g cm\ :sup:`-3`. This
table is used by the implicit solver to identify the equilibrium internal
energy at a given density. All quantities in the table are converted to code
units on construction.

The sole runtime parameter is the ISM heating rate ``GammaKI_cgs``, with a
default of :math:`2\times10^{-26}` erg s\ :sup:`-1` (per hydrogen atom).

Physical & Mathematical Description
-------------------------------------

The cooling function is the piecewise formula of Koyama & Inutsuka (2002),
with the Vazquez-Semadeni et al. (2007) typographical correction:

.. math::

   \Lambda_\mathrm{KI}(T) = \Gamma_\mathrm{KI}
   \left[10^7\exp\!\left(\frac{-1.184\times10^5}{T+1000}\right)
   + 0.014\,\sqrt{T}\,\exp\!\left(\frac{-92}{T}\right)\right]
   \quad \mathrm{[erg\ cm^3\ s^{-1}]}.

The first term describes cooling in the warm phase (atomic line emission)
and the second describes cooling in the cold phase (fine-structure and
molecular emission).

The net volumetric cooling rate per unit mass is

.. math::

   \dot{u}_\mathrm{cool} = -\frac{n\,\Lambda_\mathrm{KI}(T)}{\rho}
   + \frac{\Gamma_\mathrm{KI}}{m_\mathrm{p}},

where :math:`n = \rho/m_\mathrm{p}` is the hydrogen number density.

In the explicit scheme this rate is evaluated at the current temperature and
directly added to the energy increment.

In the implicit scheme (Vazquez-Semadeni et al. 2007 method), the equilibrium
internal energy :math:`u_\mathrm{eq}(\rho)` is read from the pre-computed
table by linear interpolation. The local cooling timescale is estimated as

.. math::

   \tau^{-1} = \left|\frac{\dot{u}_\mathrm{cool}}{u - u_\mathrm{eq}}\right|,

and the energy is relaxed toward equilibrium as

.. math::

   u(t+\Delta t) = u_\mathrm{eq} + (u - u_\mathrm{eq})\,
   e^{-\Delta t / \tau},

giving the effective rate

.. math::

   \dot{u} = -\frac{u - u(t+\Delta t)}{\Delta t}.

This exponential relaxation is unconditionally stable with respect to the
cooling timescale and correctly reproduces both the WNM and CNM equilibria.

Derivations
-----------

**Construction of the equilibrium table.** Thermal equilibrium requires
:math:`n\,\Lambda_\mathrm{KI}(T_\mathrm{eq}) = \Gamma_\mathrm{KI}`,
i.e.\ :math:`\Lambda_\mathrm{KI}(T_\mathrm{eq}) / \Gamma_\mathrm{KI} = 1/n`.
Defining :math:`f(T) = n\,\Lambda_\mathrm{KI}(T)/\Gamma_\mathrm{KI} - 1 = 0`
and differentiating:

.. math::

   f'(T) = \frac{n}{\Gamma_\mathrm{KI}}\,\Lambda'_\mathrm{KI}(T),

Newton iteration gives

.. math::

   T_\mathrm{new} = \left|T - \frac{f(T)}{f'(T)}\right|,

converging to tolerance :math:`|1 - T/T_\mathrm{new}| < 10^{-6}` within
:math:`\lesssim 30` iterations. The absolute value prevents spurious negative
temperatures during initial iterations far from equilibrium. The table entry
is then converted: density to code mass density, and temperature to specific
internal energy via
:math:`u_\mathrm{eq} = k_\mathrm{B}\,T_\mathrm{eq} / [(\gamma-1)\,\bar{\mu}\,m_\mathrm{p}]`.

References
----------

Koyama, H. & Inutsuka, S. 2002, ApJ, 564, L97 (not yet in phantom.bib)

Vazquez-Semadeni, E., Gomez, G. C., Jappsen, A. K., Ballesteros-Paredes, J.,
Gonzalez, R. F., & Klessen, R. S. 2007, ApJ, 657, 870 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_koyamainutsuka.f90
