.. phantom-doc: hand-written

eos_idealplusrad — Ideal Gas Plus Radiation Pressure Equation of State
======================================================================

Overview
--------

The ``eos_idealplusrad`` module implements an equation of state that combines an
ideal gas with radiation pressure.  It is the simplest EOS that captures the
physics of radiation-dominated stellar interiors, and is appropriate whenever the
ratio of radiation pressure to gas pressure (the parameter :math:`\beta`) is
non-negligible.  The EOS assumes local thermodynamic equilibrium so that the
radiation field has a Planck spectrum at the local gas temperature.

This EOS is selected via ``ieos = 12`` in the Phantom input file and is
incompatible with the separate radiation-transport module (to avoid double-counting
the radiation pressure term).  All inputs and outputs within this module are in CGS
units; unit conversions are performed in the calling routine in :doc:`eos`.

The module provides five public routines: a temperature solver from
:math:`(\rho, u)`, a pressure evaluator from :math:`(\rho, T)`, a sound-speed
evaluator, a temperature solver from :math:`(\rho, P)`, and a routine to recover
:math:`u` from :math:`(\rho, T)`.  Additional helper functions return the gas and
radiation energy components separately.  The temperature solvers use Newton–Raphson
iteration, which is required because the energy equation is quartic in temperature.

Physical & Mathematical Description
-------------------------------------

The total specific internal energy is the sum of gas and radiation contributions:

.. math::

   u = u_{\rm gas} + u_{\rm rad} = \frac{3}{2}\frac{k_B\,T}{\mu\,m_H} + \frac{a\,T^4}{\rho}

where :math:`k_B` is the Boltzmann constant, :math:`m_H` is the proton mass,
:math:`\mu` is the mean molecular weight, and :math:`a` is the radiation constant.
Note the factor of 3/2 corresponds to a monatomic ideal gas; the code comment
explicitly states this is not the adiabatic index :math:`\gamma`.

The total pressure is (equation 13.2 of Kippenhahn, Weigert & Weiss):

.. math::

   P = P_{\rm gas} + P_{\rm rad}
     = \frac{\rho\,k_B\,T}{\mu\,m_H} + \frac{a\,T^4}{3}.

Given :math:`(\rho, u)` the temperature is found from the quartic

.. math::

   a\,T^4 + \frac{3}{2}\frac{k_B\,\rho\,T}{\mu\,m_H} - \rho\,u = 0

by Newton–Raphson iteration with the correction

.. math::

   \delta T = \frac{a\,T^4 + \tfrac{3}{2}(k_B\,\rho\,T)/(\mu m_H) - \rho\,u}
                   {4\,a\,T^3 + \tfrac{3}{2}k_B\,\rho/(\mu m_H)}.

Given :math:`(\rho, P)` the temperature is similarly found from

.. math::

   \frac{a\,T^4}{3} + \frac{\rho\,k_B\,T}{\mu\,m_H} - P = 0.

The effective adiabatic index is computed from the definition

.. math::

   \gamma_{\rm eff} = 1 + \frac{P}{\rho\,u}

and the sound speed is

.. math::

   c_s = \sqrt{\frac{\gamma_{\rm eff}\,P}{\rho}}.

Derivations
-----------

**Initial temperature guess.**  When :math:`T \le 0` or is NaN, the initial guess
for the Newton iteration is the pure-gas temperature:

.. math::

   T_0 = \frac{\mu\,m_H\,u}{(3/2)\,k_B}.

For the pressure-to-temperature inversion the initial guess is
:math:`T_0 = \min[(3P/a)^{1/4},\, \mu m_H P/(\rho k_B)]`,
bounding the answer in both the gas- and radiation-dominated limits.

**Density from pressure and temperature.**  ``get_idealplusrad_rhofrompresT``
computes the density by solving the linear relation

.. math::

   \rho = \frac{\mu\,m_H}{k_B\,T}\!\left(P - \frac{a\,T^4}{3}\right)

which is exact once :math:`T` is known.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Kippenhahn, R., Weigert, A. & Weiss, A. 2012, Stellar Structure and Evolution, 2nd edition, Springer — equation 13.2 for the combined gas+radiation pressure

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_idealplusrad.f90
