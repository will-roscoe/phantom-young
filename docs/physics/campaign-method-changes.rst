Method changes between the mass-loading campaigns
=================================================

This page records every change of *method* made between the mass-loading
campaigns run with this fork: the blocks before the August 2026 rebuild
(``mload001``-``mload004``, "pre-005e"), ``mload005e``, ``mload006e``,
``mload007a`` and after. It covers only changes that are implemented or being
implemented. Planned or proposed changes are left out until they are adopted.

Each entry gives:

- **Change**: what changed, from what to what, and where.
- **Problem**: the issue, with the derivation or the measurement that shows it.
- **Reason**: why it was changed.
- **Why this choice**: why this was the correct (or only) option.
- **Comparing before and after**: what it means for comparing runs made
  either side of the change.
- **Physical basis**: why the new method is physically better for what the
  campaigns measure, the mass and time at which a mass-loaded disc fragments.

Where a section cannot be filled honestly, the entry says so. An entry that
cannot claim to be more physically correct is flagged as such, because it may
not be the right change.

Design variables (host mass :math:`M_\star`, :math:`R_{\rm out}`, particle
number :math:`N`, luminosity :math:`L_\star`) are the experiment, not the
method, and are listed only for reference:

.. list-table::
   :header-rows: 1

   * - campaign
     - :math:`M_\star` (M\ :sub:`sun`)
     - :math:`R_{\rm out}` (au)
     - :math:`N`
     - thermal profile
     - disc mass from
     - stops at
   * - mload003 (calib)
     - 0.2
     - 120
     - 10\ :sup:`6`
     - ``lumdisc=1``
     - fixed
     - ``rhofinal_cgs``
   * - mload004 / 004b
     - 0.2
     - 120
     - 10\ :sup:`6` / 5x10\ :sup:`5`
     - ``lumdisc=2``
     - fixed
     - ``rhofinal_cgs`` / sink
   * - mload005e
     - 0.1-0.2
     - 60-120
     - 5x10\ :sup:`5`
     - ``lumdisc=2``
     - MS20 Table 1
     - ``rhofinal_cgs = 1e-9``
   * - mload006e
     - 0.3
     - 60-120
     - 2x10\ :sup:`6`
     - ``lumdisc=2``
     - :math:`Q(R_{\rm out})=2`
     - first sink
   * - mload007a
     - 0.0477 (50 M\ :sub:`J`)
     - 60-120
     - 5x10\ :sup:`5`
     - ``lumdisc=3``
     - :math:`Q(R_{\rm out})=2`
     - first sink

MS20 is Mercer & Stamatellos (2020, A&A 633, A116), the reference study.

.. contents:: Entries
   :local:
   :depth: 1


1. Temperature slope applied in the initial condition and the run-time floor (``qprofile``)
-------------------------------------------------------------------------------------------

