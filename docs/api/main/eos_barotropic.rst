.. phantom-doc: hand-written

eos_barotropic — Barotropic Equation of State
=============================================

Overview
--------

The ``eos_barotropic`` module implements a piecewise-polytropic (barotropic) equation
of state designed for star-formation simulations.  In this prescription the pressure
is determined solely by the local density — there is no independent thermal energy
variable.  At low densities the gas is treated as isothermal, reflecting efficient
cooling; above a series of critical density thresholds the effective adiabatic index
increases in steps, modelling the progressive opacity-driven transition from the
optically thin to the optically thick regime during protostellar collapse.

This EOS is selected by setting ``ieos = 8`` in the Phantom input file.  It is
the standard choice for isolated-core and multiple-system star-formation calculations
where a simple thermodynamic treatment is sufficient.  The module is initialised
through ``init_eos_barotropic``, which converts the user-supplied critical densities
from CGS to code units and precomputes the polytropic prefactors so that pressure
is continuous across every transition.

The barotropic EOS does not require a stored thermal-energy variable and is therefore
incompatible with the ``ISOTHERMAL=no`` compilation flag at the Phantom build level.
It is used in conjunction with the master dispatcher in :doc:`eos`.

Physical & Mathematical Description
-------------------------------------

The barotropic EOS is defined by the following piecewise relation for :math:`P/\rho`:

.. math::

   \frac{P}{\rho} =
   \begin{cases}
     c_{\rm ld}^2 & \rho < \rho_T \\[4pt]
     c_{\rm ld}^2
       \left(\dfrac{\rho_T}{\rho}\right)^{m_{\rm slope}}
     & \rho_T \le \rho < \rho_0 \\[8pt]
     c_s^2 & \rho_0 \le \rho < \rho_1 \\[4pt]
     c_s^2 \left(\dfrac{\rho}{\rho_1}\right)^{\Gamma_1 - 1} & \rho_1 \le \rho < \rho_2 \\[4pt]
     K_2   \left(\dfrac{\rho}{\rho_2}\right)^{\Gamma_2 - 1} & \rho_2 \le \rho < \rho_3 \\[4pt]
     K_3   \left(\dfrac{\rho}{\rho_3}\right)^{\Gamma_3 - 1} & \rho_3 \le \rho < \rho_4 \\[4pt]
     K_4   \left(\dfrac{\rho}{\rho_4}\right)^{\Gamma_4 - 1} & \rho \ge \rho_4
   \end{cases}

where :math:`c_s^2 \equiv` ``polyk``, :math:`c_{\rm ld}^2 \equiv` ``polyk2``, and
:math:`\rho_T = \rho_0 (1 - \delta_0)` is a transition density controlled by the
parameter ``drhocrit``.  The transition slope :math:`m_{\rm slope}` is chosen so
that :math:`P(\rho)` is continuous.

The prefactors for the adiabatic branches are fixed at initialisation to ensure
global continuity:

.. math::

   K_2 = c_s^2 \left(\frac{\rho_2}{\rho_1}\right)^{\Gamma_1 - 1}, \quad
   K_3 = K_2   \left(\frac{\rho_3}{\rho_2}\right)^{\Gamma_2 - 1}, \quad
   K_4 = K_3   \left(\frac{\rho_4}{\rho_3}\right)^{\Gamma_3 - 1}.

The adiabatic sound speed at any density is

.. math::

   c_s = \sqrt{\Gamma({\rho})\,P/\rho}

where :math:`\Gamma(\rho)` is the local adiabatic index (1 in the isothermal
branches, :math:`\Gamma_i` in the adiabatic branches).

**Default parameters** (CGS, following Bate, Bonnell & Bromm 2003):

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Parameter
     - Default value
   * - :math:`\rho_0`
     - :math:`10^{-18}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\rho_1`
     - :math:`10^{-14}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\rho_2`
     - :math:`10^{-10}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\rho_3`
     - :math:`10^{-3}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\rho_4`
     - :math:`10^{-1}\ \mathrm{g\,cm^{-3}}`
   * - :math:`\Gamma_1`
     - 1.4
   * - :math:`\Gamma_2`
     - 1.1
   * - :math:`\Gamma_3`
     - 5/3
   * - :math:`\Gamma_4`
     - 1.1

Derivations
-----------

The optional warm-medium transition (``drhocrit > 0``) smoothly interpolates in
log–log space between ``polyk2`` (the warm medium sound speed squared) and
``polyk`` (the cool isothermal sound speed squared) over the density interval
:math:`[\rho_T, \rho_0]`:

.. math::

   \log_{10}\!\left(\frac{P}{\rho}\right)
   = \log_{10} c_{\rm ld}^2
   + m_{\rm slope}\!\left[\log_{10}\rho_T - \log_{10}\rho\right]

with

.. math::

   m_{\rm slope} = \frac{\log_{10} c_s^2 - \log_{10} c_{\rm ld}^2}
                        {\log_{10} \rho_T - \log_{10} \rho_0}.

This matches both :math:`c_{\rm ld}^2` at :math:`\rho = \rho_T` and :math:`c_s^2`
at :math:`\rho = \rho_0`.  If ``drhocrit = 0`` or ``polyk2 = 0`` the warm medium
is absent and :math:`\rho_T` is collapsed to :math:`\rho_0`.

References
----------

The default parameters and physical motivation for this prescription are drawn from
Bate, Bonnell & Bromm (2003).

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Bate, M. R., Bonnell, I. A. & Bromm, V. 2003, MNRAS, 339, 577 — star-formation barotropic EoS prescription

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_barotropic.f90
