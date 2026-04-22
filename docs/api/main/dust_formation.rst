.. phantom-doc: hand-written

dust_formation — Dust Nucleation and Condensation in AGB Winds
===============================================================

Overview
--------

The ``dust_formation`` module models the formation and growth of carbon dust in
the circumstellar envelopes of AGB stars.  It implements the theory of moments
for the dust grain size distribution following Gail & Sedlmayr, providing a
self-consistent treatment of chemical equilibrium, classical nucleation theory,
and grain mantle growth within a single-fluid SPH framework.

At each SPH timestep the module advances the chemical state of a wind particle
by integrating the nucleation rate and the first four moments of the grain-size
distribution.  The chemical equilibrium sub-routine resolves the partial
pressures of 25 molecular species (H\ :sub:`2`, CO, C\ :sub:`2`H\ :sub:`2`,
SiO, TiO\ :sub:`2`, and others) iteratively, given the local temperature, gas
density, and elemental abundances.  Carbon nucleation is triggered when the
saturation ratio :math:`S = p_C / p_\mathrm{sat}(T)` exceeds the critical value
:math:`S_\mathrm{crit} = 2`.  Once nuclei form, grain radii grow by accretion of
C, C\ :sub:`2`H, and C\ :sub:`2`H\ :sub:`2` molecules from the gas phase.

The dust opacity is computed from the third moment :math:`K_3` of the size
distribution using a Rosseland-mean formula from Gail & Sedlmayr (1985).
Alternatively, the simpler Bowen (1988) opacity prescription can be selected via
``idust_opacity = 1``, which gives a smooth step-function parameterised by a
condensation temperature ``bowen_Tcond`` and a width ``bowen_delta``.  The
Eddington factor (ratio of radiation pressure to gravitational deceleration) is
also calculated here and used by the wind module to account for radiative
acceleration.

The mean molecular weight :math:`\mu` and effective adiabatic index
:math:`\gamma` of the gas mixture are updated self-consistently as the
H\ :sub:`2` dissociation fraction changes with temperature, with an iterative
Newton solver handling the coupled :math:`(\mu,\gamma,T)` system.

Physical & Mathematical Description
-------------------------------------

**Theory of moments.**  Rather than tracking individual grain sizes, the module
evolves the :math:`j`-th moment of the grain number-density distribution
:math:`f(a)` per hydrogen nucleus,

.. math::

   K_j = \int_0^\infty a^j\, f(a)\,\mathrm{d}a, \qquad j = 0, 1, 2, 3.

The zeroth moment :math:`K_0` is the total grain number density per H atom; the
third moment :math:`K_3` is proportional to the total condensed carbon abundance
:math:`\epsilon_C^\mathrm{dust} = K_3 \, m_C / m_\mathrm{H}`.

**Classical nucleation rate.**  The stationary nucleation rate (number of
critical clusters formed per unit volume per unit time) is

.. math::

   J^* = \beta\, A_{N^*}\, Z\, c_{N^*},

where :math:`N^*` is the critical cluster size, :math:`A_{N^*}` its surface
area, :math:`Z` the Zeldovich non-equilibrium factor, :math:`\beta` the
monomer impingement rate, and :math:`c_{N^*}` the equilibrium concentration of
critical clusters.  The cluster free energy is parameterised through the surface
tension :math:`\sigma = 1400\,\mathrm{erg\,cm}^{-2}` and the monomer surface
area :math:`A_0 = 20.7 \times 10^{-16}\,\mathrm{cm}^2`.  The critical size is

.. math::

   N^* - 1 = \frac{1}{8}
   \left(\frac{2\theta_\infty}{3T\ln S}\right)^3
   \left(1 + \sqrt{1 + \frac{2 N_l^{1/3}}{(2\theta_\infty/3T\ln S)}}
        - \frac{2 N_l^{1/3}}{(2\theta_\infty/3T\ln S)}\right)^3,

with :math:`\theta_\infty = A_0\sigma/k_B` and lower grain size limit
:math:`N_l = 1000`.

