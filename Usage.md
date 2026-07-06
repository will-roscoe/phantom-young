# Floored Power-Law Temperature Profile — Usage

A generalized disc temperature prescription for radiative-cooling discs
(`ieos=24` / `icooling=9`), selected with `lumdisc = 2`. It replaces the legacy
luminosity-radiative temperature law with a single analytic **floored power-law**
that is used **identically** by the disc initial condition and by the runtime
radiative-cooling floor, so the two can never desync. The **Mercer & Stamatellos
(2020)** MS20 profile is the `n = 2` preset.

This document covers the changes made to the original phantom-young code, how to
use the feature, the full parameter set, and the equations implemented.

---

## 1. Governing equation

The profile is the "floored power-law"

$$
T(R) \;=\; \Big[\; T_0^{\,n}\,\big(R_{\mathrm{AU}}^2 + R_0^2\big)^{-n q}\; +\; T_\infty^{\,n}\;\Big]^{1/n}
$$

with `R_AU = R · udist / au` (radius in astronomical units) and slope index
`q = q_eff`, where `q_eff = qprofile` if `qprofile > 0`, else the paper default
`0.35`. In code (`eos_stamatellos.f90:get_T_profile`):

```fortran
Rau   = r*udist/au
q_eff = merge(qprofile, 0.35, qprofile > 0.)
get_T_profile = ( T0_prof**n_prof * (Rau**2 + R0_prof**2)**(-n_prof*q_eff) &
                  + T_bg_prof**n_prof )**(1./n_prof)
```

Behaviour:

- In the irradiation-dominated regime `T ∝ R^(−2q)` (so `q = 0.35 → T ∝ R^(−0.70)`),
  flattening to the background floor `T → T_∞` at large `R`.
- `R_0` softens the profile at `R → 0` (irrelevant for `R_in ≳ 1 AU`).
- **`n = 2`** → the MS20 *quadrature* (T²) law,
  `T² = T_0²(R_AU²+R_0²)^(−2q) + T_∞²`, i.e. Mercer & Stamatellos (2020) Eq. 8
  with temperature slope `β_T = 2q` (`= 0.70` for `q = 0.35`).
- **`n = 4`, `R_0 → 0`** → the legacy flux-addition (T⁴) form, but normalised by
  `T_0` rather than a stellar luminosity.

## 2. How it enters the physics

**Initial condition** (`set_disc.f90`). For each gas particle at cylindrical
radius `R`:

- temperature `T = get_T_profile(R)`;
- internal energy `u = getintenerg_opdep(T, ρ)` via the tabulated Stamatellos EOS,
  so `u(T,ρ)` carries H₂ rotation/vibration, H₂ dissociation and H/He ionisation;
- sound speed `c_s = sqrt(γ · k_B/(μ m_H) · T) / unit_velocity`, `μ = 2.381`;
- scale height `H = c_s / Ω`.

**Runtime cooling floor** (`cooling_radapprox.f90:radcool_update_du`). The
background temperature the gas cannot radiatively cool below is

$$
T_{\mathrm{BGR}}(R) = \texttt{get\_T\_profile}\big(\sqrt{r_i^2}\big),
$$

fed into the Stamatellos (2007) / Lombardi (2015) radiative-approximation cooling

$$
\frac{\mathrm{d}u_i}{\mathrm{d}t} = \frac{4\,\sigma\big(T_{\mathrm{BGR}}^4 - T_i^4\big)}{\bar\Sigma_i^2\,\kappa_{\mathrm{B}}(\rho_i,T_i) + \kappa_{\mathrm{P}}(\rho_i,T_i)^{-1}} .
$$

Unlike the legacy `iprofile=1` floor, the `iprofile=2` floor applies the profile
**directly** — no `exp(−τ)` optical-depth shielding and no separate `Tfloor⁴`
term (the background `T_∞` is already inside `get_T_profile`). Because the IC and
the floor call the **same** function with the **same** parameters, the disc
starts, and stays floored, on one consistent temperature law: **floor == IC**.

## 3. Parameter set

`.setup` keys (read by `phantomsetup`; the mode-2 keys are written only when
`lumdisc = 2`):

