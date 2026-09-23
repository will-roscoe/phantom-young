Behaviour-changing modifications in the phantom-young fork
=============================================================

This fork of Phantom is based on Alison Young's ``054bc4e38``. Of that base, the
``lumdisc=1`` luminosity-radiative temperature path, the tabulated
``eos_stamatellos`` equation of state, and the ``cooling_radapprox``
(Stamatellos/Lombardi) radiative-cooling approximation are **pre-existing** —
see :doc:`radiation` and :doc:`eos` — and are not among the modifications
documented here.

This page is an umbrella summary of the four behaviour-changing modifications
this fork adds on top of that base: comoving mass loading, a sink-count stop
condition, a configurable temperature slope for the existing
``lumdisc``/``ieos=24`` discs, and a floored power-law temperature profile
(``lumdisc=2``) that generalizes the slope into a fully self-consistent
profile. Each section below gives the purpose, parameters, governing
equations, and implementation files for one feature.

Feature 1 — Comoving mass loading (``mass_loading``)
------------------------------------------------------

Purpose
^^^^^^^

Models the accretion of ambient gas onto a disc by increasing the mass of
every gas particle equally each timestep ("comoving": per-particle mass
grows, particle count :math:`n_p` fixed). Reference: Mercer & Stamatellos
(2020).

Parameters
^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 18 12 70

   * - ``.in`` parameter
     - Default
     - Meaning
   * - ``iload_factor``
     - ``-1``
     - Loading mode: ``-1`` off, ``0`` = :math:`\chi` (fraction of
       :math:`M_{\mathrm{disc,0}}` per interval), ``1`` = :math:`\xi`
       (absolute mass per interval), ``2`` = :math:`\beta` (exponential
       factor per interval)
   * - ``iload``
     - —
     - The factor value (:math:`\chi` / :math:`\xi` / :math:`\beta`,
       selected by ``iload_factor``)
   * - ``iload_dt``
     - —
     - Loading interval :math:`T` [code units]; ``<= 0`` uses the Keplerian
       orbital period at ``R_load``
   * - ``R_load``
     - —
     - Loading radius [code units]; ``< 0`` uses the disc reference radius
       ``R_ref``

Dump-header (restart safety):

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Dump-header key
     - Meaning
   * - ``dm_load``
     - :math:`\xi`
   * - ``r_orb``
     - Reference orbital radius :math:`R` used to evaluate :math:`T`
   * - ``R_load``
     - Persisted copy of the ``.in`` loading radius
   * - ``mload_mp0``
     - :math:`m_{p,0}`, the particle mass at :math:`t_{\mathrm{init}}`
   * - ``mload_tinit``
     - :math:`t_{\mathrm{init}}`, the time mass loading was (re)initialised

Equations
^^^^^^^^^

Constant modes (0/1), following Mercer & Stamatellos (2020):

.. math::

   \dot M = \frac{\xi}{T}, \qquad \xi = \chi\, M_{\mathrm{disc,0}}, \qquad
   T = t_{\mathrm{orb}}(R) = \frac{2\pi R^{3/2}}{\sqrt{G M_\star}} \quad (G=1)

.. math::

   M_{\mathrm{disc}}(t) = M_{\mathrm{disc,0}} + \dot M\, t

.. math::

   m_p(t) = m_{p,0} + \frac{\xi\,(t - t_{\mathrm{init}})}{T\, n_{p,0}}

Exponential mode (2):

.. math::

   M(t) = M_{\mathrm{disc,0}}\, \exp\!\left[\frac{\ln(1+\beta)\,(t-t_{\mathrm{init}})}{T}\right]

.. math::

   m_p(t) = m_{p,0}\, \exp\!\left[\frac{\ln(1+\beta)\,(t-t_{\mathrm{init}})}{T}\right],
   \qquad \frac{M(t+T)}{M(t)} = 1+\beta

Mode derivations:

- Mode 0 (:math:`\chi`): ``mloadfactor = iload`` (:math:`\chi`),
  ``dm_load = iload * M_disc0``
- Mode 1 (:math:`\xi`): ``dm_load = iload`` (:math:`\xi`),
  ``mloadfactor = iload / M_disc0``
- Mode 2 (:math:`\beta`): ``mloadfactor = iload`` (:math:`\beta`),
  ``dm_load = 0``

Each particle's mass is evaluated directly from :math:`m_{p,0}` plus elapsed
time at every binstep (no accumulation of round-off). Negative :math:`\xi` /
:math:`\beta` is allowed and drains mass.

Files
^^^^^

