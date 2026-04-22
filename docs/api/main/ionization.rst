.. phantom-doc: hand-written

ionization
==========

Overview
--------

The ``ionization_mod`` module provides routines for computing ionisation
fractions, recombination energies, effective specific heats, and mean
molecular weights for a partially ionised hydrogen–helium plasma. The
module is owned by Mike Lau and is used primarily by the equation-of-state
layer to account for the latent energy and modified compressibility
introduced by ionisation and recombination transitions.

Four ionisation processes are tracked: dissociation of H\ :sub:`2` into
atomic H, ionisation of H I into H II, first ionisation of He I into
He II, and second ionisation of He II into He III. Each transition is
characterised by a threshold energy stored in the public array ``eion``
(in erg mol\ :sup:`-1`): :math:`\epsilon_1 = 4.36\times10^{12}` (H\
:sub:`2`), :math:`\epsilon_2 = 1.312\times10^{13}` (H I),
:math:`\epsilon_3 = 2.3723\times10^{13}` (He I), and
:math:`\epsilon_4 = 5.2505\times10^{13}` (He II).

Ionisation fractions as functions of density and temperature are returned
by ``get_xion`` via an analytic fitting formula that reproduces Saha-type
equilibrium curves. The fitting approach approximates the ionisation
transition temperature and width as power-law functions of the ionisation
energy and a degeneracy parameter :math:`\log_{10} Q \equiv \log_{10}\rho - 2\log_{10} T
+ 12`, then evaluates the fraction through a smoothed step function.

Several hyperbolic tangent and sigmoidal helper functions (``rapid_tanh``,
``rapid_dtanh``, ``rapid_sigm``) implement numerically efficient
approximations that avoid the expense of transcendental function calls in
the inner loop. The public function ``cvmol`` returns the specific heat
correction for molecular hydrogen due to rotational and vibrational degrees
of freedom, modelled as a sum of two sigmoid transitions.
The full routine ``ionisation_fraction`` provides an independent,
iterative Newton–Raphson solution of the three coupled Saha equations for
H and He simultaneously, intended for use in contexts where exact
equilibrium fractions are needed in physical (CGS) units.

Physical & Mathematical Description
------------------------------------

**Ionisation transition model.** For each species :math:`i`, the
transition temperature and width are parameterised as

.. math::

   T_{\mathrm{tra},i} &= a_{\mathrm{rec},i}\,\log_{10}\!\left(
       \epsilon_i / R_g\right) + b_{\mathrm{rec},i}\,\log Q, \\
   w_i &= T_{\mathrm{tra},i}\,c_{\mathrm{rec},i}
           \left(1 + d_{\mathrm{rec},i}\,\log Q\right),

where :math:`\log_{10} Q = \max(-14, \log_{10}\rho) - 2\log_{10} T + 12` is a
degeneracy parameter encoding the departure from the fully-ionised limit,
and :math:`R_g` is the gas constant.

.. note::

   For species :math:`i \ge 2` (H\,{\sc i}, He\,{\sc i}, He\,{\sc ii}
   ionisation), the coefficient :math:`a_{{\rm rec},i}` is multiplied by the
   helium-fraction correction :math:`Y_{\rm fac} = 1 - f_{\rm rec}\,Y`, with
   :math:`f_{\rm rec} = 0.005` and :math:`Y` the helium mass fraction.  For
   typical :math:`Y \approx 0.28`, this correction is
   :math:`Y_{\rm fac} \approx 0.9986`.

The fitting coefficients
:math:`a_{\mathrm{rec}}`, :math:`b_{\mathrm{rec}}`, :math:`c_{\mathrm{rec}}`,
:math:`d_{\mathrm{rec}}` are tabulated in ``ionization_setup`` and tuned
for hydrogen mass fractions :math:`X \in [0.6, 0.8]`. Ionisation fraction
:math:`x_i` for species :math:`i` is then

.. math::

   x_i = \frac{1}{2}\!\left[\tanh\!\left(
       \frac{\log_{10} T - T_{\mathrm{tra},i}}{w_i}\right) + 1\right],

evaluated using the rational approximation ``rapid_tanh`` for numerical
efficiency. The derivative with respect to :math:`T` is

