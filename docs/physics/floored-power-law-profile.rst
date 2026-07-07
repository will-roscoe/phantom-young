Floored power-law temperature profile (``lumdisc=2``)
=====================================================

Overview
--------

The floored power-law profile is a generalized disc temperature prescription for
radiatively-cooled discs (``ieos=24`` / ``icooling=9``), selected with the
disc-setup option ``lumdisc = 2`` (internally ``iprofile = 2``).  It supplies a
single analytic temperature law ``get_T_profile(r)`` that is used **identically**
by the disc initial condition (``set_disc``) and by the runtime radiative-cooling
floor (``cooling_radapprox``), so the two are consistent by construction — the
disc is *floored on the same law it was built with*.

The **Mercer & Stamatellos (2020)** temperature profile (their Eq. 8) is the
``nprof = 2`` preset.  The legacy ``lumdisc = 1`` luminosity-radiative path is
unchanged and remains the default.

Governing equation
-------------------

.. math::

   T(R) = \left[\, T_0^{\,n}\,\left(R_{\mathrm{AU}}^2 + R_0^2\right)^{-n q}
          + T_\infty^{\,n} \,\right]^{1/n}

where :math:`R_{\mathrm{AU}} = R\,\mathrm{udist}/\mathrm{au}` is the radius in
astronomical units, :math:`n` is the combination index (``nprof``), and the slope
index is

.. math::

   q_{\mathrm{eff}} = \begin{cases} \texttt{qprofile}, & \texttt{qprofile} > 0 \\
                                    0.35,             & \text{otherwise} \end{cases}

Limiting behaviour:

- In the irradiation-dominated regime :math:`T \propto R^{-2q}`
  (:math:`q=0.35 \Rightarrow T\propto R^{-0.70}`), flattening to :math:`T\to T_\infty`
  at large radius.
- :math:`R_0` softens the profile as :math:`R\to 0`; negligible for
  :math:`R_{\mathrm{in}} \gtrsim 1\,\mathrm{AU}`.
- :math:`n=2` recovers the **MS20 quadrature law**
  :math:`T^2 = T_0^2 (R_{\mathrm{AU}}^2+R_0^2)^{-2q} + T_\infty^2`, i.e. Mercer &
  Stamatellos (2020) Eq. 8 with slope :math:`\beta_T = 2q`.
- :math:`n=4,\ R_0\to 0` recovers the flux-addition (:math:`T^4`) form, normalised
  by :math:`T_0` instead of a stellar luminosity.

Coupling to the hydrodynamics
-----------------------------

**Initial condition.**  Each gas particle is assigned
:math:`T = \texttt{get\_T\_profile}(R)`; the internal energy is obtained through
the tabulated Stamatellos EOS, :math:`u = \texttt{getintenerg\_opdep}(T,\rho)`
(which includes H\ :sub:`2` rotation/vibration, H\ :sub:`2` dissociation and H/He
ionisation), the sound speed is
:math:`c_s = \sqrt{\gamma\, k_{\mathrm B} T / (\mu m_{\mathrm H})}/\mathrm{unit\_velocity}`
with :math:`\mu = 2.381`, and the scale height is :math:`H = c_s/\Omega`.

**Runtime cooling floor.**  The background temperature the gas cannot radiatively
cool below is set directly to the profile,
:math:`T_{\mathrm{BGR}}(R) = \texttt{get\_T\_profile}(\sqrt{r_i^2})`, and enters
the Stamatellos (2007) / Lombardi (2015) radiative-approximation cooling

.. math::

   \frac{\mathrm{d}u_i}{\mathrm{d}t} =
   \frac{4\sigma\!\left(T_{\mathrm{BGR}}^4 - T_i^4\right)}
        {\bar\Sigma_i^2\,\kappa_{\mathrm B}(\rho_i,T_i) + \kappa_{\mathrm P}(\rho_i,T_i)^{-1}} .

For ``iprofile=2`` the floor uses the profile **without** the ``exp(-tau)``
optical-depth attenuation and **without** a separate ``Tfloor**4`` term that the
legacy ``iprofile=1`` branch applies — the background :math:`T_\infty` is already
inside the profile.  The IC and floor therefore evaluate the same function with
the same parameters (**floor == IC**).

Parameters
----------