New module ``src/main/evolve_massloading.f90``, compile-time optional via
``-DMASS_LOADING`` (logical ``use_mass_loading`` in ``dim``/``config.F90``);
called from ``evolve.F90`` (``evol_prestep``, every binstep) inside
``#ifdef MASS_LOADING``. Also integrated into ``checksetup`` (validation),
``checkconserved`` (suppresses mass/energy conservation warnings while mass
is intentionally being added), ``readwrite_infile`` (``.in`` I/O), and
``readwrite_dumps_common`` (dump-header I/O).

Feature 2 — Sink-count stop condition (``stopcond``)
------------------------------------------------------

Purpose
^^^^^^^

Stops the run once ``max_created_sinks`` new sink particles have formed since
:math:`t=0`. On the dump that trips the condition, that dump is promoted to a
full dump; the run then exits cleanly, or, if an extra window is configured,
continues for that window (every dump in it full) and exits when it ends.

Parameters
^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 30 12 58

   * - Parameter
     - Default
     - Meaning
   * - ``max_created_sinks`` (``.in``)
     - ``-1``
     - Stop after this many sinks have formed since :math:`t=0`; ``-1`` = off
   * - ``stop_extra_wall`` (``.in``)
     - ``-1``
     - Wall hours to continue after the condition trips; ``<0`` = no window
   * - ``stop_extra_time`` (``.in``)
     - ``-1``
     - Ceiling on the same window in code time; ``<0`` = none. Whichever bound
       is reached first ends the run
   * - ``nptmass0`` (dump header)
     - —
     - Baseline sink count captured at :math:`t=0`, so the "since
       :math:`t=0`" count survives restarts
   * - ``t_trip``, ``wall_in_window`` (dump header)
     - —
     - When the condition tripped, and the wall seconds already spent in the
       window, so a restart resumes the window instead of starting it again

A runtime flag ``stopcond_triggered`` is read by ``evolve``.

Equation
^^^^^^^^

.. math::

   n_{\mathrm{ptmass}} - n_{\mathrm{ptmass,0}} \ge \texttt{max\_created\_sinks}

Logic
^^^^^

- ``init_stopcond(nptmass)`` captures ``nptmass0`` once — only when its
  stored value is negative — so restarts keep the header value rather than
  re-capturing it.
- ``check_stopcond(nptmass, time, fulldump)`` is evaluated at every dump-write;
  when the condition above holds it sets ``fulldump = .true.``, and sets
  ``stopcond_triggered = .true.`` at once if no window is configured, or when
  the window's wall or code-time bound is reached.
- No-op when disabled (``max_created_sinks < 0``) or before the baseline has
  been captured.

Files
^^^^^

New module ``src/main/stopcond.f90``. Integrated into ``evolve.F90`` (reads
``stopcond_triggered``), ``checksetup``, ``readwrite_infile`` (``.in``), and
``readwrite_dumps_common`` (dump header).

Feature 3 — Configurable temperature slope (``qprofile``) for lumdisc / ieos=24
----------------------------------------------------------------------------------

Purpose
^^^^^^^

Extends Alison Young's ``lumdisc=1`` luminosity-radiative disc by exposing
its temperature power-law slope as a user-settable parameter. The module
variable ``eos_stamatellos:qprofile`` (public, default ``0``) is read from
both the ``.setup`` file (``setup_disc``) and the ``.in`` file
(``cooling_radapprox``), and is applied consistently in both places.

By default :math:`q=0.25`, i.e. :math:`T\propto R^{-0.5}`. Setting
``qprofile > 0`` sets :math:`q=\texttt{qprofile}`, giving

.. math::

   q = \begin{cases} \texttt{qprofile}, & \texttt{qprofile} > 0 \\
                      0.25,              & \text{otherwise} \end{cases}
   \qquad\Longrightarrow\qquad T \propto R^{-2q}

This is applied consistently to **both** the setup initial condition (via
``qindex``, feeding the :math:`r^{-8q}` irradiation temperature term in
``get_cs_from_lum`` / ``get_T_from_lum`` / ``get_u_stamatellos``):

.. math::

   T_{\mathrm{irr}}^4 \propto r^{-8q}

**and** the runtime cooling floor (``q_eff = qprofile``):

.. math::

   T_{\mathrm{mini}}^4 \propto r^{-8q}

The slope relates to the Mercer & Stamatellos convention's T-slope
:math:`\beta_T` by

.. math::

   \beta_T = 2q

so :math:`q=0.35 \Rightarrow \beta_T = 0.7`.

Also added: ``get_Lstar_from_mass(mass_solar)`` in ``setup_disc.F90`` — a
piecewise mass–luminosity relation used to seed the interactive default of
the disc ``L_star``:

.. math::

   L_\star(m) =
   \begin{cases}
   0.23\, m^{2.3}, & m < 0.43 \\
   m^{4},          & 0.43 \le m < 2 \\
   1.4\, m^{3.5},  & 2 \le m < 55 \\
   32000\, m,      & m \ge 55
   \end{cases}