**Moment evolution equations.**  Between nucleation events the moments grow by
accretion of gas-phase carbon species at the grain surface.  The grain-growth
timescale is

.. math::

   \tau_\mathrm{gr} = \frac{k_B T}{A_0\,v_1\,
   \left[\alpha_1 p_C (1 - S^{-1})
       + \sqrt{2}\,\alpha_2\,(p_{C_2} + p_{C_2\mathrm{H}} + p_{C_2\mathrm{H}_2})
         (1 - S^{-2})\right]},

where :math:`v_1 = \sqrt{k_B T/(2\pi m_C)}` is the thermal speed of a carbon
monomer and :math:`\alpha_1 = 0.37`, :math:`\alpha_2 = 0.34` are sticking
coefficients.  The coupled moment equations are integrated analytically over a
timestep :math:`\Delta t` using the nucleation timescale :math:`\tau^*` (see
``evol_K``).

**Carbon saturation pressure.**  The saturation vapour pressure over graphite is
fitted by

.. math::

   \ln p_\mathrm{sat}(T) = -\frac{8.612 \times 10^4}{T}
   + 18.511 + 5.880 \times 10^{-4}\,T
   - 2.515 \times 10^{-7}\,T^2
   + 3.249 \times 10^{-11}\,T^3 + f,

where :math:`f = 13.8287` is a unit-conversion constant (cgs).

**Dust opacity.**  The Rosseland mean dust opacity at temperature
:math:`T_\mathrm{dust}` is

.. math::

   \kappa_\mathrm{dust} = 5.9\,\frac{0.75\,K_3\,m_C}{m_\mathrm{H}\,\rho_{C}}\,
   T_\mathrm{dust} + \kappa_\mathrm{gas},

with carbon dust bulk density :math:`\rho_C = 2.62\,\mathrm{g\,cm}^{-3}` and
constant gas opacity :math:`\kappa_\mathrm{gas}` (default
:math:`2\times10^{-4}\,\mathrm{cm}^2\,\mathrm{g}^{-1}`), following Gail &
Sedlmayr (1985).

.. note::

   The argument :math:`0.75\,K_3\,m_C / (m_\mathrm{H}\,\rho_C)` is subject to
   a floor clamp in the code:
   :math:`\max\!\left(0.75\,K_3\,m_C / (m_\mathrm{H}\,\rho_C),\;10^{-15}\right)`,
   which prevents division by zero when :math:`K_3 \approx 0`.

   Here :math:`m_\mathrm{H}` is the mass of a hydrogen nucleus
   (:math:`\approx 1.67 \times 10^{-24}\,\mathrm{g}`), not the mean molecular
   weight :math:`\mu m_p` of the gas mixture.

**Bowen opacity.**  When ``idust_opacity = 1`` the total opacity is

.. math::

   \kappa_\mathrm{Bowen}(T) = \frac{\kappa_\mathrm{max}}{1 + \exp\!\left(
   (T - T_\mathrm{cond})/\delta\right)} + \kappa_\mathrm{gas},

a smooth step function parameterised by maximum opacity
:math:`\kappa_\mathrm{max}`, condensation temperature :math:`T_\mathrm{cond}`,
and width :math:`\delta`.

**Eddington factor.**  The ratio of radiation to gravity is

.. math::

   \Gamma = \frac{L_\star \kappa}{4\pi c G M_\star}\,
   e^{-\tau},

where the optional optical-depth attenuation :math:`e^{-\tau}` accounts for
self-shielding.

References
----------

Gail, H.-P. & Sedlmayr, E. (1985), A&A 148, 183 [not yet in phantom.bib]

Gail, H.-P. & Sedlmayr, E., *Physics and Chemistry of Circumstellar Dust Shells*,
Cambridge University Press (2014) [not yet in phantom.bib]

Bowen, G. H. (1988), ApJ 329, 299 [not yet in phantom.bib]

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/dust_formation.f90
