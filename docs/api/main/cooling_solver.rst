.. phantom-doc: hand-written

cooling_solver
==============

Overview
--------

The ``cooling_solver`` module provides a generic integrator for analytic cooling
functions with known logarithmic temperature derivatives. It is the backbone of
the ``icooling = 1`` (implicit) and ``icooling = 2`` (explicit) cooling library
options in Phantom, and supports three distinct integration methods: explicit
forward differencing, implicit bisection, and the exact (Townsend 2009) method.

The module assembles the total cooling rate from a combination of physical
processes selected by boolean flags:

- ``excitation_HI``: cooling by electron excitation of neutral hydrogen.
- ``relax_Bowen``: Bowen (1988) diffusive relaxation toward a dust temperature.
- ``dust_collision``: gas–dust collision energy exchange.
- ``relax_Stefan``: radiative relaxation via the Stefan–Boltzmann law.
- ``shock_problem``: piecewise analytic cooling law for shock benchmark tests.

The rate evaluation is centralised in ``calc_cooling_rate``, which calls the
appropriate functions from ``cooling_functions``, accumulates the individual
contributions, and computes the composite logarithmic derivative
:math:`\mathrm{d}\ln Q/\mathrm{d}\ln T`. This derivative is essential for the
implicit bisection solver and for the piecewise power-law approximation used
by the Townsend exact method.

A utility function ``calc_Q`` computes the full suite of cooling and heating
rates from ``cooling_functions`` (including molecular species) for diagnostic
and post-processing purposes. A companion function ``calc_dlnQdlnT`` estimates
the numerical logarithmic derivative by centred finite differences. The test
harness ``testfunc`` and diagnostic printer ``print_cooling_rates`` are provided
for development and verification.

The Townsend (2009) exact method pre-computes a temperature grid of ``nTg = 64``
logarithmically spaced points from 10 K to ``Tref`` (default :math:`10^7` K)
at initialisation. For the shock-problem benchmark the grid upper boundary is
adjusted to fall just below the cooling function's upper cutoff temperature.

Physical & Mathematical Description
-------------------------------------

The energy equation for each SPH particle in the cooling sub-step is

.. math::

   \frac{\mathrm{d}u}{\mathrm{d}t} = Q(T,\,\rho,\,T_\mathrm{dust},\,\ldots),

where :math:`Q < 0` for net cooling. The temperature–energy relation is

.. math::

   T = \frac{(\gamma-1)\,\mu\,u_\mathrm{erg}}{R_\mathrm{g}}\,u,

with :math:`u_\mathrm{erg}` the code unit of specific energy and
:math:`R_\mathrm{g}` the specific gas constant.

**Explicit integration** evaluates :math:`Q` at the current temperature and
applies a forward-Euler update:

.. math::

   u^{n+1} = u^n + Q(T^n)\,\Delta t,

with a fallback to thermal equilibrium (:math:`T = T_\mathrm{dust}`) if
:math:`u^{n+1} < 0`.

**Implicit integration** seeks :math:`T^{n+1}` such that

.. math::

   T^{n+1} - T^n - Q(T^{n+1})\,\Delta t\,\frac{(\gamma-1)\mu\,u_\mathrm{erg}}{R_\mathrm{g}} = 0

by bisection. An initial bracketing interval is constructed by iterating the
explicit step until the residual changes sign, then bisected to relative
tolerance :math:`10^{-6}` within at most 40 iterations.

**Exact (Townsend 2009) integration** eliminates the timestep constraint by
analytically integrating the cooling ODE using a piecewise power-law
approximation to :math:`Q(T)` on each temperature interval of the pre-computed
grid. The key quantity is the Townsend cooling function :math:`\mathcal{Y}(T)`,
defined by

.. math::

   \mathcal{Y}(T) = -\frac{Q_\mathrm{ref}\,T_\mathrm{ref}}{T_\mathrm{ref}}
   \int_{T}^{T_\mathrm{ref}} \frac{\mathrm{d}T'}{Q(T')\,T'},

which is computed piecewise on the temperature grid. For each interval
:math:`[T_k, T_{k+1}]` where
:math:`Q \propto T^{\alpha_k}` (with
:math:`\alpha_k = \mathrm{d}\ln Q/\mathrm{d}\ln T`):

.. math::

   \mathcal{Y}_{k+1} - \mathcal{Y}_k =
   \begin{cases}
   -\dfrac{Q_\mathrm{ref}\,T_k}{Q_k\,T_\mathrm{ref}}\,
   \ln\!\left(\dfrac{T_k}{T_{k+1}}\right)
   & \alpha_k = 1, \\[8pt]
   -\dfrac{Q_\mathrm{ref}\,T_k}{Q_k\,T_\mathrm{ref}\,(1-\alpha_k)}
   \left[1 - \left(\dfrac{T_k}{T_{k+1}}\right)^{\alpha_k-1}\right]
   & \alpha_k \neq 1.
   \end{cases}

The updated temperature is found by inverting :math:`\mathcal{Y}` at
:math:`\mathcal{Y}(T^n) + \Delta\mathcal{Y}`, where
:math:`\Delta\mathcal{Y} = -Q_\mathrm{ref}\,\Delta t / T_\mathrm{ref}`.

The composite logarithmic derivative used in ``calc_cooling_rate`` is

.. math::

   \frac{\mathrm{d}\ln Q}{\mathrm{d}\ln T} =
   \frac{\sum_i Q_i\,(\mathrm{d}\ln Q_i/\mathrm{d}\ln T)}{\sum_i Q_i},

a rate-weighted average over all active cooling processes.

Derivations
-----------

**Townsend piecewise inversion.** Given that :math:`Q \approx Q_k(T/T_k)^{\alpha_k}`
on interval :math:`k`, the indefinite integral of :math:`1/(Q\,T)` over that
interval is elementary. For :math:`\alpha_k \neq 1`:

.. math::

   \int_{T_k}^{T} \frac{\mathrm{d}T'}{Q(T')\,T'} =
   \frac{1}{Q_k\,(\alpha_k-1)}\left[\left(\frac{T}{T_k}\right)^{\alpha_k-1} - 1\right].

Inversion of :math:`\mathcal{Y}` at a given level :math:`y` within interval
:math:`k` (equations A7 of Townsend 2009) yields:

.. math::

   T = T_k\left[1 - \frac{(1-\alpha_k)\,Q_k\,T_\mathrm{ref}}
   {Q_\mathrm{ref}\,T_k}\,(y - \mathcal{Y}_k)\right]^{1/(1-\alpha_k)}.

The special case :math:`\alpha_k = 1` gives :math:`T = T_k\exp[\ldots]`.
Both cases are implemented in ``exact_cooling`` and bounded below by a
temperature floor to prevent runaway cooling.

References
----------

Townsend, R. H. D. 2009, ApJS, 181, 391 (not yet in phantom.bib)

Bowen, G. H. 1988, ApJ, 329, 299 (not yet in phantom.bib)

Young, M. D. et al. 2024 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_solver.f90
