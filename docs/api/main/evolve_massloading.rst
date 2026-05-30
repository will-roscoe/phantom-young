.. phantom-doc: hand-written

evolve_massloading
==================

Overview
--------

The ``mass_loading`` module implements comoving mass loading of gas particles
for protoplanetary disc simulations.  Mass loading models the accretion of
ambient gas onto the disc: every loading interval :math:`T` the per-particle
mass is increased (or decreased, for negative factors) according to one of
three modes selected at runtime by ``iload_factor``.

The module is entirely self-contained and compile-time optional.  All call
sites in ``evolve``, ``checksetup``, and ``checkconserved`` are wrapped in
``#ifdef MASS_LOADING / #endif`` guards.  When compiled without
``-DMASS_LOADING``, none of the module code is linked and the simulation runs
as if mass loading were absent.  The ``dim`` (``config.F90``) module exposes a
corresponding compile-time logical ``use_mass_loading``.

**Loading modes** (selected by ``iload_factor``):

.. list-table::
   :header-rows: 1
   :widths: 10 15 20 55

   * - Value
     - Name
     - ``iload`` meaning
     - Behaviour
   * - ``-1``
     - Off
     - —
     - No loading; module initialises but returns immediately.
   * - ``0``
     - Constant :math:`\chi`
     - :math:`\chi` — fraction of :math:`M_{\mathrm{disc},0}` per interval
     - :math:`\xi = \chi M_{\mathrm{disc},0}` is derived; both stored.
   * - ``1``
     - Constant :math:`\xi`
     - :math:`\xi` — absolute mass per interval
     - :math:`\chi = \xi / M_{\mathrm{disc},0}` is back-derived; both stored.
   * - ``2``
     - Exponential :math:`\beta`
     - :math:`\beta` — fractional increase per interval
     - ``dm_load`` is set to zero; ``mloadfactor`` holds :math:`\beta`.

For modes 0 and 1, both ``mloadfactor`` (:math:`\chi`) and ``dm_load``
(:math:`\xi`) are always populated so that simulations run under different
parameterisations can be directly compared.

**Parameter file interface** — three ``.in`` keys only:

.. list-table::
   :header-rows: 1
   :widths: 20 10 15 55

   * - Key
     - Type
     - Default
     - Description
   * - ``iload_factor``
     - integer
     - ``-1``
     - Loading mode (``-1`` = off, ``0`` = :math:`\chi`, ``1`` = :math:`\xi`, ``2`` = :math:`\beta`).
   * - ``iload``
     - real
     - ``0.``
     - Factor value: :math:`\chi`, :math:`\xi`, or :math:`\beta` depending on mode.
   * - ``iload_dt``
     - real
     - ``-1.``
     - Loading interval [code units].  ``<= 0`` computes the Keplerian orbital period at ``r_orb``.

**Dump-header persistence** — four values are written to every dump header
so that restarts continue exactly from where the previous run left off:
``dm_load`` (:math:`\xi`), ``r_orb``, ``mload_mp0`` (:math:`m_{p,0}`, the
original per-particle mass), and ``mload_tinit`` (:math:`t_\mathrm{init}`,
the simulation time when loading first fired).  On restart the formulas
:math:`m_{p,0} + \xi(t-t_\mathrm{init})/(T n_{p,0})` and
:math:`m_{p,0}\exp(\ln(1+\beta)(t-t_\mathrm{init})/T)` are evaluated
directly with the correct base state — no re-derivation from the evolved
disc mass is needed.

**v1 compatibility check** — both ``read_options_massloading`` and
``read_options_massloading_setup`` contain a clearly bracketed
``COMPAT_CHECK_V1`` block that raises a ``fatal`` error if the deprecated
``iload_dm`` key is found in the parameter file, printing a migration guide.
This block can be removed once all configurations have been updated.

Physical & Mathematical Description
------------------------------------

**Constant loading (modes 0 and 1):**

Following Mercer & Stamatellos (2020), the accretion rate is

.. math::

   \dot{M} = \frac{\xi}{T}, \quad
   \xi \equiv \chi M_{\mathrm{disc},0}, \quad
   T \equiv t_\mathrm{orb}(R) = \frac{2\pi R^{3/2}}{\sqrt{G M_\star}}.