.. list-table::
   :header-rows: 1
   :widths: 14 16 10 60

   * - ``.setup`` key
     - Internal
     - Default
     - Meaning
   * - ``lumdisc``
     - —
     - ``0``
     - ``0`` = off, ``1`` = luminosity radiative (legacy), ``2`` = floored power-law
   * - ``T0``
     - ``T0_prof``
     - ``100.``
     - normalisation temperature at 1 AU (K)
   * - ``nprof``
     - ``n_prof``
     - ``2.``
     - combination index (``2`` = MS20 T², ``4`` = flux-add T⁴)
   * - ``R0``
     - ``R0_prof``
     - ``0.01``
     - inner smoothing radius (AU)
   * - ``qprofile``
     - ``qprofile``
     - ``0.``
     - slope index, :math:`T\propto R^{-2q}`; ``0`` gives :math:`q_{\mathrm{eff}}=0.35`
   * - ``T_bg``
     - ``T_bg_prof`` (``Tinf``)
     - ``10.``
     - background temperature :math:`T_\infty` (K)
   * - —
     - ``iprofile``
     - ``1``
     - internal mode (``2`` when ``lumdisc=2``)

In mode 2, ``L_star`` is not used for temperature.

Restart safety (dump-header propagation)
----------------------------------------

The IC-defining parameters are **not** stored in the ``.in`` file.  They are
written to, and read back from, the **dump header** on every full dump via
``write_headeropts_flooredprof`` / ``read_headeropts_flooredprof`` (header keys
``iprofile, T0_prof, nprof, R0_prof, Tinf, qprofile``), hooked into ``fill_header``
and ``unfill_rheader`` in ``readwrite_dumps_common``.  Consequently:

- the runtime cooling floor uses exactly the values the IC was built with;
- editing the ``.in`` between restarts cannot desync the floor from the frozen
  disc state;
- the values persist across every full dump, so a restart from any dump is exact.

This mirrors the ``mass_loading`` module, which persists its restart-critical
state (``dm_load``, ``r_orb``, ``m_p0``, ``t_init``) in the dump header rather than
the ``.in``.  Legacy dumps written before this feature (no ``iprofile`` header key)
default to ``iprofile = 1`` and are read unchanged.

Usage
-----

Set in the ``.setup``::

   lumdisc  = 2        ! floored power-law
   T0       = 100.     ! K at 1 AU
   nprof    = 2.       ! MS20
   R0       = 0.01     ! AU
   qprofile = 0.35     ! slope T ~ R^-0.70
   T_bg     = 10.      ! K background

Run ``phantomsetup`` (writes the IC dump, ``.in`` and ``.discparams``) then
``phantom`` (restores the profile from the dump header).  To revert to the legacy
behaviour, set ``lumdisc = 1``.

The **MS20 preset** is ``lumdisc=2, nprof=2, qprofile=0.35, T0=100, R0=0.01,
T_bg=10``.

Implementation summary
----------------------

- ``eos_stamatellos.f90`` — profile state, ``get_T_profile(r)``,
  ``write/read_headeropts_flooredprof``.
- ``set_disc.f90`` — IC ``cs``/``u``/``T`` branched on ``iprofile==2``.
- ``setup_disc.F90`` — ``lumdisc==2`` selection and ``T0``/``nprof``/``R0`` I/O.
- ``cooling_radapprox.f90`` — floor branched on ``iprofile==2``.
- ``readwrite_dumps_common.f90`` — dump-header hooks.
- ``test_flooredprof.f90`` (+ ``testsuite.f90``, ``build/Makefile``) — unit test.

Testing
-------

``phantomtest flooredprof`` checks ``get_T_profile`` at 1/10/1000 AU and a
``qprofile`` override.  Integration tests confirm ``lumdisc=1`` reproduces the
original discparams, ``lumdisc=2`` matches ``get_T_profile`` to ``<0.1%``, a
``T_bg=20`` run keeps floor == IC (dump header carries ``Tinf=20``), and the
parameters persist from the setup dump into a subsequent full dump.

References
----------

- Mercer, A. & Stamatellos, D. 2020, A&A, 633, A116.
- Stamatellos, D., Whitworth, A. P., Bisbas, T. & Goodwin, S. 2007, A&A, 475, 37.
- Lombardi, J. C., McInally, W. G. & Faber, J. A. 2015, MNRAS, 447, 25.
- Young, M. D. et al. 2024.
