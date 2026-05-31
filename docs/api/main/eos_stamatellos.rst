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

Derivations
-----------

The effective adiabatic index is derived at each SPH particle location from

.. math::

   \gamma = 1 + \frac{P}{\rho\,u} = 1 + \frac{(k_B/\mu m_H)\,T}{u}

using the table-interpolated values of :math:`T` and :math:`\mu`.  No analytic
differentiation of the table is performed; the sound speed is then
:math:`c_s = \sqrt{\gamma P/\rho}`.

MS20 initial temperature profile (``iprofile = 2``)
---------------------------------------------------

In addition to the tabulated EOS, the module hosts the analytic disc
temperature profile of Mercer & Stamatellos (2020, Eq. 8), exposed as the
``pure`` function ``get_T_MS20(r)``:

.. math::

   T(R) = \left[\,T_0^2
   \left(\frac{R^2 + R_0^2}{\mathrm{AU}}\right)^{-0.7}
   + T_\infty^2\,\right]^{1/2}

where :math:`R` is the cylindrical (setup) or spherical (cooling) radius,
:math:`T_0` is the temperature at 1 AU, :math:`R_0` is a smoothing radius that
caps the temperature near the star, and :math:`T_\infty` is the background
temperature far from the star.  Internally the radius is converted to AU
(``Rau = r*udist/au``) so the profile is independent of the chosen
``dist_unit``.  The fixed exponent ``ms20_exp = 0.7`` is the defining slope of
the profile (:math:`T \propto R^{-0.7}`) and is a ``parameter``, not a runtime
option.

This profile is selected by the module switch ``iprofile``:

.. list-table::
   :header-rows: 1
   :widths: 12 88

   * - ``iprofile``
     - Temperature law used for both the initial condition and the cooling floor
   * - ``1`` (default)
     - Optically-thin radiative equilibrium :math:`T \propto R^{-1/2}`,
       normalised by the stellar luminosity (the original behaviour).
   * - ``2``
     - MS20 Eq. 8 above, normalised by ``T0_ms20`` and independent of
       :math:`L_\star`.

The associated module variables ``T0_ms20``, ``R0_ms20`` and ``Tinf_ms20``
hold :math:`T_0`, :math:`R_0` and :math:`T_\infty`.  They are set at setup time
by ``setup_disc`` when ``lumdisc = 2`` (mapping the disc ``T_bg`` onto
:math:`T_\infty`) and are written to / read from the ``.in`` file by
:doc:`cooling_radapprox`, so the runtime cooling floor reproduces the same
profile that was baked into the initial dump.  See :doc:`cooling_radapprox` for
the role of this profile as the background floor :math:`T_{\rm BGR}` in the
Eq. 4 cooling rate.

.. note::

   For the cooling floor, ``Tinf_ms20`` is synchronised to the runtime
   ``Tfloor`` (not ``T_bg``).  To keep the floor consistent with the initial
   condition, set ``Tfloor`` in the ``.in`` file equal to the ``T_bg`` used at
   setup (both equal :math:`T_\infty`, e.g. 10 K).

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Stamatellos, D., Whitworth, A. P., Bisbas, T. & Goodwin, S. 2007, A&A, 475, 37 — pseudo-cloud radiative cooling approximation
- Mercer, A. & Stamatellos, D. 2020, A&A, 633, A116 — disc initial temperature profile (Eq. 8), used by ``iprofile = 2``
- Young, A. K. et al. 2024 — updated tabulated cooling method for Phantom (icooling=9)
- Lombardi, J. C. et al. 2015, MNRAS, 447, 25 — opacity/EoS table (eos_lom.dat source)
- Forgan, D., Rice, K., Stamatellos, D. & Whitworth, A. 2009, MNRAS, 394, 882 — FLD hybrid cooling method

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_stamatellos.f90
