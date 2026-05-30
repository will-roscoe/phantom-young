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

**Dump-header persistence** — ``dm_load`` and ``r_orb`` are written to every
dump header so that restarts reproduce the correct loading rate without
re-deriving :math:`\xi` from the evolved (no longer initial) disc mass.

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

With :math:`n_{p,0}` gas particles the per-particle mass evolves as

.. math::

   m_p(t) = m_{p,0} + \frac{\xi\,t}{T\,n_{p,0}}.

Each timestep :math:`\delta t` the implementation applies the increment

.. math::

   m_p \leftarrow m_p + \frac{\xi\,\delta t}{T\,n_{p,0}}.

Over :math:`N` binsteps spanning one interval (:math:`N \cdot \delta t = T`)
this accumulates to exactly :math:`\xi / n_{p,0}`, independent of :math:`N`.

**Exponential loading (mode 2):**

The disc mass scales as

.. math::

   M(t) = M_{\mathrm{disc},0}\,e^{\ln(1+\beta)\,t/T},

so that :math:`M(t+T)/M(t) = 1+\beta`.  Each timestep the implementation
multiplies:

.. math::

   m_p \leftarrow m_p \cdot \exp\!\left(\frac{\ln(1+\beta)\,\delta t}{T}\right).

After :math:`N` steps this gives

.. math::

   m_p(N\,\delta t) = m_{p,0}
     \cdot\left[\exp\!\left(\frac{\ln(1+\beta)\,\delta t}{T}\right)\right]^N
     = m_{p,0}\cdot\exp(\ln(1+\beta)) = m_{p,0}\cdot(1+\beta),

which is also exactly timestep-independent.  This follows from the composition
property :math:`\exp(a)\cdot\exp(b)=\exp(a+b)`, which decomposes the full
step exactly into arbitrarily many sub-steps.  A naive first-order in-place
update :math:`m_p \leftarrow m_p(1 + \beta\,\delta t/T)` would instead give
:math:`(1+\beta/N)^N \to e^\beta \neq 1+\beta`, with a result that depends on
:math:`N` and converges to the wrong value for finite :math:`\beta`.

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
