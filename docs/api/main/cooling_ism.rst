.. phantom-doc: hand-written

cooling_ism
===========

Overview
--------

The ``cooling_ism`` module implements a comprehensive cooling and heating
network for the multi-phase interstellar medium (ISM). The routines were
originally written by Simon Glover for the ZEUS-3D code (based on work by
M. D. Smith and G. Pavlovski at Armagh Observatory) and subsequently
translated to Fortran 90 and adapted for Phantom by Daniel Price (2011).

The core of the module is the ``cool_func`` subroutine, which computes the
net volumetric cooling rate :math:`\Lambda_\mathrm{net}` (erg s\ :sup:`-1`
cm\ :sup:`-3`) for given local temperature, number density, chemical
abundances, and velocity divergence. The rates are evaluated by interpolation
within a large pre-computed look-up table (10 000 entries in temperature,
54 cooling coefficients per entry) that is constructed at initialisation by
``init_cooling_ism``. A separate set of tables handles CO rotational cooling
as a function of both temperature and CO column density.

The module is activated for ``icooling = 4`` (applied within the SPH step) or
``icooling = 8`` (applied outside the step). The public entry point used by
the dispatcher is ``energ_cooling_ism``, which converts the volumetric rate to
the specific rate :math:`\dot{u}` in code units.

The ISM cooling network includes the following processes:

- Fine-structure line cooling from neutral oxygen [O I], singly ionised carbon
  [C II], and singly ionised silicon [Si II] (following Glover & Mac Low
  2007 and references therein; tabulated from Sembach et al. 2000 atomic data).
- Molecular hydrogen ro-vibrational and rotational cooling.
- CO rotational cooling with explicit column-density dependence via tabulated
  escape-probability rates (Neufeld & Kaufman 1993 data).
- Photoelectric heating from dust grains illuminated by the ambient UV field,
  treated either as optically thin (``iphoto = 0``) or with an approximate
  dust-shielding correction (``iphoto = 1``).
- Cosmic-ray ionisation heating.
- Atomic cooling from H and He species at elevated temperatures.

The abundances of C, O, Si, and electrons, as well as the dust-to-gas ratio,
UV field strength, and characteristic length scales for chemistry and
photodissociation, are all configurable runtime parameters.

Physical & Mathematical Description
-------------------------------------

The net cooling rate is assembled as

.. math::

   \frac{\mathrm{d}e}{\mathrm{d}t} = -\Lambda_\mathrm{net}
   = -\sum_i \Lambda_i + \sum_j \Gamma_j,

where :math:`\Lambda_i` are individual cooling contributions (positive
values indicate cooling) and :math:`\Gamma_j` are heating contributions
(negative in the sign convention used internally). The conversion to the
specific energy update used by Phantom is

.. math::

   \dot{u}_\mathrm{cool} = -\frac{\Lambda_\mathrm{net}}{\rho}\,
   \frac{u_t^3}{l_t^2},

where :math:`u_t` and :math:`l_t` are the code time and length units.

The temperature used internally by ``energ_cooling_ism`` is derived from the
specific internal energy via the ideal-gas relation for an isothermal-like gas:

.. math::

   T = \frac{2}{3}\,\frac{u}{R_\mathrm{g}/(\bar{\mu}\,u_\mathrm{erg})},

where :math:`u_\mathrm{erg}` is the code unit of specific energy. The number
density is approximated as :math:`n \approx (5/7)\,\rho/m_\mathrm{p}`,
consistent with a gas dominated by H\ :sub:`2`.

**Fine-structure line cooling** uses a three-level model for each species
(O I, C II, Si II). The level populations are solved from the steady-state
balance equations including collisional excitation by H, H\ :sub:`2`, and
electrons, radiative decay, and an approximate treatment of stimulated emission.
The resulting emissivities are tabulated as a function of temperature.

**CO rotational cooling** is computed using the escape-probability formalism
at temperatures 10–2000 K, with rates tabulated as a function of :math:`T` and
CO column density :math:`N_\mathrm{CO}`. The effective column density is
derived from the local line-of-sight length ``dlq`` and the velocity gradient
via

.. math::

   N_\mathrm{CO,eff} = n_\mathrm{CO}\,l_\mathrm{eff}
   \approx \frac{n_\mathrm{CO}}{|\nabla\cdot\mathbf{v}| / c_s},

following the large-velocity-gradient (LVG) approximation.

**Photoelectric heating** (``iphoto = 0``) follows the Bakes & Tielens (1994)
functional form scaled to the Habing UV field strength ``uv_field_strength``
:math:`G_0`:

.. math::

   \Gamma_\mathrm{PE} \propto G_0\,\epsilon(G_0,\,n_e,\,T)\,n_\mathrm{H},

where :math:`\epsilon` is the photoelectric heating efficiency. For
``iphoto = 1`` an attenuation factor :math:`\exp(-A_V)` is applied using the
visual extinction computed from the column density and ``AV_conversion_factor``.

References
----------

Bakes, E. L. O. & Tielens, A. G. G. M. 1994, ApJ, 427, 822
(not yet in phantom.bib)

Glover, S. C. O. & Mac Low, M.-M. 2007, ApJS, 169, 239
(not yet in phantom.bib)

Neufeld, D. A. & Kaufman, M. J. 1993, ApJ, 418, 263 (not yet in phantom.bib)

Sembach, K. R. et al. 2000, ApJ, 528, 310 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_ism.f90