With :math:`n_{p,0}` gas particles the per-particle mass at simulation time
:math:`t` is

.. math::

   m_p(t) = m_{p,0} + \frac{\xi\,(t - t_\mathrm{init})}{T\,n_{p,0}},

where :math:`t_\mathrm{init}` is the simulation time of the first loading
step (stored in the dump header for restart safety).  The implementation
evaluates this formula directly each binstep — no incremental accumulation.

**Exponential loading (mode 2):**

The disc mass scales as

.. math::

   M(t) = M_{\mathrm{disc},0}\,e^{\ln(1+\beta)(t-t_\mathrm{init})/T},

so that :math:`M(t_\mathrm{init}+T)/M(t_\mathrm{init}) = 1+\beta`.  The
per-particle mass is

.. math::

   m_p(t) = m_{p,0}\,\exp\!\left(\frac{\ln(1+\beta)\,(t - t_\mathrm{init})}{T}\right).

Again evaluated directly each binstep from :math:`m_{p,0}` and the current
simulation time.

**Why direct evaluation over incremental updates:**

An incremental approach (e.g. :math:`m_p \leftarrow m_p + \xi\,\delta t / (T n_{p,0})`)
accumulates a floating-point rounding error of
:math:`\mathcal{O}(N\,\varepsilon_\mathrm{mach}\,m_{p,0})` after :math:`N`
binsteps.  The direct formula carries only a single :math:`\mathcal{O}(\varepsilon_\mathrm{mach}\,m_{p,0})`
error regardless of :math:`N`, and the result is the same at any timestep
size.  This is particularly important for exponential loading, where an
incremental first-order approximation :math:`m_p \leftarrow m_p(1+\beta\,\delta t/T)`
converges to :math:`e^\beta \neq 1+\beta` rather than the intended value.

**Varying** :math:`T` **approximation:**

When ``iload_dt <= 0``, :math:`T` is recomputed from :math:`M_\star` at each
sync point and may change over time.  The direct formulas above use the
*current* :math:`T` for the entire elapsed time :math:`(t - t_\mathrm{init})`,
which is an approximation when :math:`T` varies.  This is valid when the
stellar mass changes slowly relative to the loading timescale, which holds
for typical disc accretion scenarios.

Negative values of :math:`\xi` and :math:`\beta` are supported (mass drain).

**Orbital period and** ``ind_timesteps`` **integration:**

``t_orb`` is refreshed once per sync point (``istepfrac == 2**nbinmax``, or
every step when individual timesteps are disabled) by reading the host-star
mass from ``xyzmh_ptmass(4, id_mstar)`` and broadcasting it via
``bcast_mpi``.  Between sync points the cached value is reused.  If
``iload_dt > 0`` then ``t_orb`` is fixed to that value and the star mass is
never read.

The per-particle mass update is applied at **every binstep** from
``evol_prestep`` in ``evolve.f90``, so loading accumulates correctly under
both global and individual timestep modes.

External Integration Points
----------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Module
     - Role
   * - ``evolve``
     - Calls ``step_mass_loading(time, dt, dtmax, istepfrac, nbinmax)`` from
       ``evol_prestep`` on every binstep, guarded by ``#ifdef MASS_LOADING``.
       The pre-call guard ``iload_factor >= 0`` avoids the call overhead when
       loading is off.
   * - ``checksetup``
     - Reads ``iload_factor``, ``mloadfactor``, ``iload_dt``, and ``r_orb``
       to validate the loading configuration before the time loop starts.
       Returns early (no check) when loading is inactive.
   * - ``checkconserved``
     - Reads ``iload_factor`` to suppress the total-energy and total-mass
       conservation warnings that would otherwise fire when mass is
       intentionally added or removed.
   * - ``config.F90``
     - Defines the compile-time logical parameter ``use_mass_loading``
       (``true`` when ``-DMASS_LOADING`` is set, ``false`` otherwise).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`evolve` — calls ``step_mass_loading`` from ``evol_prestep``.

   :doc:`checksetup` — validates the mass loading configuration at startup.

   :doc:`checkconserved` — suppresses conservation warnings during active loading.

   :doc:`utils_indtimesteps` — ``istepfrac`` and ``nbinmax`` used to detect sync points.

   :doc:`config` — compile-time ``use_mass_loading`` flag.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/evolve_massloading.f90
