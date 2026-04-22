.. phantom-doc: hand-written

cooling_functions
=================

Overview
--------

The ``cooling_functions`` module provides a self-contained library of analytic
and semi-analytic heating and cooling rate prescriptions, all evaluated in CGS
units. Every function returns a net rate :math:`Q` (erg g\ :sup:`-1`
s\ :sup:`-1` or erg cm\ :sup:`-3` s\ :sup:`-1` depending on context) together
with the logarithmic temperature derivative
:math:`\mathrm{d}\ln Q/\mathrm{d}\ln T`, which is required by the implicit and
exact integration schemes implemented in ``cooling_solver``.

The module is not invoked directly by the SPH time-integration loop. Instead,
``cooling_solver`` assembles the total cooling rate by calling the individual
functions selected at runtime via the flags ``excitation_HI``,
``relax_Bowen``, ``dust_collision``, and ``relax_Stefan``. The combined CGS
result is then converted to code units by ``calc_cooling_rate`` before being
returned to the integrator.

The library is organised around four categories of physical process. First,
dust–gas energy exchange: full contact cooling (Bowen 1988), discrete grain
contact cooling (Hollenbach & McKee 1979; Burke & Hollenbach 1983), and a
radiative exchange term (Woitke 2006) that is explicitly marked as physically
incorrect and excluded from production runs. Second, dust heating: friction
heating by dust drift (Goldreich & Scoville 1976) and photovoltaic heating by
soft and hard UV radiation (Weingartner & Draine 2001; Inoue & Kamaya 2010).
Third, atomic and ionic cooling: electron excitation of neutral hydrogen
(Spitzer 1978; Dalgarno & McCray 1972; Cen 1992), collisional ionisation of H
and He (Black 1982; Cen 1992), and Coulomb cooling via charged-grain electron
scattering (Weingartner & Draine 2001). Fourth, molecular cooling and heating:
ro-vibrational excitation of H\ :sub:`2` (Lepp & Shull 1983; Smith & Rosen
2003), H\ :sub:`2` collisional dissociation (Shapiro & Kang 1987; Smith &
Rosen 2003), H\ :sub:`2` formation heating on grains (Hollenbach & McKee 1979),
CO ro-vibrational emission (Hollenbach & McKee 1979; McKee et al. 1982), H\
:sub:`2`\ O ro-vibrational emission (Hollenbach & McKee 1989; Neufeld &
Kaufman 1993), and OH rotational emission (Hollenbach & McKee 1979; McKee et
al. 1982). Cosmic-ray heating (Jonkheid et al. 2004) and a piecewise analytic
shock cooling law (Creasey et al. 2011) for benchmark tests are also included.

