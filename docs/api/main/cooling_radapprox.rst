.. phantom-doc: hand-written

cooling_radapprox
=================

Overview
--------

The ``cooling_radapprox`` module implements the radiative cooling approximation
of Stamatellos et al. (2007), extended and refined by Young et al. (2024), for
use in disc and protostellar simulations where the gas optical depth spans many
orders of magnitude. It is activated by setting ``icooling = 9`` in the Phantom
input file and requires the tabulated equation of state ``ieos = 24``
(``eos_stamatellos``).

The method avoids solving the full radiative-transfer equation by instead
computing an effective optical depth :math:`\tau_\mathrm{eff}` for each SPH
particle from an estimate of the local mean column density. The net radiative
cooling rate is then expressed as a blackbody emission term modified by the
optical depth, relaxing the gas toward an equilibrium temperature that accounts
for both the background radiation field and stellar irradiation.

Four methods for estimating the column density (and hence the optical depth)
are available, selected by the parameter ``od_method``:

1. **Stamatellos et al. (2007)** — column density from the gravitational
   potential and local density via a polytropic approximation.
2. **Lombardi et al. (2015)** — column density from the local pressure
   gradient scale height.
3. **Combined** — harmonic mean of the Stamatellos and Lombardi scale heights.
4. **Modified Lombardi (Young et al. 2024, default)** — pressure gradient
   scale height combined with a modified disc scale height that accounts for
   both self-gravity and the stellar gravitational field.

An optional stellar irradiation term is included when a non-zero stellar
luminosity ``Lstar`` (in solar luminosities) is provided. The central (closest
to the origin) sink particle is used as the irradiating star.

The module stores per-particle thermalization timescales (``ttherm_store``) and
equilibrium internal energies (``ueqi_store``) for use by the implicit energy
integration in the main SPH step (``radcool_evolve_ui``). This design decouples
the expensive opacity and column-density calculations, performed once per
``radcool_update_du`` call, from the rapid exponential relaxation applied in
``radcool_evolve_ui``.

Physical & Mathematical Description
-------------------------------------

The effective opacity combining absorption and scattering is

.. math::

   \tau_\mathrm{eff} = \Sigma^2\,\bar{\kappa}_\mathrm{R}
   + \frac{1}{\bar{\kappa}_\mathrm{P}},

where :math:`\Sigma` is the estimated surface density (column density),
:math:`\bar{\kappa}_\mathrm{R}` is the Rosseland mean opacity, and
:math:`\bar{\kappa}_\mathrm{P}` is the Planck mean opacity, both obtained
from the tabulated EOS.

The radiative cooling rate per unit mass is

.. math::

   \dot{u}_\mathrm{rad} = \frac{4\,\sigma_\mathrm{SB}
   (T_\mathrm{min}^4 - T^4)}{\tau_\mathrm{eff}\,u_\mathrm{erg}}\,
   \frac{u_t}{1},

where :math:`T` is the current gas temperature, :math:`u_\mathrm{erg}` is the
code unit of specific energy, and :math:`u_t` is the code unit of time.

The minimum temperature is set by background irradiation and stellar heating:

.. math::

   T_\mathrm{min}^4 = T_\mathrm{floor}^4
   + e^{-\Sigma\,\bar{\kappa}_\mathrm{R}}\,
   \frac{L_\star}{16\pi\sigma_\mathrm{SB}\,r^2},

where the exponential factor provides approximate self-shielding from the
stellar radiation field.

The equilibrium temperature toward which the gas relaxes is determined by the
total energy input (hydrodynamic plus radiative):

.. math::

   T_\mathrm{eq}^4 = \frac{(\dot{u}_\mathrm{hydro} + \dot{u}_\mathrm{rad})
   \,\tau_\mathrm{eff}\,u_\mathrm{erg}/u_t}{4\,\sigma_\mathrm{SB}}
   + T_\mathrm{min}^4,

and the corresponding equilibrium energy :math:`u_\mathrm{eq}` is obtained from
the tabulated EOS. The thermalization timescale is

.. math::

   t_\mathrm{therm} = \left|\frac{u_\mathrm{eq} - u}
   {\dot{u}_\mathrm{hydro} + \dot{u}_\mathrm{rad}}\right|.

**Modified Lombardi scale height** (Young et al. 2024, ``od_method = 4``):

The pressure scale height :math:`H_\mathrm{Lom} = P / (|\nabla P|/\rho)` from
Lombardi et al. (2015) is combined with a modified disc scale height

.. math::

   H_\mathrm{mod}^{-2} = H_\mathrm{Lom}^{-2}
   + \left(\frac{c_s^2\,\pi/2}{\Omega^2 + 8\sqrt{\pi/2}\,G\,\rho}\right)^{-1},

where the denominator in the second term accounts for both the stellar Keplerian
field and self-gravity of the disc. The combined column density is then

.. math::

   \Sigma = 1.014\,H_\mathrm{comb}\,\rho,

with :math:`H_\mathrm{comb} = (H_\mathrm{Lom}^{-2} + H_\mathrm{mod}^{-2})^{-1/2}`.

The implicit energy update in ``radcool_evolve_ui`` uses the stored
:math:`t_\mathrm{therm}` and :math:`u_\mathrm{eq}` to perform an exponential
relaxation:

.. math::

   u(t+\Delta t) = u_\mathrm{eq}
   + (u - u_\mathrm{eq})\,\exp(-\Delta t / t_\mathrm{therm}),

which is unconditionally stable for all values of :math:`\Delta t / t_\mathrm{therm}`.

References
----------

Lombardi, J. C., McInelly, J. A., Faber, J. A., Dooley, K. L., Rasio, F. A.,
& Sills, A. 2015, MNRAS, 447, 75 (not yet in phantom.bib)

Stamatellos, D., Whitworth, A. P., Bisbas, T., & Goodwin, S. 2007, A&A, 475,
37 (not yet in phantom.bib)

Young, M. D. et al. 2024 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_radapprox.f90