where :math:`m` is the mass in solar masses.

Parameters
^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 20 30 12 38

   * - Parameter
     - Set in
     - Default
     - Meaning
   * - ``qprofile``
     - ``.setup`` (``setup_disc``) and ``.in`` (``cooling_radapprox``)
     - ``0``
     - Temperature power-law slope index; ``qprofile > 0`` overrides the
       default :math:`q=0.25`
   * - ``q`` / ``q_eff`` (internal)
     - —
     - ``0.25``
     - Effective slope used by ``qindex`` (setup IC) and the runtime floor;
       equals ``qprofile`` when set

Files
^^^^^

``eos_stamatellos.f90`` (module variable ``qprofile``), ``setup_disc.F90``
(``.setup`` read, ``qindex``, ``get_Lstar_from_mass``), and
``cooling_radapprox.f90`` (``.in`` read, runtime ``q_eff``). Commits
``a6433960b``, ``4d27a74f8``. There is no dedicated dump-header entry for
``qprofile`` at this stage — it is only added to the dump header as part of
Feature 4, below.

Feature 4 — Floored power-law temperature profile (``lumdisc=2``)
----------------------------------------------------------------------

Purpose
^^^^^^^

Generalizes Feature 3 into a self-consistent profile, selected by
``lumdisc=2`` (internal ``iprofile=2``). A single analytic function
``eos_stamatellos:get_T_profile(r)`` is used identically by the disc initial
condition (``set_disc``) and the cooling floor (``cooling_radapprox``), so
floor == IC by construction. The Mercer & Stamatellos (2020) profile (their
Eq. 8) is the ``n=2`` preset.

.. math::

   T(R) = \left[\, T_0^{\,n}\left(R_{\mathrm{AU}}^2+R_0^2\right)^{-nq}
          + T_\infty^{\,n}\,\right]^{1/n}

where :math:`R_{\mathrm{AU}} = R\,\mathrm{udist}/\mathrm{au}` and
:math:`q = q_{\mathrm{eff}} = \texttt{qprofile}` if ``qprofile > 0``, else
:math:`0.35`.

- :math:`n=2` gives the MS20 quadrature
  :math:`T^2 = T_0^2(R_{\mathrm{AU}}^2+R_0^2)^{-2q} + T_\infty^2` (Eq. 8,
  slope :math:`\beta_T=2q`).
- :math:`n=4,\ R_0\to0` gives the flux-addition (:math:`T^4`) form,
  normalised by :math:`T_0` rather than a stellar luminosity.
- Irradiation-dominated regime: :math:`T \propto R^{-2q}`; the floor
  :math:`T \to T_\infty` at large :math:`R`.

Parameters
^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 18 18 12 52

   * - ``.setup`` key
     - Internal
     - Default
     - Meaning
   * - ``lumdisc``
     - ``iprofile``
     - ``1``
     - ``2`` selects the floored power-law profile
   * - ``T0``
     - ``T0_prof``
     - ``100.``
     - Normalisation temperature at 1 AU (K)
   * - ``nprof``
     - ``n_prof``
     - ``2.``
     - Combination index
   * - ``R0``
     - ``R0_prof``
     - ``0.01``
     - Inner smoothing radius (AU)
   * - ``qprofile``
     - ``qprofile``
     - ``0.``
     - Slope index (reused from Feature 3); ``0`` gives
       :math:`q_{\mathrm{eff}}=0.35`
   * - ``T_bg``
     - ``T_bg_prof`` (``Tinf``)
     - ``10.``
     - Background temperature :math:`T_\infty` (K)

``L_star`` is not used for temperature in this mode.

Restart safety and files
^^^^^^^^^^^^^^^^^^^^^^^^^

These IC-defining parameters are **not** stored in the ``.in`` file. They
are written to, and read back from, the dump header on every full dump via
``write_headeropts_flooredprof`` / ``read_headeropts_flooredprof`` (header
keys ``iprofile, T0_prof, nprof, R0_prof, Tinf, qprofile``), hooked into
``fill_header`` / ``unfill_rheader`` in ``readwrite_dumps_common``.

The MS20 preset is ``lumdisc=2, nprof=2, qprofile=0.35, T0=100, R0=0.01,
T_bg=10``.

For the full governing-equation derivation, hydrodynamics coupling, usage
examples, and test coverage, see :doc:`floored-power-law-profile`.

References
----------

- Mercer, A. & Stamatellos, D. 2020, A&A, 633, A116.
- Stamatellos, D., Whitworth, A. P., Bisbas, T. & Goodwin, S. 2007, A&A, 475, 37.
- Lombardi, J. C., McInally, W. G. & Faber, J. A. 2015, MNRAS, 447, 25.
