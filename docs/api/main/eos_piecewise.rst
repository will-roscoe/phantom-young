.. phantom-doc: hand-written

eos_piecewise — Piecewise Polytropic Equation of State
======================================================

Overview
--------

The ``eos_piecewise`` module implements a piecewise-polytropic equation of state
designed primarily for neutron-star simulations.  The pressure is a power law in
density within each of four successive density segments, and the polytropic
coefficients :math:`K_i` are fixed by requiring global pressure continuity at the
transition densities.  This parameterisation follows the prescription of Read et al.
(2009), which provides a compact four-parameter representation (transition pressure
:math:`p_1`, exponents :math:`\Gamma_1, \Gamma_2, \Gamma_3`) that can reproduce the
predictions of a wide range of nuclear-matter models.

This EOS is selected by ``ieos = 9`` in the Phantom input file.  Unlike the
barotropic EOS (:doc:`eos_barotropic`), which uses the same mathematical structure but
different defaults and a more involved warm-medium transition, this module is optimised
for neutron-star conditions and includes a preset library (``init_eos_piecewise_preset``)
corresponding to the APR3, SLy, MS1, and ENG nuclear models from Read et al. (2009).

The module also provides ``gamma_pwp`` (a function returning the local :math:`\Gamma`
at a given density) and ``get_dPdrho_piecewise`` (the derivative :math:`dP/d\rho`,
needed for time-step control), both of which are used by the Phantom SPH integrator.

Physical & Mathematical Description
-------------------------------------

The piecewise polytrope is defined as

.. math::

   P(\rho) = K_i\,\rho^{\Gamma_i}, \qquad \rho_{i-1} \le \rho < \rho_i

for :math:`i = 0, 1, 2, 3`, where the density segments are separated by the
critical densities :math:`\rho_0 < \rho_1 < \rho_2`.  The polytropic coefficients
:math:`K_i` are determined by continuity:

.. math::

   K_1 = \frac{p_1}{\rho_1^{\Gamma_1}}, \quad
   K_2 = \frac{p_1}{\rho_1^{\Gamma_2}}, \quad
   K_3 = K_2\,\rho_2^{\Gamma_2 - \Gamma_3}, \quad
   K_0 = K_1\,\rho_0^{\Gamma_1 - \Gamma_0}.

The adiabatic sound speed is

.. math::

   c_s = \sqrt{\frac{\Gamma_i\,P}{\rho}}

at any point within segment :math:`i`.

**Default parameters (Read et al. 2009, APR3 model, CGS):**

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Parameter
     - Default value
   * - :math:`\rho_0`
     - :math:`2.628 \times 10^{12}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\rho_1`
     - :math:`5.012 \times 10^{14}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\rho_2`
     - :math:`1.0   \times 10^{15}\ \mathrm{g\,cm^{-3}}`
   * - :math:`p_1`
     - :math:`2.466 \times 10^{34}\ \mathrm{dyn\,cm^{-2}}`
   * - :math:`\Gamma_0`
     - 5/3 (non-relativistic matter)
   * - :math:`\Gamma_1`
     - 3.166
   * - :math:`\Gamma_2`
     - 3.573
   * - :math:`\Gamma_3`
     - 3.281

Derivations
-----------

The pressure continuity conditions are applied in ``init_eos_piecewise`` after
converting the critical densities and reference pressure from CGS to code units.
The computation proceeds outward from the anchor point :math:`p_1` at :math:`\rho_1`:

1. :math:`K_1 = p_1/\rho_1^{\Gamma_1}` and :math:`K_2 = p_1/\rho_1^{\Gamma_2}`
   ensure :math:`P_{1,\rm left} = P_{1,\rm right} = p_1`.
2. :math:`K_3 = K_2\,\rho_2^{\Gamma_2-\Gamma_3}` ensures
   :math:`P_2 = K_2\,\rho_2^{\Gamma_2} = K_3\,\rho_2^{\Gamma_3}`.
3. :math:`K_0 = K_1\,\rho_0^{\Gamma_1-\Gamma_0}` ensures
   :math:`P_0 = K_0\,\rho_0^{\Gamma_0} = K_1\,\rho_0^{\Gamma_1}`.

The derivative :math:`dP/d\rho = \Gamma_i K_i \rho^{\Gamma_i - 1}` is computed
directly from the piecewise coefficients in ``get_dPdrho_piecewise``.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Read, J. S., Lackey, B. D., Owen, B. J. & Friedman, J. L. 2009, Phys. Rev. D, 79, 124032 — piecewise polytrope parameterisation for neutron stars

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_piecewise.f90
=============

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

.. f:autosrcfile:: ../../../src/main/eos_piecewise.f90