Auxiliary routines compute the LTE electron number density from the Saha
equations (D'Angelo & Bodenheimer 2013 parameterisation) for a hydrogen–helium
mixture with assumed mass fractions :math:`X_H = 0.7`, :math:`X_{He} = 0.28`,
the mean thermal speed, the cumulative Maxwell–Boltzmann distribution function
(used to truncate molecular cooling rates at velocities sufficient to destroy
bonds), and the dust grain number density from a dust-to-gas ratio and mean
grain size.

Physical & Mathematical Description
-------------------------------------

**Bowen (1988) diffusive relaxation:**

.. math::

   Q_\mathrm{Bowen} = \frac{R_\mathrm{g}}{(\gamma-1)\,\mu}\,\rho\,
   \frac{T_\mathrm{dust} - T}{C^\prime},

where :math:`C^\prime` (parameter ``bowen_Cprime``, default
:math:`3\times10^{-5}` g s cm\ :sup:`-3`) is the Bowen radiative cooling rate
constant, :math:`R_\mathrm{g}` is the specific gas constant, and :math:`\mu`
is the mean molecular weight.

**Discrete grain–gas contact cooling** (Hollenbach & McKee 1979;
Burke & Hollenbach 1983):

.. math::

   Q_\mathrm{disc} = \alpha\,n_\mathrm{gas}\,n_\mathrm{dust}\,
   \sigma_\mathrm{grain}\,\bar{v}(T)\,k_\mathrm{B}
   (T_\mathrm{gas} - T_\mathrm{dust}),

with accommodation coefficient :math:`\alpha = 0.33`, geometric grain cross
section :math:`\sigma_\mathrm{grain} = 2\pi a^2`, and mean thermal speed
:math:`\bar{v} = \sqrt{3k_\mathrm{B}T/(\mu m_\mathrm{p})}`.

**Radiative relaxation toward dust temperature** (Woitke 2006 style):

.. math::

   Q_\mathrm{rad} = 4\,\sigma_\mathrm{SB}
   (T_\mathrm{dust}^4 - T^4)\,\kappa,

where :math:`\kappa` is the mean opacity and :math:`\sigma_\mathrm{SB}` is the
Stefan–Boltzmann constant. This function is retained for completeness but is
noted as physically approximate.

**Electron excitation of neutral hydrogen** (Spitzer 1978; Cen 1992):

.. math::

   Q_\mathrm{HI} = -7.3\times10^{-19}\,\frac{n_e\,n_\mathrm{H}}{\rho}
   \frac{\exp(-118400/T)}{1 + \sqrt{T/10^5}}
   \quad \mathrm{[erg\ g^{-1}\ s^{-1}]}, \quad T > 3000\,\mathrm{K}.

The correction factor :math:`(1+\sqrt{T/10^5})^{-1}` is due to Cen (1992).

**Piecewise analytic shock cooling** (Creasey et al. 2011):

.. math::

   Q_\mathrm{shock} = -\frac{\lambda_\mathrm{shock}\,n^2}{\rho}\times
   \begin{cases}
   (T-T_0)/T_0, & T_0 \le T \le T_\mathrm{mid}, \\
   (T_1-T)/T_0, & T_\mathrm{mid} \le T \le T_1, \\
   0, & \text{otherwise},
   \end{cases}

where :math:`T_\mathrm{mid} = (T_0+T_1)/2`, :math:`T_1 = f\,T_0` with factor
:math:`f` = ``T1_factor``, and :math:`\lambda_\mathrm{shock}` is set by
``lambda_shock_cgs``.

**H\ :sub:`2` ro-vibrational cooling** (Lepp & Shull 1983; Smith & Rosen 2003)
uses a two-rate (high- and low-density) formulation for both the vibrational
and rotational contributions:

.. math::

   Q_\mathrm{H_2} = n_\mathrm{H_2}
   \left[\frac{L_{v,\mathrm{hi}}}{1+L_{v,\mathrm{hi}}/L_{v,\mathrm{lo}}}
   +\frac{L_{r,\mathrm{hi}}}{1+L_{r,\mathrm{hi}}/L_{r,\mathrm{lo}}}\right].

**Electron number density** from the Palla et al. (1983) / D'Angelo &
Bodenheimer (2013) Saha-equation network for H, H\ :sub:`2`, and He:

.. math::

   n_e = x\,n_\mathrm{H} + z_1(1+z_2)\,n_\mathrm{He},

where :math:`x` (H ionisation fraction), :math:`z_1` (He ionisation fraction)
and :math:`z_2` (He double ionisation fraction) are obtained from the quadratic
Saha equations at temperature :math:`T_\mathrm{gas}`.

References
----------

Black, J. H. 1982, in Symposium on the Orion Nebula to Honor Henry Draper,
   Ann. N.Y. Acad. Sci., 395, 99 (not yet in phantom.bib)

Bowen, G. H. 1988, ApJ, 329, 299 (not yet in phantom.bib)

Burke, J. R. & Hollenbach, D. J. 1983, ApJ, 265, 223 (not yet in phantom.bib)

Cen, R. 1992, ApJS, 78, 341 (not yet in phantom.bib)

Creasey, P., Theuns, T., Bower, R. G., & Lacey, C. G. 2011, MNRAS, 415, 3706
(not yet in phantom.bib)

D'Angelo, G. & Bodenheimer, P. 2013, ApJ, 778, 77 (not yet in phantom.bib)

Dalgarno, A. & McCray, R. A. 1972, ARA&A, 10, 375 (not yet in phantom.bib)

Goldreich, P. & Scoville, N. 1976, ApJ, 205, 144 (not yet in phantom.bib)

Hollenbach, D. & McKee, C. F. 1979, ApJS, 41, 555 (not yet in phantom.bib)

Hollenbach, D. & McKee, C. F. 1989, ApJ, 342, 306 (not yet in phantom.bib)

Inoue, A. K. & Kamaya, H. 2010, MNRAS, 405, 2415 (not yet in phantom.bib)

Jonkheid, B., Faas, F. G. A., van Zadelhoff, G.-J., & van Dishoeck, E. F.
2004, A&A, 428, 511 (not yet in phantom.bib)

Lepp, S. & Shull, J. M. 1983, ApJ, 270, 578 (not yet in phantom.bib)

McKee, C. F., Storey, J. W. V., Watson, D. M., & Green, S. 1982, ApJ, 259, 647
(not yet in phantom.bib)

Neufeld, D. A. & Kaufman, M. J. 1993, ApJ, 418, 263 (not yet in phantom.bib)

Palla, F., Salpeter, E. E., & Stahler, S. W. 1983, ApJ, 271, 632
(not yet in phantom.bib)

Shapiro, P. R. & Kang, H. 1987, ApJ, 318, 32 (not yet in phantom.bib)

Smith, M. D. & Rosen, A. 2003, MNRAS, 339, 133 (not yet in phantom.bib)

Spitzer, L. 1978, Physical Processes in the Interstellar Medium, Wiley
(not yet in phantom.bib)

Weingartner, J. C. & Draine, B. T. 2001, ApJS, 134, 263 (not yet in phantom.bib)

Woitke, P. 2006, A&A, 460, L9 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_functions.f90
