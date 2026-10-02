# phantom-young — Usage Guide

This fork is based on Alison Young's Phantom branch at commit `054bc4e38`
and adds **four** behaviour-changing modifications on top of it. Everything
else in this fork (documentation, tests, build plumbing) is scaffolding
around these four features.

> **Attribution note.** The `lumdisc=1` luminosity-radiative temperature
> path, `eos_stamatellos` (tabulated EOS), and `cooling_radapprox`
> (Stamatellos/Lombardi radiative cooling) are Alison Young's **pre-existing
> base** — they are not part of this fork's changes. Features 3 and 4 below
> extend that base; they do not replace it (`lumdisc=0/1` remain untouched).

The four features:

1. [Comoving mass loading](#feature-1--comoving-mass-loading-mass_loading) (`mass_loading`)
2. [Sink-count stop condition](#feature-2--sink-count-stop-condition-stopcond) (`stopcond`)
3. [Configurable temperature slope](#feature-3--configurable-temperature-slope-qprofile) (`qprofile`)
4. [Floored power-law temperature profile](#feature-4--floored-power-law-temperature-profile-lumdisc2) (`lumdisc=2`)

---

## Feature 1 — Comoving mass loading (`mass_loading`)

### Purpose

Models accretion of ambient gas onto a disc by increasing the mass of
**every gas particle equally** each timestep ("comoving": per-particle mass
grows, particle count `n_p` stays fixed). Reference: Mercer & Stamatellos
(2020).

The feature is **compile-time optional**: it is built only when Phantom is
configured with `-DMASS_LOADING` (gated by the logical `use_mass_loading`
in `dim`/`config.F90`); the call site in `evolve.F90` (in `evol_prestep`,
executed every binstep) is wrapped in `#ifdef MASS_LOADING`. It is also
wired into `checksetup` (validation), `checkconserved` (suppresses
mass/energy conservation warnings while mass is being intentionally added),
and `readwrite_infile`/`readwrite_dumps_common` (see below).

### How to use

Set the loading mode and factor in the `.in` file. Example — constant mode,
loading 10% of the initial disc mass per orbital period at `R=50`:

```
iload_factor = 0      ! chi mode
iload        = 0.1    ! chi = 0.1 (10% of M_disc0 per interval)
iload_dt     = -1      ! <=0 -> use Keplerian orbital period at R_load
R_load       = 50.     ! code units
```

### Parameters

`.in` keys (3, plus `R_load` and `iload_total`):

| Key | Default | Meaning |
|---|---|---|
| `iload_factor` | `-1` | loading mode: `-1` off, `0` = chi (fraction of `M_disc0` per interval), `1` = xi (absolute mass per interval), `2` = beta (exponential factor per interval) |
| `iload` | `0.` | the factor value, interpreted per `iload_factor` as chi / xi / beta |
| `iload_dt` | `-1.` | loading interval `T` [code units]; `<=0` ⇒ computed as the Keplerian orbital period at `R_load`/`r_orb` |
| `R_load` | `-1.` | loading radius [code units]; `<0` ⇒ use the disc's `R_ref` |
| `iload_total` | `0` | modes 0/1 only: `0` = fixed rate per particle, so the total delivered falls as `n_alive/n_p0` while gas is accreted or killed; `1` = fixed total rate `dm_load/T` shared over the live gas (no closed form; `t_last` is carried in the dump header). A run started with `1` cannot restart with `0`. |

Derived/internal (not `.in` keys, set from the above): `mloadfactor` (chi or
beta), `dm_load` (xi), `r_orb` (reference radius used to compute `t_orb`).

### Equations / mechanism

Constant formulation (modes 0/1), Mercer & Stamatellos (2020):

$$
\dot M = \frac{\xi}{T}, \qquad \xi = \chi \, M_{\mathrm{disc},0}, \qquad T = t_{\mathrm{orb}}(R) = \frac{2\pi R^{3/2}}{\sqrt{G M_\star}} \;\; (G=1)
$$

$$
M_{\mathrm{disc}}(t) = M_{\mathrm{disc},0} + \dot M\, t
$$

$$
m_p(t) = m_{p,0} + \frac{\xi\,(t - t_{\mathrm{init}})}{T\, n_{p,0}}
$$

Exponential formulation (mode 2):

$$
M(t) = M_{\mathrm{disc},0}\, \exp\!\Big(\ln(1+\beta)\,\frac{t - t_{\mathrm{init}}}{T}\Big)
$$

$$
m_p(t) = m_{p,0}\, \exp\!\Big(\ln(1+\beta)\,\frac{t - t_{\mathrm{init}}}{T}\Big), \qquad \text{so } \frac{M(t+T)}{M(t)} = 1+\beta
$$

Mode-to-internal-variable mapping:

- mode 0: `mloadfactor = iload` (χ), `dm_load = iload * M_disc0`
- mode 1: `dm_load = iload` (ξ), `mloadfactor = iload / M_disc0`
- mode 2: `mloadfactor = iload` (β), `dm_load = 0`

Each binstep, `m_p(t)` is evaluated **directly** from `m_p0` and elapsed
time (not accumulated stepwise), so there is no build-up of round-off error
over a long run. Negative χ/ξ/β are permitted and drain mass from the disc
instead of adding it.

### Where it lives

- `src/main/evolve_massloading.f90` — new module `mass_loading` (the
  feature's entire implementation, ~556 lines).
- `src/main/evolve.F90` — call site under `#ifdef MASS_LOADING`.
- `src/main/checksetup.f90`, `src/main/checkconserved.f90` — validation and
  conservation-warning suppression.
- `src/main/readwrite_infile.f90` — `.in` read/write of `iload_factor`,
  `iload`, `iload_dt`, `R_load`.
- `src/main/readwrite_dumps_common.f90` — dump-header read/write.
- `src/main/config.F90`/`dim` — `use_mass_loading` compile-time flag.

**`.in` vs dump header:** only `iload_factor`, `iload`, `iload_dt`, `R_load`,
`iload_total` are user-editable `.in` options. Everything needed to resume mass loading
exactly across a restart — `dm_load` (ξ), `r_orb`, `R_load`, `mload_mp0`
(`m_p0`), `mload_tinit` (`t_init`), `mload_np0`, `mload_mstar0`, `mload_tlast`
(`t_last`), `mload_total` (`iload_total`) — is persisted in the **dump header**,
so it survives independent of what a user later edits in the `.in`.

---

## Feature 2 — Sink-count stop condition (`stopcond`)

### Purpose

Stops the run once **more than `max_created_sinks` new sink particles have
formed since t=0**. On the dump that trips the condition, that dump is
promoted to a full dump and the run exits cleanly.

### How to use

```
max_created_sinks = 5   ! stop once more than 5 sinks have formed since t=0
```

Set `max_created_sinks = -1` (the default) to disable the feature.

### Parameters

| `.in` key | Default | Meaning |
|---|---|---|
| `max_created_sinks` | `-1` | stop after this many sinks form since t=0 (`-1` = off) |

Dump-header only (not a `.in` key): `nptmass0` — the baseline sink count
captured at t=0, so the "since t=0" count survives restarts.

Runtime-only flag (not persisted): `stopcond_triggered` — read by `evolve`
once the condition has fired.

### Equations / mechanism

Logic (module `stopcond`):

- `init_stopcond(nptmass)` captures `nptmass0` **once** (only when
  `nptmass0 < 0`), so on a restart the value already restored from the dump
  header is left untouched; it also resets `stopcond_triggered`.
- `check_stopcond(nptmass, fulldump)` is evaluated at each dump-write point:
  - no-op if `max_created_sinks < 0` (feature off) or `nptmass0 < 0`
    (baseline not yet captured);
  - otherwise, if `nptmass - nptmass0 > max_created_sinks`, sets
    `fulldump = .true.` and `stopcond_triggered = .true.`.

### Where it lives

- `src/main/stopcond.f90` — new module `stopcond` (~136 lines): `nptmass0`,
  `max_created_sinks`, `stopcond_triggered`; `init_stopcond`,
  `check_stopcond`; `write_options_stopcond`/`read_options_stopcond` (`.in`);
  `write_headeropts_stopcond`/`read_headeropts_stopcond` (dump header).
- `src/main/evolve.F90` — reads `stopcond_triggered` to end the run.
- `src/main/checksetup.f90`, `src/main/readwrite_infile.f90`,
  `src/main/readwrite_dumps_common.f90` — validation, `.in` I/O, dump-header
  I/O respectively.

**`.in` vs dump header:** `max_created_sinks` is the only `.in` option.
`nptmass0` is restart-critical baseline state and lives **only** in the
dump header (`add_to_iheader`/`extract` on key `nptmass0`), not the `.in` —
this is what makes the "since t=0" count correct across restarts even if a
user edits `max_created_sinks` in between.

---

## Feature 3 — Configurable temperature slope (`qprofile`)

### Purpose

Extends Alison Young's pre-existing `lumdisc=1` luminosity-radiative disc
(`ieos=24`) by letting the user set the disc temperature power-law index,
instead of it being hardwired. Default behaviour (`qprofile=0`) is
unchanged: `q=0.25`, i.e. `T ∝ R^(-0.5)`. Setting `qprofile>0` overrides
`q=qprofile`, giving `T ∝ R^(-2q)`.

The override is applied **consistently** to both:

- the `.setup` initial condition, via `qindex` (feeding the `r^(-8q)`
  irradiation temperature term used in `get_cs_from_lum`/
  `get_T_from_lum`/`get_u_stamatellos`), and
- the runtime cooling floor, via `q_eff = qprofile` (giving
  `Tmini4 ~ r^(-8q)`).

Slope relation to the Mercer & Stamatellos (2020) convention: their
temperature slope `β_T = 2q` (e.g. `q=0.35 → β_T=0.7`).

Also added alongside this feature: `get_Lstar_from_mass(mass_solar)` in
`setup_disc.F90` — a piecewise mass–luminosity relation used to seed the
interactive default of the disc's `L_star`:

$$
L_\star(M) =
\begin{cases}
0.23\,M^{2.3} & M < 0.43\ M_\odot \\
M^{4} & 0.43 \le M < 2\ M_\odot \\
1.4\,M^{3.5} & 2 \le M < 55\ M_\odot \\
32000\,M & M \ge 55\ M_\odot
\end{cases}
$$

### How to use

```
lumdisc  = 1       ! legacy luminosity-radiative disc (base feature)
qprofile = 0.35     ! q=0.35 -> T ~ R^-0.70 (instead of the default 0.25 -> R^-0.5)
```

`qprofile` is read from both the `.setup` file (`setup_disc`, feeding
`qindex`) and the `.in` file (`cooling_radapprox`, feeding the runtime
floor), so the same value should be used in both if editing by hand
(`phantomsetup` and normal restart bookkeeping keep them consistent).

### Parameters

| Key | Default | Meaning |
|---|---|---|
| `qprofile` | `0` | disc temperature slope override for `lumdisc>0`, `ieos=24`; `0` ⇒ standard `q=0.25`; `>0` ⇒ `q=qprofile`, giving `T ∝ R^(-2q)` |

### Equations / mechanism

With the override, the irradiation temperature term scales as:

$$
T \propto R^{-2q}
$$

applied as `r^(-8q)` inside the irradiation temperature term of
`get_cs_from_lum`/`get_T_from_lum`/`get_u_stamatellos` (setup IC) and as
`Tmini4 ~ r^(-8q)` in the runtime cooling floor — i.e. the same slope
override reaches both the particles' initial temperatures and the floor
they cool towards at runtime.

Mercer & Stamatellos (2020) slope convention: `β_T = 2q` (so `q=0.35`
corresponds to `β_T=0.7`).

### Where it lives

- `src/main/eos_stamatellos.f90` — module variable `qprofile` (public,
  default `0`), consumed by the `q_eff = merge(qprofile, 0.25-equivalent
  default, qprofile > 0.)` logic feeding the irradiation-temperature terms.
- `src/setup/setup_disc.F90` — reads `qprofile` from `.setup`, sets
  `qindex(1) = qprofile` when `qprofile > 0.`; also hosts
  `get_Lstar_from_mass`.
- `src/main/cooling_radapprox.f90` — reads `qprofile` for the runtime
  `Tmini4` floor term.

**`.in`/`.setup` vs dump header:** `qprofile` is a genuine user-facing
option in both the `.setup` (IC generation) and the `.in` (runtime cooling);
it is not restart-critical hidden state the way mass-loading's or
stopcond's internals are, so it is not treated specially in the dump
header for this feature. (Contrast with Feature 4, which builds on this
variable but does promote it to dump-header-only storage.)

---

## Feature 4 — Floored power-law temperature profile (`lumdisc=2`)

### Purpose

Generalizes Feature 3 into a self-consistent disc temperature
prescription for radiative-cooling discs (`ieos=24`/`icooling=9`), selected
with `lumdisc=2` (internal mode `iprofile=2`). A single analytic function,
`eos_stamatellos:get_T_profile(r)`, is used **identically** by the disc
initial condition (`set_disc`) and by the runtime radiative-cooling floor
(`cooling_radapprox`), so the floor and the IC can never desync
("floor == IC by construction"). The Mercer & Stamatellos (2020) MS20
profile (Eq. 8) is the `n=2` preset of this more general form.

### How to use

```
lumdisc  = 2        ! floored power-law
T0       = 100.      ! K at 1 AU
nprof    = 2.        ! MS20 (T^2 combination)
R0       = 0.01      ! AU
qprofile = 0.35      ! slope T ~ R^-0.70
T_bg     = 10.       ! K background
```

Workflow:

1. In the `.setup`, set the keys above.
2. `phantomsetup <name>` writes `<name>_00000` (IC dump, profile params in
   its header), `<name>.in`, `<name>.discparams`.
3. `phantom <name>.in` restores the profile params from the dump header
   and runs; every full dump re-persists them, so restarts are exact.
4. **Revert:** set `lumdisc=1` to restore the legacy radiative path,
   byte-identical to the pre-existing base.

**MS20 preset** (Mercer & Stamatellos 2020): `lumdisc=2, nprof=2,
qprofile=0.35, T0=100, R0=0.01, T_bg=10`.

### Parameters

`.setup` keys (the mode-2 keys are written only when `lumdisc=2`):

| `.setup` key | Internal var | Default | Meaning |
|---|---|---|---|
| `lumdisc` | — | `0` | `0` = off, `1` = luminosity radiative (legacy base), `2` = floored power-law |
| `T0` | `T0_prof` | `100.` | normalisation temperature at 1 AU (K) |
| `nprof` | `n_prof` | `2` | combination index (`n=2` = MS20 quadrature `T²`; `n=4` = flux-addition `T⁴`) |
| `R0` | `R0_prof` | `0.01` | inner smoothing radius (AU) |
| `qprofile` | `qprofile` | `0.` | slope index, `T ∝ R^(-2q)`; `0` ⇒ `q_eff = 0.35` |
| `T_bg` | `T_bg_prof` (`Tinf`) | `10.` | background temperature `T_∞` (K) |
| — | `iprofile` | `1` | internal mode selector (set to `2` by `lumdisc=2`) |

In mode 2, `L_star` is **not** used for temperature.

### Equations / mechanism

The profile is the "floored power-law":

$$
T(R) = \Big[\, T_0^{\,n}\,\big(R_{\mathrm{AU}}^2 + R_0^2\big)^{-n q}\; +\; T_\infty^{\,n}\,\Big]^{1/n}
$$

where `R_AU = R·udist/au` (radius in astronomical units) and
`q = q_eff`, with `q_eff = qprofile` if `qprofile > 0`, else the paper
default `0.35`.

- `n=2` ⇒ the MS20 *quadrature* law (Eq. 8), slope `β_T = 2q`:

$$
T^2 = T_0^2\,(R_{\mathrm{AU}}^2+R_0^2)^{-2q} + T_\infty^2
$$

- `n=4`, `R0 → 0` ⇒ the legacy flux-addition `T⁴` form, but normalised by
  `T0` rather than a stellar luminosity.
- In the irradiation-dominated regime, `T ∝ R^(-2q)`, flattening to the
  background floor `T → T_∞` at large `R`.

**Initial condition** (`set_disc.f90`). For each gas particle at
cylindrical radius `R`:

- temperature `T = get_T_profile(R)`;
- internal energy `u = getintenerg_opdep(T, ρ)` via the tabulated
  Stamatellos EOS;
- sound speed `c_s = \sqrt{\gamma\, k_B/(\mu m_H)\, T}\,/\,\text{unit\_velocity}`,
  `μ = 2.381`;
- scale height `H = c_s / Ω`.

**Runtime cooling floor** (`cooling_radapprox.f90:radcool_update_du`). The
background temperature the gas cannot radiatively cool below is:

$$
T_{\mathrm{BGR}}(R) = \texttt{get\_T\_profile}\big(\sqrt{r_i^2}\big)
$$

fed into the Stamatellos (2007)/Lombardi (2015) radiative-approximation
cooling:

$$
\frac{du_i}{dt} = \frac{4\sigma\big(T_{\mathrm{BGR}}^4 - T_i^4\big)}{\bar\Sigma_i^2\,\kappa_B(\rho_i,T_i) + \kappa_P(\rho_i,T_i)^{-1}}
$$

Unlike the legacy `iprofile=1` floor, the `iprofile=2` floor applies the
profile **directly** — there is **no** `exp(-τ)` optical-depth shielding
and **no** separate `Tfloor^4` term (the background `T_∞` is already
inside `get_T_profile`).

### Where it lives

- `src/main/eos_stamatellos.f90` — module state `iprofile, T0_prof,
  n_prof, R0_prof, T_bg_prof`; function `get_T_profile(r)`;
  `write_headeropts_flooredprof`/`read_headeropts_flooredprof`.
- `src/setup/set_disc.f90` — branches
  `get_cs_from_lum`/`get_T_from_lum`/`get_u_stamatellos`/`get_HonR` on
  `iprofile==2` to source `cs`/`u`/`T` from `get_T_profile` (the legacy
  `else` branch is byte-preserved).
- `src/setup/setup_disc.F90` — accepts `lumdisc==2` (→ `iprofile=2`,
  `T_bg_prof=T_bg`); reads/writes `T0`/`nprof`/`R0` (optional, defaulted).
- `src/main/cooling_radapprox.f90` — branches the `Tmini4` floor on
  `iprofile==2` → `get_T_profile(√ri2)**4` (no `exp(-τ)`).
- `src/main/readwrite_dumps_common.f90` — hooks
  `write_headeropts_flooredprof` into `fill_header`,
  `read_headeropts_flooredprof` into `unfill_rheader`.
- `src/tests/test_flooredprof.f90` — unit test of `get_T_profile` (4
  analytic checks); registered in `src/tests/testsuite.f90` and
  `build/Makefile` (runs under `phantomtest all`, or standalone as
  `phantomtest flooredprof`).

**Runtime source of truth = the dump header, not the `.in`.** The
IC-defining parameters `iprofile, T0_prof, nprof, R0_prof, Tinf, qprofile`
are written to (and read back from) the dump header on every full dump.
They are deliberately **absent from the `.in`**, so a user editing the
`.in` between restarts cannot desync the runtime floor from the frozen IC.
This mirrors how the `mass_loading` module (Feature 1) and `stopcond`
(Feature 2) persist their own restart-critical state.

**Verification.** `lumdisc=1` reproduces the original baseline
discparams (`T_ref = 10.06 K`); `lumdisc=2` matches the analytic formula to
`<0.1%` (`T_ref = 10.76 K`); a `T_bg=20` run confirms floor==IC (dump
header carries `Tinf=20`, `T_out=20.3 K`); profile params persist from the
setup dump into a later full dump written with an `.in` lacking them.

---

## Files changed

Behaviour Fortran only, master..fork, ~1027 insertions total.

| File | Status | Change |
|---|---|---|
| `src/main/evolve_massloading.f90` | new (556 lines) | Feature 1 — comoving mass loading module |
| `src/main/stopcond.f90` | new (136 lines) | Feature 2 — sink-count stop condition module |
| `src/main/eos_stamatellos.f90` | modified (+70) | Features 3 & 4 — `qprofile`; `iprofile`/`get_T_profile`/floored-profile header I/O |
| `src/setup/set_disc.f90` | modified (+78) | Feature 4 — `iprofile==2` branches in `get_cs_from_lum`/`get_T_from_lum`/`get_u_stamatellos`/`get_HonR` |
| `src/setup/setup_disc.F90` | modified (+85, renamed from `.f90`) | Features 3 & 4 — `qprofile`/`lumdisc==2` `.setup` handling; `get_Lstar_from_mass` |
| `src/main/cooling_radapprox.f90` | modified (+26) | Features 3 & 4 — `q_eff`/`iprofile==2` branches in the `Tmini4` floor |
| `src/main/evolve.F90` | modified (+26, renamed from `.f90`) | Features 1 & 2 — mass-loading call site (`#ifdef MASS_LOADING`), `stopcond_triggered` check |
| `src/main/readwrite_dumps_common.f90` | modified (+17) | Features 1, 2 & 4 — dump-header hooks (`fill_header`/`unfill_rheader`) |
| `src/main/checksetup.f90` | modified (+36) | Features 1 & 2 — validation |
| `src/main/checkconserved.f90` | modified (+10) | Feature 1 — suppress conservation warnings during loading |
| `src/main/config.F90` | modified (+9) | Feature 1 — `use_mass_loading` compile-time flag; stopcond wiring |
| `src/main/readwrite_infile.f90` | modified (+8) | Features 1 & 2 — `.in` read/write |
| `src/main/evolve_utils.F90` | modified (+2) | supporting change for `.F90` conversion |
| `src/main/readwrite_dumps.f90` | modified (+2) | supporting change for dump-header hooks |

---

## Design principles

- **Compile-time optionality.** Feature 1 (mass loading) is fully
  removable at build time via `-DMASS_LOADING`; when not defined, the call
  site and module are simply absent from the binary.
- **Restart-critical state lives in the dump header, not the `.in`.**
  Mass loading (`dm_load`, `r_orb`, `R_load`, `mload_mp0`, `mload_tinit`),
  stopcond (`nptmass0`), and the floored power-law profile (`iprofile,
  T0_prof, nprof, R0_prof, Tinf, qprofile`) are all defined once — at setup
  or at t=0 — and then persisted through the dump header on every full
  dump, so restarts are exact even if a user edits the `.in` in between.
- **Reversibility.** Every new mode is gated behind an explicit flag
  (`iload_factor=-1`, `max_created_sinks=-1`, `iprofile=1`,
  `lumdisc=0/1`) whose default reproduces the pre-existing, legacy
  behaviour byte-for-byte; existing `.setup`/`.in` files and dumps are
  unaffected.

## References

- Mercer, A. & Stamatellos, D. 2020, A&A 633, A116 — disc fragmentation
  around M dwarfs; temperature profile (Eq. 8) and mass-loading method.
- Stamatellos, D. et al. 2007, A&A 475, 37 — radiative-cooling
  approximation and tabulated EOS.
- Lombardi, J. C. et al. 2015 — column-density estimator (modified
  Lombardi, `od_method`) underlying the radiative-cooling approximation.
