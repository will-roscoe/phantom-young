.. phantom-doc: hand-written

eos_stamatellos — Tabulated Opacity/EoS for Radiative Cooling (ieos = 24)
=========================================================================

Overview
--------

The ``eos_stamatellos`` module provides the tabulated equation-of-state and opacity
infrastructure used by the ``icooling = 9`` radiative cooling approximation in
Phantom (the method of Stamatellos et al. 2007, as extended by Young et al. 2024).
Rather than solving the full radiation-transport problem, this approach approximates
the local cooling rate by evaluating the flux that would escape from a pseudo-cloud
of local conditions, using the optical depth to the nearest boundary as a proxy for
the column depth through which radiation must diffuse.

The EOS is selected by ``ieos = 24``.  At initialisation, ``read_optab`` reads a
multi-column ASCII table (default filename ``eos_lom.dat``, based on Lombardi et al.
2015) containing :math:`(\rho, T, u, \mu, \kappa_P, \kappa_R)` on a rectangular
grid in density and internal energy.  The ``getopac_opdep`` routine interpolates this
table to return the Planck-mean opacity :math:`\kappa_P`, Rosseland-mean opacity
:math:`\kappa_R`, temperature :math:`T`, and mean molecular weight :math:`\mu` at
any :math:`(\rho, u)` point.  The master dispatcher in :doc:`eos` then uses these
to compute the ideal-gas pressure and sound speed:

.. math::

   P = \frac{k_B}{\mu\,m_H}\,\rho\,T, \qquad
   c_s = \sqrt{\gamma\,P/\rho}

where :math:`\gamma = 1 + P/(\rho\,u)` is computed self-consistently from the
table.

In addition to the EOS function, the module allocates and manages per-particle
arrays used by the cooling integrator: thermal timescale ``ttherm_store``,
equilibrium energy ``ueqi_store``, optical depth ``tau_store``, and the
flux-limited diffusion (FLD) arrays (``duFLD``, ``lambda_FLD``, ``urad_FLD``)
used by the optional Forgan et al. (2009) hybrid cooling method.

Physical & Mathematical Description
-------------------------------------

**Table structure.**  The table ``eos_lom.dat`` is an ASCII file with :math:`N_\rho
\times N_u` rows, each containing six columns:

.. math::

   (\rho,\ T,\ u,\ \mu,\ \kappa_P,\ \kappa_R)

in CGS units (density in g cm\ :sup:`-3`, energy in erg g\ :sup:`-1`, opacity in
cm\ :sup:`2` g\ :sup:`-1`).  The table is read into the three-dimensional array
``optable(nx, ny, 6)``.

**Interpolation.**  Given :math:`(\rho_i, u_i)`, the module performs a binary
search along each axis to locate the enclosing cell, then bilinear interpolation:

.. math::

   f(\rho_i, u_i) =
   f_{00} + (f_{10}-f_{00})\,\frac{\rho_i - \rho_j}{\rho_{j+1}-\rho_j}
          + (f_{01}-f_{00})\,\frac{u_i - u_k}{u_{k+1}-u_k}
          + \cdots

(standard bilinear form).  Out-of-range inputs trigger a warning but are not
fatal; the boundary value is returned.

**Equilibrium energy.**  ``getintenerg_opdep`` inverts the :math:`T \to u` relation
by interpolating the :math:`u(T, \rho)` slice of the table, returning the specific
internal energy :math:`u_{\rm eq}` that corresponds to a given equilibrium
temperature :math:`T_{\rm eq}`.

Floored power-law profile (``lumdisc=2`` / ``iprofile=2``)
------------------------------------------------------------

In addition to the legacy luminosity-derived radiative floor (``lumdisc=1``),
the module provides a purely analytic "floored power-law" temperature profile
selected by ``iprofile = 2`` (set automatically when the disc-setup option
``lumdisc = 2``).  The profile is evaluated by ``get_T_profile(r)``:

.. math::

   T(R) = \left[\, T_0^{\,n}\,\bigl(R_{\rm au}^2 + R_0^2\bigr)^{-n\,q_{\rm eff}}
                 + T_{\rm bg}^{\,n} \,\right]^{1/n}

where :math:`R_{\rm au}` is the radius in AU (converted from code units via
``udist``/``au``, so it is robust to any ``dist_unit``), and
:math:`q_{\rm eff} = q_{\rm profile}` if ``qprofile > 0``, otherwise the
default :math:`q_{\rm eff}=0.35` — the same ``merge`` rule used to set the
irradiation slope in the legacy (``iprofile=1``) branch.

**Parameters** (module-level, in :f:mod:`eos_stamatellos`):

======================  =======================================================
Parameter                Meaning
======================  =======================================================
``T0`` (``T0_prof``)     Normalisation temperature at 1 AU (K)
``nprof`` (``n_prof``)   Combination index :math:`n`: ``2`` gives an MS20-style
                         :math:`T^2` quadrature sum, ``4`` gives a flux-additive
                         :math:`T^4` sum
``R0`` (``R0_prof``)     Inner smoothing radius (AU), regularises the profile
                         as :math:`R\to 0`
``qprofile``             Reused from the legacy branch: overrides
                         :math:`q_{\rm eff}` when ``> 0`` (default ``0.35``
                         when unset)
``T_bg`` (``T_bg_prof``) Reused from the legacy branch: background/floor
                         temperature :math:`T_{\rm bg}` at large :math:`R`
======================  =======================================================

The MS20 preset (Stamatellos-style outer-disc floor) corresponds to
``nprof=2``, ``qprofile=0.35``, ``T0=100``, ``R0=0.01``, ``T_bg=10``.

**Floor == IC, no** ``exp(-tau)`` **shielding.**  When ``iprofile=2``, both the
disc initial condition (:f:mod:`set_disc`, via ``get_T_profile`` at setup
time) and the runtime cooling floor (:f:mod:`cooling_radapprox`, via
``Tmini4 = get_T_profile(r)**4``) call the *same* function with the *same*
parameters.  Unlike the ``iprofile=1`` branch — where the floor is attenuated
by ``exp(-coldensi*kappaBari)`` optical-depth shielding of the stellar flux —
the floored power-law profile is applied directly with no optical-depth
attenuation: the particle temperature floor at any radius is, by
construction, identical to the temperature the disc was initialised with at
that radius.

Derivations
-----------

The effective adiabatic index is derived at each SPH particle location from

.. math::

   \gamma = 1 + \frac{P}{\rho\,u} = 1 + \frac{(k_B/\mu m_H)\,T}{u}

using the table-interpolated values of :math:`T` and :math:`\mu`.  No analytic
differentiation of the table is performed; the sound speed is then
:math:`c_s = \sqrt{\gamma P/\rho}`.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Stamatellos, D., Whitworth, A. P., Bisbas, T. & Goodwin, S. 2007, A&A, 475, 37 — pseudo-cloud radiative cooling approximation
- Young, A. K. et al. 2024 — updated tabulated cooling method for Phantom (icooling=9)
- Lombardi, J. C. et al. 2015, MNRAS, 447, 25 — opacity/EoS table (eos_lom.dat source)
- Forgan, D., Rice, K., Stamatellos, D. & Whitworth, A. 2009, MNRAS, 394, 882 — FLD hybrid cooling method

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_stamatellos.f90