.. math::

   \frac{dx_i}{dT} = \frac{1}{2 T\,w_i^2}\,\mathrm{sech}^2\!\left(
       \frac{\log_{10} T - T_{\mathrm{tra},i}}{w_i}\right)
       \left[w_i(1 + 2\,b_i) + 2\,c_i\,(\log_{10} T - T_{\mathrm{tra},i})
       \,(b_i(1 + d_i\log_{10} Q) + d_i T_{\mathrm{tra},i})\right],

which is returned as the optional ``dxion`` output of ``get_xion``.

**Recombination energy.** The specific recombination energy per unit mass
(in erg g\ :sup:`-1`) is

.. math::

   e_\mathrm{rec} = \sum_{i=1}^{4} e_i\,x_i,

where the per-species energy weights are :math:`e_1 = \epsilon_1 X / 2`,
:math:`e_2 = \epsilon_2 X`, :math:`e_3 = \epsilon_3 Y / 4`, and
:math:`e_4 = \epsilon_4 Y / 4`, with :math:`X` and :math:`Y` the hydrogen
and helium mass fractions respectively.

**Effective specific heat.** The effective heat capacity at constant volume,
normalised as :math:`c_{V,\mathrm{eff}} / (\bar{\mu} R_g)`, is

.. math::

   c_{V,\mathrm{eff}} = \begin{cases}
     \dfrac{c_{V,\mathrm{mol}}(T)}{2}\,X_\mathrm{mol}
       + \dfrac{3}{2}\,\bar{\mu}_p^{-1}(1 - X_\mathrm{mol}),
       & x_1 < 1, \\[6pt]
     \dfrac{3}{2}\,\bar{\mu}_p^{-1}, & x_1 = 1,
   \end{cases}

where :math:`X_\mathrm{mol} = (1 - x_1)X` is the molecular hydrogen mass
fraction and :math:`\bar{\mu}_p^{-1}` collects the mean-molecular-weight
contributions from the monatomic/ionic part. The molecular H\ :sub:`2`
specific heat :math:`c_{V,\mathrm{mol}}` is given by

.. math::

   c_{V,\mathrm{mol}}(\ln T) = \frac{1}{2}\!\left[
     \sigma\!\left(\frac{\ln T - \ln T_\mathrm{rot}}{\sigma_\mathrm{rot}}\right)
     + \sigma\!\left(\frac{\ln T - \ln T_\mathrm{vib}}{\sigma_\mathrm{vib}}\right)
     + 5 \right],

where :math:`\sigma(u) = u / \sqrt{1 + |u|^n}^{1/n}` is the sigmoidal
function ``rapid_sigm``, the rotational activation temperature is
:math:`T_\mathrm{rot} = 130` K, the vibrational activation temperature is
:math:`T_\mathrm{vib} = 2000` K, and both width parameters are
:math:`\sigma_\mathrm{rot} = \sigma_\mathrm{vib} = 0.7`.

**Mean molecular weight.** The inverse mean molecular weight for a
partially ionised H/He plasma is

.. math::

   \bar{\mu}^{-1} = \left(\frac{x_1}{2} + x_2\right)X
   + \frac{1}{4}(x_3 + x_4 - 1)Y + \frac{1}{2},

where :math:`x_1 \in [0,1]` denotes the H\ :sub:`2` dissociation fraction
and :math:`x_2, x_3, x_4` the H I, He I, and He II ionisation fractions
respectively.

**Saha equilibrium (direct solver).** The ``ionisation_fraction``
subroutine solves three coupled Saha equations for
:math:`n_{\mathrm{H^+}} / n`, :math:`n_{\mathrm{He^+}} / n`, and
:math:`n_{\mathrm{He^{2+}}} / n` simultaneously via Newton–Raphson
iteration. The Saha coefficient for each transition is

.. math::

   A_s = g_s \left(\frac{\sqrt{2\pi m_e k_B}}{h}\right)^3
         \frac{T^{3/2}}{n}\,\exp\!\left(-\frac{\chi_s}{k_B T}\right),

with ionisation potentials :math:`\chi_{\mathrm{H}} = 13.598` eV,
:math:`\chi_{\mathrm{He\,I}} = 24.587` eV, and
:math:`\chi_{\mathrm{He\,II}} = 54.418` eV. The Saha equations are cast as
a :math:`3\times3` nonlinear system and the Jacobian is inverted at each
iteration using the ``matrixinvert3D`` utility.

References
----------

Saha, M. N. 1920, Philos. Mag., 40, 472 (original Saha ionisation equation)

Weingartner, J. C. & Draine, B. T. 2001, ApJ, 563, 842

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/ionization.f90