| `.setup` key | Internal var | Default | Meaning |
|---|---|---|---|
| `lumdisc` | — | `0` | `0` = off, `1` = luminosity radiative (legacy), `2` = floored power-law |
| `T0` | `T0_prof` | `100.` | normalisation temperature at 1 AU (K) |
| `nprof` | `n_prof` | `2.` | combination index (`2` = MS20 T², `4` = flux-add T⁴) |
| `R0` | `R0_prof` | `0.01` | inner smoothing radius (AU) |
| `qprofile` | `qprofile` | `0.` | slope index, `T ∝ R^(−2q)`; `0` ⇒ `q_eff = 0.35` |
| `T_bg` | `T_bg_prof` (`Tinf`) | `10.` | background temperature `T_∞` (K) |
| — | `iprofile` | `1` | internal mode selector (set to `2` by `lumdisc=2`) |

In mode 2, `L_star` is **not** used for temperature.

**Runtime source of truth = the dump header, not the `.in`.** The IC-defining
parameters are written to (and read back from) the dump header on every full dump
(`write/read_headeropts_flooredprof`, keys `iprofile, T0_prof, nprof, R0_prof,
Tinf, qprofile`). They are deliberately **absent from the `.in`**, so a user
editing the `.in` between restarts cannot desync the runtime floor from the frozen
IC. This mirrors how the `mass_loading` module persists its restart-critical state.

## 4. Usage

1. In the `.setup`, set:
   ```
   lumdisc  = 2        ! floored power-law
   T0       = 100.     ! K at 1 AU
   nprof    = 2.       ! MS20
   R0       = 0.01     ! AU
   qprofile = 0.35     ! slope T ~ R^-0.70
   T_bg     = 10.      ! K background
   ```
2. `phantomsetup <name>` → writes `<name>_00000` (IC dump, params in its header),
   `<name>.in`, `<name>.discparams`.
3. `phantom <name>.in` → restores the profile params from the dump header and runs.
   Every full dump re-persists them, so restarts are exact.
4. **Revert:** `lumdisc = 1` restores the legacy radiative path, byte-identical.

**MS20 preset** (Mercer & Stamatellos 2020): `lumdisc=2, nprof=2, qprofile=0.35,
T0=100, R0=0.01, T_bg=10`.

## 5. Changes to the original code

| File | Change |
|---|---|
| `src/main/eos_stamatellos.f90` | module state (`iprofile, T0_prof, n_prof, R0_prof, T_bg_prof`); `get_T_profile(r)`; `write/read_headeropts_flooredprof` (dump-header persistence) |
| `src/setup/set_disc.f90` | branch `get_cs_from_lum`/`get_T_from_lum`/`get_u_stamatellos`/`get_HonR` on `iprofile==2` to source `cs`/`u`/`T` from `get_T_profile` (legacy `else` verbatim) |
| `src/setup/setup_disc.F90` | accept `lumdisc==2` (→ `iprofile=2`, `T_bg_prof=T_bg`); read/write `T0`/`nprof`/`R0` (optional, defaulted) |
| `src/main/cooling_radapprox.f90` | branch the `Tmini4` floor on `iprofile==2` → `get_T_profile(√ri2)**4` (no `exp(−τ)`) |
| `src/main/readwrite_dumps_common.f90` | hook `write_headeropts_flooredprof` into `fill_header`, `read_headeropts_flooredprof` into `unfill_rheader` |
| `src/tests/test_flooredprof.f90` | unit test of `get_T_profile` (4 checks) |
| `src/tests/testsuite.f90`, `build/Makefile` | register the `flooredprof` test (runs under `phantomtest all`) |
| `docs/api/main/eos_stamatellos.rst` | API documentation |

All new behaviour is gated behind `iprofile==2` (default `1`); legacy `lumdisc=0/1`
runs, `.setup`/`.in` files and pre-existing dumps are unchanged.

## 6. Verification

- `phantomtest flooredprof` — 4 analytic checks of `get_T_profile` (1/10/1000 AU and
  a `qprofile` override), plus `phantomtest cooling` regression.
- Integration: `lumdisc=1` reproduces the original discparams (`T_ref = 10.06 K`);
  `lumdisc=2` matches `get_T_profile` to `<0.1%` (`T_ref = 10.76 K`); a `T_bg = 20`
  run confirms floor==IC (dump header carries `Tinf = 20`, `T_out = 20.3 K`); the
  profile params persist from the setup dump into a later full dump written with the
  `.in` lacking them.

## References

- Mercer, A. & Stamatellos, D. 2020, A&A 633, A116 — disc fragmentation around M
  dwarfs; temperature profile (Eq. 8) and mass-loading method.
- Stamatellos, D. et al. 2007, A&A 475, 37 — radiative-cooling approximation and
  tabulated EOS.
- Lombardi, J. C. et al. 2015; Young, M. D. et al. 2024 — column-density estimator
  (modified Lombardi, `od_method`).