**Change.** Pre-005e (June 2026, fork PRs #1 and #2). ``qprofile`` now sets the
temperature slope in both the ``lumdisc=1`` initial condition and the run-time
floor of the radiative-approximation cooling. The initial condition previously
used a hard-coded slope of 0.25.

**Problem.** Both paths use :math:`T \propto r^{-2q}`. With the initial condition
fixed at :math:`q=0.25` and the run-time floor at the requested :math:`q`, a run
asking for :math:`q=0.35` started from :math:`T\propto r^{-0.5}` but was held to
a floor of :math:`T\propto r^{-0.7}`. The initial disc was out of equilibrium
with its own floor by a factor :math:`(r/r_{\rm ref})^{0.2}` in temperature.

**Reason.** The initial condition must be the disc the run is meant to evolve.

**Why this choice.** There is one requested slope, so both paths must use it.
No alternative keeps them consistent.

**Comparing before and after.** Runs before June 2026 that requested
:math:`q \ne 0.25` started out of equilibrium with their floor. None of those runs
is used in a comparison.

**Physical basis.** An initial condition in equilibrium with the thermal model
does not relax in the first orbits, so early evolution is not a transient of the
setup. Note that the floor is only a floor: it is attenuated by
:math:`e^{-\bar\Sigma\bar\kappa}`, and gas heated above it keeps its own
temperature, so the slope is not maintained where the disc is optically thick.


2. Mass loading active from the first step
------------------------------------------

**Change.** Pre-005e (June 2026, fork PR #3). The loading interval :math:`T` is
derived on the first sub-step of a fresh or restarted run, not at the first
synchronisation point.

**Problem.** Loading adds :math:`\dot M = \xi/T` with :math:`\xi = \chi M_{\rm disc,0}`.
Before the fix :math:`T` was unset until the first sync point, so the first
``dtmax`` interval of every link loaded nothing. Each link lost
:math:`\xi\,{\rm dtmax}/T` of loaded mass.

**Reason.** The loading rate must be what the parameters say, from :math:`t=0`.

**Why this choice.** The only alternative is a smaller, run-length-dependent
rate, which no parameter describes.

**Comparing before and after.** Runs before 13 June 2026 under-loaded by one dump
interval per link. None is used in a comparison.

**Physical basis.** The model (MS20 Eq. 5) is a constant infall rate. A gap at
each restart is a numerical artefact with no physical counterpart.


3. Thermal profile: ``lumdisc=1`` to the floored power law ``lumdisc=2``
------------------------------------------------------------------------

**Change.** Campaign rebuild, 14 August 2026 (``mload004`` onward). The
luminosity-anchored ``lumdisc=1`` was replaced by the floored power law of
MS20 Eq. 8:

.. math::

   T(R) = \left[ T_0^{\,n} \left( R_{\rm au}^2 + R_0^2 \right)^{-nq} + T_\infty^{\,n} \right]^{1/n},
   \qquad n = 2,\ T_0 = 100\ {\rm K},\ R_0 = 0.01\ {\rm au},\ T_\infty = 10\ {\rm K},\ q = 0.35 .

**Problem.** ``lumdisc=1`` sets the temperature from :math:`L_\star`:
:math:`T(1\,{\rm au}) = [L_\star / (4\pi\sigma_{\rm SB}\,{\rm au}^2)]^{1/4}`. With
main-sequence luminosities for :math:`M_\star` = 0.10, 0.15 and 0.20
M\ :sub:`sun`, this gives 70%, 86% and 99% of MS20's 100 K at 1 au. The Toomre
parameter goes as
:math:`Q = c_s\kappa/(\pi G\Sigma) \propto T^{1/2}`, so the 0.10 M\ :sub:`sun`
disc had :math:`Q` lower by :math:`\sqrt{0.70} = 0.84` than intended, and the
0.20 M\ :sub:`sun` disc almost none.

**Reason.** That bias depends on :math:`M_\star`, which is the trend being
measured. Colder, lower-:math:`Q` discs around lighter hosts would fragment
earlier and lighter for a reason that has nothing to do with the host.

**Why this choice.** The only run in the earlier blocks that fragmented and
matched MS20 (``mload002_fprofile``) used ``lumdisc=2``, and ``lumdisc=2`` is
MS20's Eq. 8 exactly. Reproducing the reference model is the precondition for
extending it.

**Comparing before and after.** All ``lumdisc=1`` blocks (``mload003``, the old
``mload004``/``mload005``) are superseded, not compared. They were deleted and
rebuilt.

**Physical basis.** Neither profile is derived from first principles: both are
parametrisations of an irradiated disc. The claim for ``lumdisc=2`` is
consistency with the reference study and the absence of an
:math:`M_\star`-dependent bias. It is not a claim of more realistic irradiation.
Entry 12 replaces the fixed :math:`T_0` with one set by the host's luminosity,
because a fixed 100 K is not appropriate for brown-dwarf hosts.


4. Loading rate: chi mode with the reference disc masses
--------------------------------------------------------

**Change.** Campaign rebuild, 14 August 2026. Loading uses
``iload_factor = 0`` (chi mode), ``iload = 0.1``, loading radius ``R_load = 100``
au, with :math:`M_{\rm disc,0}` taken from MS20 Table 1 in ``mload005e``.
Before this, ``mload002`` ran chi mode on an undersized disc, and a switch to
xi mode (absolute mass per orbit) was proposed as a workaround.

**Problem.** In chi mode

.. math::

   \dot M_{\rm load} = \frac{\chi\, M_{\rm disc,0}}{T(R_{\rm load})},
   \qquad T(R_{\rm load}) = 2\pi\sqrt{R_{\rm load}^3 / G M_\star},

so the rate is proportional to the starting disc mass. ``mload002`` started from
0.030 M\ :sub:`sun` against MS20's 0.059 for the same cell, which halved the
loading rate. It fragmented at :math:`q = M_{\rm disc}/M_\star = 0.600`
against MS20 run 7's 0.61, but late.

**Reason.** Use the reference formulation (MS20 Eq. 5) with the reference
initial masses, so the rate matches by construction.

**Why this choice.** Xi mode would have matched one cell's rate by choosing
:math:`\xi` by hand. That treats a wrong :math:`M_{\rm disc,0}` rather than
fixing it. Chi mode with the correct :math:`M_{\rm disc,0}` is MS20's definition.

**Comparing before and after.** Pre-rebuild loading rates differ by
:math:`M_{\rm disc,0}^{\rm old}/M_{\rm disc,0}^{\rm MS20}`. Those runs are
superseded (entry 3).

**Physical basis.** A loading rate proportional to the disc's initial mass is a
modelling choice made by MS20, not a physical law. Its merit here is that it is
the reference definition. See entry 16 for how :math:`T` is evaluated.


5. Stop at sink creation, not at a density ceiling
--------------------------------------------------

**Change.** ``mload005e`` to ``mload006e``. ``rhofinal_cgs = 1e-9`` (stop when
the peak density reaches :math:`10^{-9}` g cm\ :sup:`-3`) was removed. Runs end
when the first sink forms, with sink creation at
``rho_crit_cgs = 1e-3`` and ``max_created_sinks = 1``.

**Problem.** The two thresholds were six orders of magnitude apart. Every
``mload005e`` run stopped when :math:`\rho_{\max}` first reached
:math:`10^{-9}`, before any fragment was dense enough to be a sink. The
``.sink`` files hold only the host (checked on the raw file: 5772 rows, no id
:math:`\ge 2`). The quoted "fragmentation mass" was the disc mass when a density
threshold was crossed, which is why ``mload005e`` appeared to fragment earlier
and lighter than MS20.

**Reason.** The quantity measured is the disc mass when a bound fragment forms,
so the run must reach one.

**Why this choice.** A density ceiling is not the event of fragmentation at any
value, since density can spike in a shock or a transient clump. Sink creation
requires the collapsing gas to pass phantom's creation checks (or the density
override of entry 7), which is the closest event the code provides.

**Comparing before and after.** ``mload005e`` masses are density-threshold
masses. Where both exist they agree with ``mload006e``'s sink masses to 0.09%
(r090) and 0.25% (r120), despite a 4x resolution change and a different
starting mass. The ``mload005e`` fragmentation *times* and radii are not
comparable.

**Physical basis.** A sink marks gas that has collapsed well past the density at
which it could still be sheared out. That is fragmentation, where a density
ceiling of :math:`10^{-9}` g cm\ :sup:`-3` is not.


6. ``max_created_sinks`` counts created sinks correctly
-------------------------------------------------------

**Change.** 23 August 2026. The stop condition fires when the number of sinks
created in the run reaches ``max_created_sinks``. Previously the test was off by
one.

**Problem.** With the off-by-one, ``max_created_sinks = 1`` needed a second sink
before stopping. So a run could continue past its first fragment into
multi-fragmentation, and the reported first-fragment state was not the state at
the first fragment.

**Reason / why this choice.** A stop condition must stop at the count it names.
There is no other correct reading.

**Comparing before and after.** The condition is checked at dump-write points,
not every step, so a run can still overshoot by up to one dump interval. In
``mload006e`` r060 two sinks formed within one interval. First-sink masses are
therefore recorded from the ``.sink`` series at the moment of creation, not from
the final dump.

**Physical basis.** None needed: this is bookkeeping, not physics.


7. Sink parameters and the creation override
--------------------------------------------

**Change.** ``r_crit`` (minimum separation from an existing sink) 3.0 au in the
pre-005e and ``mload005e`` blocks, 1.89 au in ``mload006e``, 1.0 au in
``mload007a``. ``h_acc`` (accretion radius) 0.5, 0.315, 0.1667 au, the last as
:math:`r_{\rm crit}/6`. ``f_crit_override = 10`` from ``mload006e``: a sink is
created when the density exceeds :math:`10\,\rho_{\rm crit}` even if the energy
checks fail.

**Problem.** Sink radii that are large compared with the fragment's Hill radius
and the local smoothing length merge distinct fragments and accrete gas that is
not bound to them. The external recommendation (D. Stamatellos) was to reduce the
accretion radius. For ``mload006e`` all sinks were created by the override.
phantom's energy test uses only the sphere of radius :math:`2h` around the
densest particle (``ptmass.F90:1213``), and there that sphere is a hot,
pressure-supported core (T ~ 160-1700 K, :math:`E_{\rm th}/|E_{\rm pot}|` ~ 20-50),
so the test fails on gas that is bound on larger scales.

**Reason.** Smaller radii resolve separate fragments and measure the mass of each.
The override creates sinks for fragments whose boundness the :math:`2h` test
cannot see.

**Why this choice.** *Not fully established.* The 1.89 au value for
``mload006e`` was chosen with the sizing script ``lengthcalc``. Until 23 September
2026 that script assumed :math:`H/R = 0.05`, while the discs have
:math:`H/R \approx 0.1`, so the parameters were sized for discs half as thick as
the runs. Rerun with the real profile, it rates r090's 1.89 au as low against a
recommended 1.99 au. The
:math:`r_{\rm crit}/6` ratio is inherited from ``mload005``, not derived. The
override was checked after the fact: in ``mload006e`` the gas around every sink
is bound (:math:`E_{\rm tot}<0`) over 1-7 au inside its Hill radius, and sink
masses match the pre-sink bound mass (r090: 9.19 against 8.78 M\ :sub:`J`).

**Comparing before and after.** Fragmentation *masses* are insensitive to these
radii in ``mload006e``, whose first-sink disc masses agree with ``mload005e`` to
0.25% or better. Fragment *counts and separations* after the first sink depend on
``r_crit`` and are not compared across campaigns.

**Physical basis.** A sink should be no larger than the fragment it represents.
Smaller radii move towards that, but the specific values are sized by a
resolution argument whose inputs were corrected late. They should be re-derived
per campaign from the current sizing script.


8. Untapered inner edge (``ismoothgas``)
----------------------------------------

**Change.** ``mload005e`` onward. ``ismoothgas`` true to false: the surface
density is a pure power law :math:`\Sigma \propto R^{-p}` from :math:`R_{\rm in}`
to :math:`R_{\rm out}`, without the inner factor
:math:`(1-\sqrt{R_{\rm in}/R})`.

**Problem.** A disc mass is only meaningful together with the profile it was
solved for. At :math:`R_{\rm in}` = 5 au and :math:`p = 1`, the tapered disc's
:math:`Q(R_{\rm out})` is 0.776, 0.809 and 0.831 times the untapered value at
:math:`R_{\rm out}` = 60, 90 and 120 au. So a mass solved for one profile and
used with the other misses the intended :math:`Q` by a radius-dependent fraction.

**Reason.** The recorded reason is consistency: "untapered, as ``mload006e``".

**Why this choice.** *Not forced.* The disc-mass solver (entry 9) takes the
surface-density profile from the run's own configuration, taper included, so
either choice gives the intended :math:`Q`. Untapered was kept so that
``mload005e``, ``mload006e`` and ``mload007a`` share one profile.

**Comparing before and after.** The pre-005e blocks used the taper. They are
superseded for other reasons (entry 3). ``mload005e`` onward are mutually
consistent.

**Physical basis.** *Cannot claim this is more physical.* A sharp edge at
:math:`R_{\rm in}` = 5 au, next to the host's 3 au accretion radius, relaxes onto
the host in the first orbits. In ``mload007a`` r060L35, ~3% of the particles
were gone within 0.3 outer orbits. That is about the mass of the first 2 au of
an untapered :math:`\Sigma\propto R^{-1}` disc (3.6%). A tapered edge, which
the solver already supports, would be the physically better choice. By the test
of this page, this should be revisited, at the cost of comparability with
``mload005e``-``mload007a``.


9. Initial disc mass: MS20 Table 1, then solved for :math:`Q(R_{\rm out}) = 2`
----------------------------------------------------------------------------------

**Change.** ``mload005e`` took :math:`M_{\rm disc,0}` from MS20 Table 1.
``mload006e`` and ``mload007a`` solve :math:`M_{\rm disc,0}` so that the Toomre
parameter at :math:`R_{\rm out}` is 2 at :math:`t=0`, with their own solver
(``sph.helpers.calc.profiles.disc_mass_for_Q``) and ``isetgas = 0``.
phantom's minimum-:math:`Q` solver (``isetgas = 4``) is not used.

**Problem.** For :math:`\Sigma = \Sigma_{\rm ref}(R/R_{\rm ref})^{-1}` between
:math:`R_{\rm in}` and :math:`R_{\rm out}`,

.. math::

   M_{\rm disc} = 2\pi\Sigma_{\rm ref}R_{\rm ref}(R_{\rm out}-R_{\rm in}),
   \qquad
   Q(R_{\rm out}) = \frac{c_s(R_{\rm out})\,\Omega(R_{\rm out})}{\pi G\,\Sigma(R_{\rm out})}
   \;\Rightarrow\;
   M_{\rm disc} = \frac{2\,c_s\,\Omega\,R_{\rm out}(R_{\rm out}-R_{\rm in})}{G\,Q_{\rm out}} .

phantom's ``get_disc_mass`` evaluates this with two errors. It takes :math:`c_s`
from an *unfloored* power law, extrapolated from :math:`R_{\rm ref}` with an extra
:math:`1/\sqrt{\pi/2}`, when the real profile (entry 3) is floored at
:math:`T_\infty`. For :math:`M_\star` = 0.2 M\ :sub:`sun` at
:math:`R_{\rm out}` = 120 au that gives 3.50 K against the true 10.60 K. It also
takes :math:`\kappa` from the star alone, although the disc's mass is part of
the enclosed mass. The campaign solver uses the floored :math:`T(R)` and
:math:`M_{\rm enc} = M_\star + M_{\rm disc}` in :math:`\Omega`, iterating
because :math:`Q` depends on the mass through both. The resulting
error in :math:`Q` grows with :math:`R_{\rm out}/R_{\rm ref}`: 16%, 32% and 46%
at 60, 90 and 120 au for ``mload006e``.

**Reason.** Each cell should start from the same stability state, computed on
the temperature the run actually starts with. Then the time to fragmentation
measures loading, not a cell-dependent initial margin. MS20's Table 1 masses do
not have a uniform :math:`Q(R_{\rm out})`: 1.505 for (0.2 M\ :sub:`sun`, 60 au)
under this convention.

**Why this choice.** :math:`Q = 2` is marginally stable (above the
axisymmetric threshold of 1), so no cell fragments from its initial condition.
*The value 2 itself is a convention, not derived.* The solver must use the
run's own floored :math:`T(R)`, which rules out phantom's.

**Comparing before and after.** ``mload006e`` starts at 0.714x MS20's disc mass
for r090 (0.04425 against 0.062 M\ :sub:`sun`). Fragmentation *times* are
therefore not comparable with MS20 or ``mload005e``. Masses must be compared as
absolute :math:`M_{\rm disc}`, never as :math:`M_{\rm disc}/M_{\rm disc,0}`,
because the denominators differ.

**Physical basis.** A uniform, marginally stable start makes the loading the
only route to instability, which is the process studied. For light hosts at
:math:`Q_{\rm out} = 2`, the disc is 0.43-0.60 of the host's mass
(``mload007a``) and above it for 10 M\ :sub:`J` hosts. That is outside the
Keplerian, host-dominated regime the :math:`Q` criterion assumes. It is recorded
as a limit of this convention.


10. Radiative-approximation cooling state read back on restart
--------------------------------------------------------------

**Change.** 13 September 2026 (fork PR #11). The per-particle stores of the
radiative-approximation cooling (``ueqi``, ``ttherm``, ``taumean``, ``dudt``) are
read back from the dump on restart.

**Problem.** The read was guarded on arrays not yet allocated when the dump was
read, and the initialisation zeroed them unconditionally. So ``ttherm = 0`` after
every restart, which fails the guard that decides whether to cool: every particle
skipped one cooling step per restart.

**Reason / why this choice.** A restart must continue the calculation it
resumes. There is no alternative.

**Comparing before and after.** ``mload006e`` was built from a tree without this
fix and chained over several links, so it carries one skipped cooling step per
particle per restart. *The effect has not been quantified.* It is bounded by one
step in tens of thousands per link, but cooling is what sets fragmentation.

**Physical basis.** Removes a numerical interruption of the cooling physics. No
physical process corresponds to it.


11. Flux-limited-diffusion limiter computed after the density pass
------------------------------------------------------------------

**Change.** 23 September 2026 (fork PR #25). The FLD limiter :math:`\lambda` is
computed once the density iteration has converged and stored ``gradh``, not
before.

**Problem.** :math:`\lambda(R)` depends on :math:`R = |\nabla T|/(\kappa\rho T)`,
and the SPH gradient needs ``gradh``. Computed before the density pass,
:math:`\lambda` used the previous pass's ``gradh``. On a job's first pass
(``gradh`` is not in the dump) that was 0 for every particle, and the fallback
gave :math:`\lambda = 1/3`, the optically thick limit, everywhere. On a test
lattice the first and second passes differed by a factor 6.

**Reason / why this choice.** :math:`\lambda` must be computed from the state it
describes. There is no alternative ordering.

**Comparing before and after.** Every run before 23 September 2026
(``mload006e`` and earlier) had :math:`\lambda = 1/3` on the first density pass of
every link: optically thick diffusion regardless of the local optical depth. It
is transient (one pass per link), but not quantified.

**Physical basis.** Flux-limited diffusion is why this fork exists. It only
describes radiative transport correctly when :math:`\lambda` reflects the local
optical depth.


12. Thermal profile set by the host's luminosity: ``lumdisc=3``
---------------------------------------------------------------

**Change.** ``mload007a`` (fork PR #23). ``lumdisc=3`` sets :math:`T_0` from
:math:`L_\star` at grain equilibrium:

.. math::

   T_0 = \left(\frac{L_\star}{16\pi\,\sigma_{\rm SB}\,(1\,{\rm au})^2}\right)^{1/4},
   \qquad L_\star = 0.035\,L_{\rm sun} \Rightarrow T_0 = 120.95\ {\rm K},

with ``qprofile`` :math:`q = 0.25` (was 0.35), and the same floored form, :math:`n = 2`
(entry 13). :math:`L_\star` is carried into the ``.in`` and the dump header as a
record.

**Problem.** A fixed :math:`T_0 = 100` K belongs to MS20's M-dwarf hosts. A
50 M\ :sub:`J` brown dwarf has a different luminosity (0.035-0.070 L\ :sub:`sun`
for young brown dwarfs, Riaz & Nally 2021), so the disc temperature must follow
the host. The normalisation matters. An isothermal grain in radiative
equilibrium absorbs :math:`\pi a^2 L/(4\pi R^2)` and emits
:math:`4\pi a^2\sigma T^4`, giving :math:`\sigma T^4 = L/(16\pi R^2)`, i.e.
:math:`T = 279\,{\rm K}\,(L/L_{\rm sun})^{1/4}(R/{\rm au})^{-1/2}`.
The earlier :math:`L/(4\pi R^2)` is the flux temperature of a flat absorber, and
is :math:`4^{1/4} = 1.414` times hotter. The run-time floor of the radiative
cooling already used :math:`16\pi`. The grain-equilibrium slope
:math:`T\propto R^{-1/2}` is :math:`q = 1/4` in :math:`T \propto R^{-2q}`.

**Reason.** The disc must be irradiated by its own host, with the same
normalisation in the initial condition and the run-time floor.

**Why this choice.** :math:`16\pi` is the equilibrium of the grains that set the
opacity. :math:`q = 0.25` was set by D. Stamatellos, and is the slope of that
equilibrium. It remains a free input.

**Comparing before and after.** At :math:`R` = 60 au the ``mload007a`` disc is at
18.5 K against 11.5 K for ``mload006e``'s profile, i.e. 1.6x hotter. Combined
with the 6.3x lighter host, :math:`H/R` at :math:`R_{\rm out}` is 0.39 against 0.12.
Every quantity that scales with :math:`H/R` differs between the campaigns,
including the viscous evolution rate per orbit (:math:`\propto\alpha(H/R)^2`,
about 10x faster). Before PR #23 the ``.in`` could carry a stale ``Lstar``
(``mload006e``: 0.001 beside ``L_star = 0.0144`` in the ``.setup``). ``lumdisc=2``
never reads ``Lstar``, so that had no effect on ``mload006e``.

**Physical basis.** The temperature of an irradiated disc is set by its star.
Grain equilibrium is the standard optically thin estimate of it.


13. Background combination index kept at :math:`n = 2`, with one :math:`n = 4` check
---------------------------------------------------------------------------------------

**Change.** ``mload007a``: :math:`n = 2` (quadrature, as MS20 Eq. 8 and all
earlier campaigns) in four cells, and :math:`n = 4` in one, ``r120L35n4``.

**Problem.** With ``lumdisc=3``, :math:`q = 1/4` and :math:`R_0\to 0`, :math:`n = 4`
is exactly :math:`\sigma T^4 = L_\star/(16\pi R^2) + \sigma T_\infty^4`: stellar
and background heating add as fluxes. :math:`n = 2` is not an energy sum, and
heats the outer disc more. At fixed :math:`Q_{\rm out}` a colder outer disc needs
less mass, so the choice changes the disc masses by 7-12%.

**Reason.** :math:`n = 4` is the more consistent physics, but :math:`n = 2` keeps
``mload007`` comparable with MS20 and the earlier campaigns. The pair measures
what the difference does to the result.

**Why this choice.** If fragmentation is :math:`Q`-limited, :math:`Q \propto c_s
\propto T^{1/2}` and the expected ratio is
:math:`M_{\rm frag}(n{=}4)/M_{\rm frag}(n{=}2) \approx 0.89\text{-}0.92`. A result
inside 0.88-0.93 keeps ``mload007b`` at :math:`n = 2`. Outside it, the irradiated
trend is rerun at :math:`n = 4` first.

**Comparing before and after.** :math:`n = 2` cells compare directly with
``mload005e``/``mload006e`` in the thermal-profile form, and differ only in how
:math:`T_0` is set (entry 12).

**Physical basis.** :math:`n = 4` is the physically correct combination of two
heating sources. :math:`n = 2` is retained only for comparability, and the check
cell bounds the cost of that choice.


14. Particles beyond 500 au removed (``rkill``)
-----------------------------------------------

**Change.** ``rkill = 500`` au: gas beyond 500 au from the origin is marked
accreted, and leaves the simulation without joining a sink. Applied mid-run to
``mload006e`` r090 on 11 September 2026, and to all of ``mload007a``. Earlier
campaigns ran with ``rkill = -1`` (off).

**Problem.** In ``mload006e`` r090, ~120 escaped particles beyond 1000 au had
smoothing lengths up to 1270 au. Neighbour search is symmetric in :math:`h`, so a
2540 au kernel is a neighbour of the whole disc. Its long timestep then limits
every particle through the timestep limiter: 17-18 wall seconds per code time
unit against 2.4 for r060. With ``rkill = 500``, ~1670 particles (0.09% of the
disc) were removed, giving a 9.1x speedup. Total energy continued smoothly across
the cull.

**Reason.** Cost: the escaped gas cannot affect the disc physically but stalls
the whole calculation numerically.

**Why this choice.** *Established only for a 314 M*\ :sub:`J` *host.* The check
(``reduce.py --escape`` on ``mload006e`` r120) measured the mass beyond each
radius, 5.6x10\ :sup:`-4` of the gas over the whole run, *not* whether that gas
was bound.

**Comparing before and after.** For ``mload006e`` the removed mass is negligible.
For ``mload007a`` (50 M\ :sub:`J` host) it is not. About 35% of r060L35's lost
particles went through ``rkill``, rising to 75-80% of the losses after 60
orbits. The gas in the shell just inside 500 au is all outflowing, but only
18-37% of it is unbound between orbits 10 and 60 (Bernoulli parameter about the
host, including the enclosed disc mass). Most of what ``rkill`` removed around
the light host would have turned back.

**Physical basis.** *Cannot claim this is more physical for light hosts.*
Removing bound gas removes mass and angular momentum that would have returned to
the disc. Around a 50 M\ :sub:`J` host at these temperatures the outer disc is
marginally bound (:math:`c_s/v_K > 0.44` beyond ~120 au). By the test of this
page, a fixed 500 au is not correct for light hosts. Whether to keep it, raise it
or switch it off (with the option of switching it on mid-run if escaped particles
stall a run) is under test in ``mload007d``, and is not decided.


15. Mass-loading state fixed at setup and carried across restarts (being implemented)
-------------------------------------------------------------------------------------

**Change.** Fork PR #27. The particle count :math:`n_{p,0}`, particle mass
:math:`m_{p,0}` and host mass :math:`M_{\star,0}` are written to the dump header
from the setup dump onward and read back at every restart. The loading interval
uses :math:`M_{\star,0}`. The old behaviour is kept behind internal switches
(``torb_mstar0``, ``np0_initial``) for reproducing earlier runs.

**Problem.** Chi-mode loading sets every gas particle's mass directly from
elapsed time,

.. math::

   m_p(t) = m_{p,0} + \frac{\xi\,(t - t_{\rm init})}{T\,n_{p,0}},
   \qquad T = 2\pi\sqrt{R_{\rm load}^3/(G M_\star)} .

1. :math:`T` was re-evaluated from the *current* host mass and then applied to the
   whole elapsed time. As the host accretes, all mass already loaded is re-rated
   by :math:`\sqrt{M_\star(t)/M_{\star,0}}`. For ``mload007a`` r060L35 the host
   grew 0.0477 to 0.0722 M\ :sub:`sun`, so the loaded mass was overstated by up
   to a factor 1.23.
2. :math:`n_{p,0}` was recounted from each restart dump. Particles removed through
   ``kill_particle`` are dropped from dumps, so after :math:`k` such removals a
   restart re-rated all loaded mass by :math:`n_{p,0}/(n_{p,0}-k)`, a jump in
   every particle's mass.

**Reason.** The loading rate must be the one the parameters define, constant,
and independent of how many links a run is split into.

**Why this choice.** MS20 Eq. 5 is a constant rate,
:math:`\dot M = \chi M_{\rm disc,0}/T`. A constant :math:`T` requires a fixed
mass, and :math:`M_{\star,0}` is the one the definition refers to. With it the
closed form above is exact rather than an approximation. :math:`n_{p,0}` is a
property of the initial condition, so it belongs in the setup dump.

**Comparing before and after.** Checked for ``mload006e``: the particle count
stayed at 2x10\ :sup:`6` (1\ 999\ 999 for r060), and :math:`m_p` is continuous
across every link, so the :math:`n_{p,0}` fault did not act. The :math:`T`
re-rating did act, by :math:`\sqrt{M_\star(t)/M_{\star,0}}`. By the end of
``mload006e`` the host had grown 6.4%, 2.8% and 2.3% (r060, r090, r120), so
those runs loaded 3.2%, 1.4% and 1.2% more than the nominal rate. For
``mload007a`` r060L35, whose host grew 51%, it reached 23%. Runs on the fixed
code load slightly less than the same runs before it.

**Physical basis.** The model is a constant infall onto the disc. A rate that
jumps at restarts or rises retroactively with host accretion has no physical
counterpart.


Operational changes with no effect on the physics
-------------------------------------------------

Recorded for completeness. None changes the equations solved or their parameters.

- **Restart points and wall-time limits** (``twallmax``, ``dtwallmax``; PR #12 made
  ``dtwallmax = 0`` disable the subdivision rather than freeze it). Runs chain
  over SLURM's 2-day limit from clean restart dumps.
- **``dtmax_dratio``** shrinks the dump interval during collapse, so a collapsing
  run still writes dumps and the sink stop condition (checked at dump writes) can
  fire.
- **Safe sub-dump naming** (PR #13), and run names of at most 20 characters
  (``setpart``'s file prefix was fixed-length, and a longer name silently fell
  back to interactive setup).
- **Radially binned Toomre Q and cooling beta in the log** (PR #26): a diagnostic,
  off by default, read-only.
- **An extra-time window after the sink stop** (PR #21): available, not used in
  ``mload007a``.
- **Checksum of the EOS table** before a run starts. An exo2 copy of
  ``eos_lom.dat`` was a truncated download and gave NaN initial conditions. Runs
  that started are unaffected, because a truncated table fails at setup.
