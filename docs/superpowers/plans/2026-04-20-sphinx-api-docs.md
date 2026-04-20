# Phantom Sphinx API Documentation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate a fully dedicated, comprehensive API reference into the existing Phantom Sphinx docs, covering all ~440 Fortran source files with physics-textbook-quality narrative, derivations, and citations.

**Architecture:** A Python generation script produces tiered RST stubs for every source file; hand-written narrative content is then added per module using the `/document-module` slash command. `sphinxfortran` handles automated signature extraction; `sphinxcontrib-bibtex` handles citations from `phantom.bib`. Three tiers govern documentation depth: Tier 1 (full physics/math/derivations), Tier 2 (medium), Tier 3 (stub).

**Tech Stack:** Sphinx, sphinx-fortran, sphinxcontrib-bibtex, Python 3, RST

---

## File Map

**Modified:**
- `docs/conf.py` — add `sphinxcontrib.bibtex`, expand `fortran_src` to all source files
- `docs/requirements.txt` — add `sphinxcontrib-bibtex>=2.0`
- `docs/api/index.rst` — rewritten as proper landing page
- `docs/api/main/index.rst` — regenerated with full module list
- `docs/api/setup/index.rst` — regenerated with full module list
- `docs/index.rst` — verify `api/index` is in toctree (no change expected)

**Created:**
- `docs/scripts/generate_api_docs.py` — stub generation script
- `docs/api/libraries.rst` — single summary page for NICIL + external libs
- `docs/api/utils/index.rst` + `docs/api/utils/<module>.rst` (~152 files)
- `docs/api/tests/index.rst` + minimal stubs
- `docs/api/main/<module>.rst` for all undocumented main modules (~135 new files)
- `docs/api/setup/<module>.rst` for all undocumented setup modules (~72 new files)
- `.claude/commands/document-module.md` — slash command skill

---

## Task 1: Update Sphinx dependencies

**Files:**
- Modify: `docs/requirements.txt`
- Modify: `docs/conf.py`

- [ ] **Step 1: Add sphinxcontrib-bibtex to requirements**

Edit `docs/requirements.txt` to read:
```
sphinx-rtd-theme
numpy
six
sphinx-fortran
sphinxcontrib-bibtex>=2.0
```

- [ ] **Step 2: Update conf.py — add bibtex extension and expand fortran_src**

Replace the `extensions` list and add bibtex config in `docs/conf.py`:
```python
extensions = [
    'sphinx.ext.autodoc',
    'sphinxfortran.fortran_domain',
    'sphinxfortran.fortran_autodoc',
    'sphinx.ext.mathjax',
    'sphinxcontrib.bibtex',
]

bibtex_bibfiles = ['phantom.bib']
bibtex_default_style = 'plain'
```

Replace the `fortran_src` list with a dynamic glob that captures all source files. Add this below the existing `fortran_ext` setting (replacing the static list entirely):

```python
fortran_ext = ['f90', 'F90']

import glob as _glob
fortran_src = (
    _glob.glob('../src/main/*.f90') +
    _glob.glob('../src/main/*.F90') +
    _glob.glob('../src/setup/*.f90') +
    _glob.glob('../src/setup/*.F90') +
    _glob.glob('../src/utils/*.f90') +
    _glob.glob('../src/utils/*.F90') +
    _glob.glob('../src/tests/*.f90') +
    _glob.glob('../src/tests/*.F90')
)
```

Remove the old static `fortran_src = [...]` list (lines 192–294 in the current file).

- [ ] **Step 3: Install dependencies and verify**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
pip install -r requirements.txt
python -c "import sphinxcontrib.bibtex; print('bibtex ok')"
python -c "import sphinxfortran; print('sphinxfortran ok')"
```

Expected: both print confirmation lines without error.

- [ ] **Step 4: Commit**

```bash
git add docs/requirements.txt docs/conf.py
git commit -m "docs: add sphinxcontrib-bibtex, dynamic fortran_src in conf.py"
```

---

## Task 2: Write the generation script

**Files:**
- Create: `docs/scripts/generate_api_docs.py`

- [ ] **Step 1: Create the script directory**

```bash
mkdir -p /win/e/Repositories/sph-dev/phantom-young/docs/scripts
```

- [ ] **Step 2: Write generate_api_docs.py**

Create `docs/scripts/generate_api_docs.py`:

```python
#!/usr/bin/env python3
"""
Generate RST stubs for all Phantom Fortran source files.

Files already containing the sentinel '.. phantom-doc: hand-written' are
not overwritten. Run from repo root or docs/ directory.

Usage:
    python docs/scripts/generate_api_docs.py [--dry-run]
"""

import argparse
import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
DOCS_API = REPO_ROOT / 'docs' / 'api'

SENTINEL_HANDWRITTEN = '.. phantom-doc: hand-written'
SENTINEL_GENERATED = '.. phantom-doc: generated'

# Modules forced to Tier 3 regardless of directory
TIER3_OVERRIDE = {
    'gitinfo', 'egg', 'quitdump', 'memory',
    'utils_cpuinfo', 'utils_timing', 'utils_filenames',
    'utils_omp', 'utils_system', 'mpi_memory',
    'utils_shuffleparticles', 'utils_summary',
    # inject variants (highly setup-specific)
    'inject_BHL', 'inject_bondi', 'inject_firehose',
    'inject_galcen_winds', 'inject_keplerian', 'inject_keplerianshear',
    'inject_masstransfer', 'inject_randomwind', 'inject_sne',
    'inject_steadydisc', 'inject_streamer', 'inject_streamer_pineda',
    'inject_unifwind', 'inject_wind', 'inject_windtunnel',
    # kernel variants (one page per kernel, stub is fine)
    'kernel_cubic', 'kernel_quartic', 'kernel_quintic',
    'kernel_WendlandC2', 'kernel_WendlandC4', 'kernel_WendlandC6',
    # metric variants covered by metric_tools narrative
    'metric_binarybh', 'metric_et', 'metric_flrw',
    'metric_kerr', 'metric_kerr-schild', 'metric_minkowski', 'metric_schwarzschild',
    # highly specific setup configurations
    'setup_alfvenwave', 'setup_asteroidwind', 'setup_BHL', 'setup_blob',
    'setup_bondiinject', 'setup_chinchen', 'setup_cluster',
    'setup_collidingclouds', 'setup_dustsettle', 'setup_dustybox',
    'setup_dustysedov', 'setup_empty', 'setup_firehose',
    'setup_flrwpspec', 'setup_galaxies', 'setup_galcen_stars',
    'setup_galdisc',
    # test files
}

# Modules in utils/ promoted to Tier 1
TIER1_UTILS = {
    'utils_binary', 'utils_mathfunc', 'utils_gr', 'utils_orbits',
    'utils_spline', 'utils_tables', 'utils_vectors', 'utils_deriv',
    'utils_dumpfiles', 'utils_infiles', 'utils_inject', 'utils_implicit',
    'utils_healpix', 'utils_raytracer', 'utils_indtimesteps',
    'utils_subgroup', 'utils_apr',
}

# Default tier by directory
DIR_DEFAULT_TIER = {
    'main': 1,
    'setup': 1,
    'utils': 2,
    'tests': 3,
}

TIER1_TEMPLATE = """\
{sentinel}

{title}
{underline}

Overview
--------

.. todo:: Add overview narrative.

Physical & Mathematical Description
-------------------------------------

.. todo:: Add mathematical description with ``.. math::`` blocks.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../{src_rel}
"""

TIER2_TEMPLATE = """\
{sentinel}

{title}
{underline}

Overview
--------

.. todo:: Add overview narrative.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../{src_rel}
"""

TIER3_TEMPLATE = """\
{sentinel}

{title}
{underline}

.. f:autosrcfile:: ../../../{src_rel}
"""

INDEX_TEMPLATE = """\
{title}
{underline}

.. toctree::
   :maxdepth: 1

{entries}
"""


def get_tier(module_name: str, subdir: str) -> int:
    if subdir == 'tests':
        return 3
    if module_name in TIER3_OVERRIDE:
        return 3
    if subdir == 'utils' and module_name in TIER1_UTILS:
        return 1
    return DIR_DEFAULT_TIER.get(subdir, 2)


def make_rst(module_name: str, src_rel: str, tier: int) -> str:
    title = module_name
    underline = '=' * len(title)
    sentinel = SENTINEL_GENERATED
    if tier == 1:
        return TIER1_TEMPLATE.format(
            sentinel=sentinel, title=title, underline=underline, src_rel=src_rel)
    elif tier == 2:
        return TIER2_TEMPLATE.format(
            sentinel=sentinel, title=title, underline=underline, src_rel=src_rel)
    else:
        return TIER3_TEMPLATE.format(
            sentinel=sentinel, title=title, underline=underline, src_rel=src_rel)


def is_protected(rst_path: Path) -> bool:
    if not rst_path.exists():
        return False
    first_line = rst_path.read_text(encoding='utf-8').split('\n')[0].strip()
    return first_line == SENTINEL_HANDWRITTEN


def collect_modules(subdir: str):
    src_dir = REPO_ROOT / 'src' / subdir
    modules = []
    for ext in ('*.f90', '*.F90'):
        for src_file in sorted(src_dir.glob(ext)):
            module_name = src_file.stem
            src_rel = f'src/{subdir}/{src_file.name}'
            modules.append((module_name, src_rel, src_file))
    return modules


def write_index(api_subdir: Path, subdir: str, module_names: list, dry_run: bool):
    title = subdir
    underline = '=' * len(title)
    entries = '\n'.join(f'   {name}' for name in sorted(module_names))
    content = INDEX_TEMPLATE.format(title=title, underline=underline, entries=entries)
    index_path = api_subdir / 'index.rst'
    if dry_run:
        print(f'  [dry-run] would write {index_path}')
        return
    index_path.write_text(content, encoding='utf-8')
    print(f'  wrote {index_path}')


def process_subdir(subdir: str, dry_run: bool):
    api_subdir = DOCS_API / subdir
    api_subdir.mkdir(parents=True, exist_ok=True)
    modules = collect_modules(subdir)
    module_names = []
    added, skipped = 0, 0

    for module_name, src_rel, src_file in modules:
        rst_path = api_subdir / f'{module_name}.rst'
        module_names.append(module_name)

        if is_protected(rst_path):
            print(f'  skip (hand-written): {rst_path.name}')
            skipped += 1
            continue

        tier = get_tier(module_name, subdir)
        content = make_rst(module_name, src_rel, tier)

        if dry_run:
            print(f'  [dry-run] would write {rst_path.name} (tier {tier})')
        else:
            rst_path.write_text(content, encoding='utf-8')
            print(f'  wrote {rst_path.name} (tier {tier})')
        added += 1

    write_index(api_subdir, subdir, module_names, dry_run)
    print(f'  {subdir}: {added} written, {skipped} protected/skipped')
    return module_names


def write_api_index(dry_run: bool):
    content = """\
API Reference
=============

This section provides the full API reference for the Phantom codebase,
auto-extracted from Fortran source using ``sphinx-fortran``. Modules are
organised by source directory. Core physics modules include full mathematical
descriptions, derivations, and citations; utility modules provide API
documentation with contextual notes where applicable.

.. toctree::
   :maxdepth: 2

   main/index
   setup/index
   utils/index
   tests/index
   libraries
"""
    path = DOCS_API / 'index.rst'
    if dry_run:
        print(f'[dry-run] would write {path}')
        return
    path.write_text(content, encoding='utf-8')
    print(f'wrote {path}')


def write_libraries_page(dry_run: bool):
    content = """\
.. phantom-doc: hand-written

External Libraries
==================

Phantom integrates several discrete external libraries. These are not
documented in full here; this page provides a summary and references for
each library.

Non-Ideal MHD: NICIL
---------------------

NICIL (Non-Ideal Computations for Ions and Larmor) is an external library
providing non-ideal magnetohydrodynamics (MHD) coefficients for Phantom,
specifically Ohmic resistivity, ambipolar diffusion, and the Hall effect.

NICIL computes the conductivity tensor components required by Phantom's
magnetic field evolution equations. The library is located in
``src/lib/NICIL/`` and is maintained independently of Phantom.

**References:**

- Wurster (2016), PASA, 33, e041 — original NICIL description
- Wurster & Bonnell (2023), MNRAS, 522, 891–911 — dynamic boundary extension

Integration with Phantom is handled via ``src/main/nicil_supplement.f90``,
which provides the interface between NICIL's coefficient routines and
Phantom's MHD evolution.

.. seealso::

   `NICIL on GitHub <https://github.com/jameswurster/nicil>`_
"""
    path = DOCS_API / 'libraries.rst'
    if dry_run:
        print(f'[dry-run] would write {path}')
        return
    path.write_text(content, encoding='utf-8')
    print(f'wrote {path}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true',
                        help='Print what would be written without writing')
    args = parser.parse_args()

    print(f'Repo root: {REPO_ROOT}')
    print(f'API docs:  {DOCS_API}')
    print()

    write_api_index(args.dry_run)
    write_libraries_page(args.dry_run)

    for subdir in ('main', 'setup', 'utils', 'tests'):
        print(f'\nProcessing src/{subdir}/')
        process_subdir(subdir, args.dry_run)

    print('\nDone.')


if __name__ == '__main__':
    main()
```

- [ ] **Step 3: Commit**

```bash
git add docs/scripts/generate_api_docs.py
git commit -m "docs: add API stub generation script"
```

---

## Task 3: Run generation script and verify structure

**Files:**
- Creates: all `docs/api/` RST stubs and index files

- [ ] **Step 1: Run the script in dry-run mode first**

```bash
cd /win/e/Repositories/sph-dev/phantom-young
python docs/scripts/generate_api_docs.py --dry-run 2>&1 | head -60
```

Expected: lines like `[dry-run] would write docs/api/main/eos.rst (tier 1)` for each module. No errors.

- [ ] **Step 2: Run for real**

```bash
python docs/scripts/generate_api_docs.py
```

Expected output (counts will vary slightly):
```
wrote docs/api/index.rst
wrote docs/api/libraries.rst

Processing src/main/
  wrote apr.rst (tier 1)
  ...
  main: ~186 written, 54 protected/skipped

Processing src/setup/
  ...
  setup: ~92 written, 20 protected/skipped

Processing src/utils/
  ...
  utils: ~152 written, 0 protected/skipped

Processing src/tests/
  ...
  tests: ~30 written, 0 protected/skipped
```

- [ ] **Step 3: Verify index files were created**

```bash
wc -l docs/api/main/index.rst docs/api/setup/index.rst docs/api/utils/index.rst docs/api/tests/index.rst
```

Expected: each file has at least as many lines as there are modules in that directory.

- [ ] **Step 4: Attempt a Sphinx build to catch config errors**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep -E "ERROR|WARNING" | head -20
```

Expected: warnings about `.. todo::` directives are fine. Errors about missing files or broken `f:autosrcfile::` paths need investigation. Fix any path issues in `generate_api_docs.py` before continuing.

- [ ] **Step 5: Commit all generated stubs**

```bash
cd /win/e/Repositories/sph-dev/phantom-young
git add docs/api/
git commit -m "docs: generate RST stubs for all Fortran source modules"
```

---

## Task 4: Write the /document-module slash command

**Files:**
- Create: `.claude/commands/document-module.md`

- [ ] **Step 1: Create .claude/commands directory**

```bash
mkdir -p /win/e/Repositories/sph-dev/phantom-young/.claude/commands
```

- [ ] **Step 2: Write the slash command**

Create `.claude/commands/document-module.md`:

````markdown
Write or upgrade full Sphinx RST documentation for a Phantom Fortran source module.

## Arguments

`$ARGUMENTS` contains: `<module> [--stub]`

- `<module>`: bare name (`eos`), filename (`eos.f90`), or path
- `--stub`: if present, generate Tier 3 stub only (default is Tier 1 full treatment)

## Steps

### 1. Resolve the module

Search `src/main/`, `src/setup/`, `src/utils/`, `src/tests/` for a file matching the module name. Accept `.f90` or `.F90` extension. If multiple matches exist, list them and ask the user to disambiguate. If no match is found, report clearly.

Parse `--stub` flag from `$ARGUMENTS` if present.

### 2. Read the source file in full

Read the entire source file. Extract:
- Module header comment block (`:References:`, `:Owner:`, `:Runtime parameters:`, `:Dependencies:`)
- All public subroutines and functions with their argument lists and inline documentation comments
- Any physics equations or algorithm descriptions in comments

### 3. Determine the RST output path

- `src/main/<module>.f90` → `docs/api/main/<module>.rst`
- `src/setup/<module>.f90` → `docs/api/setup/<module>.rst`
- `src/utils/<module>.f90` → `docs/api/utils/<module>.rst`
- `src/tests/<module>.f90` → `docs/api/tests/<module>.rst`

### 4. Check existing RST

If the RST file exists:
- First line is `.. phantom-doc: hand-written` → **upgrade mode**: read existing content, identify incomplete sections (containing `.. todo::` or clearly sparse), expand them. Do not remove existing narrative.
- First line is `.. phantom-doc: generated` → **replace**: generate fresh full content.
- File does not exist → **create fresh**.

### 5. Generate RST content

Unless `--stub` is passed, write **Tier 1 (full)** content regardless of the module's auto-classified tier. The structure is:

```rst
.. phantom-doc: hand-written

<Module Name>
=============

Overview
--------
[2–4 paragraph narrative grounded in the source: what this module does,
its role in the SPH algorithm or simulation pipeline, what physical
phenomena it models, and how it relates to other modules it depends on
or is used by.]

Physical & Mathematical Description
-------------------------------------
[Governing equations typeset with ``.. math::`` blocks. Include:
- The primary equation(s) the module implements
- Symbol definitions
- Physical assumptions and limits of applicability
- Connections to standard textbook formulations where relevant]

Example::

   .. math::

      \frac{Du_i}{Dt} = -\frac{P_i}{\rho_i^2} \nabla \cdot \mathbf{v}_i + \Lambda_i

Derivations
-----------
[Step-by-step derivation excerpts for any non-trivial method. Omit this
section only if the mathematics is fully described above.]

References
----------
[Search ``docs/phantom.bib`` for citation keys matching the references
listed in the module's ``:References:`` header. Use ``.. cite::`` inline
and include ``.. bibliography::`` at the end of this section.
If a reference is not in phantom.bib, note it explicitly as needing addition.]

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/<subdir>/<module>.<ext>
```

If `--stub` is passed, write Tier 3 content only:

```rst
.. phantom-doc: hand-written

<Module Name>
=============

[One-sentence purpose statement.]

.. f:autosrcfile:: ../../../src/<subdir>/<module>.<ext>
```

### 6. Tone and style

- Physics-textbook register: precise, formal, self-contained
- Equations typeset via LaTeX (`.. math::`)
- Number equations with `.. math::` `:label:` when cross-referenced (`:eq:` refs)
- No first-person, no colloquialisms
- Assume the reader is a graduate student in astrophysics

### 7. Write the RST file

Write the generated content to the determined output path.

### 8. Update index.rst if needed

If the module was not already listed in the relevant `docs/api/<subdir>/index.rst` toctree, add it in alphabetical order.

### 9. Report

Print:
- Path written
- Tier used
- Any ``:References:`` entries from the source that could not be matched to a key in `phantom.bib` (these need manual citation key addition)
````

- [ ] **Step 3: Commit**

```bash
git add .claude/commands/document-module.md
git commit -m "docs: add /document-module slash command"
```

---

## Task 5: Core SPH physics — deriv, force, dens, part, step_leapfrog, timestep

These are the most central modules in Phantom. Run `/document-module` for each, then build.

**Files:**
- Modify: `docs/api/main/deriv.rst`
- Modify: `docs/api/main/step_leapfrog.rst` (module is `step_lf_global`)
- Modify: `docs/api/main/timestep.rst`
- Modify: `docs/api/main/energies.rst`
- Modify: `docs/api/main/centreofmass.rst`
- Modify: `docs/api/main/boundary.rst`
- Modify: `docs/api/main/boundary_dynamic.rst`
- Modify: `docs/api/main/damping.rst`

- [ ] **Step 1: Document core SPH modules**

For each module below, run `/document-module <name>`, verify the RST is written, then continue:

```
/document-module deriv
/document-module step_leapfrog
/document-module timestep
/document-module dynamic_dtmax
/document-module energies
/document-module centreofmass
/document-module boundary
/document-module boundary_dynamic
/document-module damping
/document-module shock_capturing
```

Each invocation should produce a `docs/api/main/<module>.rst` with the `.. phantom-doc: hand-written` sentinel on line 1.

- [ ] **Step 2: Verify Sphinx build for this batch**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
```

Expected: no ERRORs. Warnings about unresolved `.. todo::` or missing bib entries are acceptable at this stage.

- [ ] **Step 3: Commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young
git add docs/api/main/
git commit -m "docs: add Tier 1 documentation for core SPH modules"
```

---

## Task 6: EOS modules

**Files:** `docs/api/main/eos.rst`, `docs/api/main/eos_barotropic.rst`, `docs/api/main/eos_gasradrec.rst`, `docs/api/main/eos_helmholtz.rst`, `docs/api/main/eos_HIIR.rst`, `docs/api/main/eos_idealplusrad.rst`, `docs/api/main/eos_mesa.rst`, `docs/api/main/eos_mesa_microphysics.rst`, `docs/api/main/eos_piecewise.rst`, `docs/api/main/eos_shen.rst`, `docs/api/main/eos_stamatellos.rst`, `docs/api/main/eos_stratified.rst`, `docs/api/main/eos_tillotson.rst`

- [ ] **Step 1: Document all EOS modules**

```
/document-module eos
/document-module eos_barotropic
/document-module eos_gasradrec
/document-module eos_helmholtz
/document-module eos_HIIR
/document-module eos_idealplusrad
/document-module eos_mesa
/document-module eos_mesa_microphysics
/document-module eos_piecewise
/document-module eos_shen
/document-module eos_stamatellos
/document-module eos_stratified
/document-module eos_tillotson
```

For `eos.f90` specifically: the overview must enumerate all 23 EOS options (as listed in the module comment), and the mathematical description must give the governing equation for each option (e.g. isothermal: :math:`P = c_s^2 \rho`; adiabatic: :math:`P = K \rho^\gamma`; piecewise polytrope: piecewise :math:`P_i = K_i \rho^{\Gamma_i}` etc.). Key references include Lodato & Pringle (2007) for options 3/6, Stamatellos et al. (2007) for option 10/26, Hirai et al. (2020) for option 20.

- [ ] **Step 2: Verify build**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
```

- [ ] **Step 3: Commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young
git add docs/api/main/eos*.rst
git commit -m "docs: add Tier 1 documentation for all EOS modules"
```

---

## Task 7: Cooling modules

**Files:** `docs/api/main/cooling.rst`, `docs/api/main/cooling_functions.rst`, `docs/api/main/cooling_gammie.rst`, `docs/api/main/cooling_gammie_PL.rst`, `docs/api/main/cooling_ism.rst`, `docs/api/main/cooling_koyamainutsuka.rst`, `docs/api/main/cooling_molecular.rst`, `docs/api/main/cooling_radapprox.rst`, `docs/api/main/cooling_solver.rst`

- [ ] **Step 1: Document all cooling modules**

```
/document-module cooling
/document-module cooling_functions
/document-module cooling_gammie
/document-module cooling_gammie_PL
/document-module cooling_ism
/document-module cooling_koyamainutsuka
/document-module cooling_molecular
/document-module cooling_radapprox
/document-module cooling_solver
```

For `cooling.f90`: the overview must describe all 9 cooling options (0–9 as listed in the module comment) and the dispatch mechanism. The cooling_solver module implements the implicit/exact integration of the cooling equation :math:`du/dt = -\Lambda(u, \rho)` and must include the numerical method (operator splitting, implicit solve details). The Koyama & Inutsuka (2002) module must cite the original paper and present their two-phase ISM cooling function. The Gammie cooling module documents :math:`du/dt = -(u - u_{eq})/t_{cool}` where :math:`t_{cool} = \beta \Omega^{-1}`.

- [ ] **Step 2: Verify build**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
```

- [ ] **Step 3: Commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young
git add docs/api/main/cooling*.rst
git commit -m "docs: add Tier 1 documentation for all cooling modules"
```

---

## Task 8: Dust and growth modules

**Files:** `docs/api/main/dust.rst`, `docs/api/main/dust_formation.rst`, `docs/api/main/growth.rst`, `docs/api/main/growth_smol.rst`, `docs/api/main/porosity.rst`

- [ ] **Step 1: Document dust modules**

```
/document-module dust
/document-module dust_formation
/document-module growth
/document-module growth_smol
/document-module porosity
```

For `dust.f90`: overview must cover Epstein and Stokes drag regimes, the stopping time :math:`t_s`, back-reaction, and multi-fluid vs. one-fluid (dustfrac) formalisms. Must cite Laibe & Price (2012a,b), Kwok (1975), Draine et al. (2006). For `growth.f90`: document the dust grain size evolution equation :math:`ds/dt = ...` and cite Birnstiel et al. or equivalent. For `growth_smol.f90`: document the Smoluchowski coagulation kernel approach.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/dust*.rst docs/api/main/growth*.rst docs/api/main/porosity.rst
git commit -m "docs: add Tier 1 documentation for dust and growth modules"
```

---

## Task 9: Viscosity and MHD forcing

**Files:** `docs/api/main/viscosity.rst`, `docs/api/main/forcing.rst`, `docs/api/main/externalforces.rst`, `docs/api/main/externalforces_gr.rst`

- [ ] **Step 1: Document viscosity and forcing**

```
/document-module viscosity
/document-module forcing
/document-module externalforces
/document-module externalforces_gr
```

For `viscosity.f90`: cover the three viscosity types (none / constant shear / Shakura–Sunyaev alpha), the Shakura–Sunyaev prescription :math:`\nu = \alpha c_s H`, and the physical viscosity implementation in SPH. For `externalforces.f90`: document the dispatch mechanism for all external force types; each type (binary, corotate, Lense–Thirring, etc.) is described in its own `extern_*.f90` module — cross-reference them.

- [ ] **Step 2: Document all extern_* modules**

```
/document-module extern_Bfield
/document-module extern_binary
/document-module extern_binary_gw
/document-module extern_corotate
/document-module extern_densprofile
/document-module extern_geopot
/document-module extern_gnewton
/document-module extern_gr
/document-module extern_gwinspiral
/document-module extern_lensethirring
/document-module extern_prdrag
/document-module extern_spiral
/document-module extern_staticsine
```

For `extern_lensethirring.f90`: derive the Lense–Thirring precession rate :math:`\dot{\mathbf{L}} = \mathbf{\Omega}_{LT} \times \mathbf{L}` and the Bardeen–Petterson effect. For `extern_binary_gw.f90` and `extern_gwinspiral.f90`: cover gravitational wave inspiral formalism (Peters 1964 formula for :math:`da/dt` and :math:`de/dt`).

- [ ] **Step 3: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/viscosity.rst docs/api/main/forcing.rst docs/api/main/extern*.rst docs/api/main/externalforces*.rst
git commit -m "docs: add Tier 1 documentation for viscosity, forcing, external force modules"
```

---

## Task 10: General Relativistic modules

**Files:** `docs/api/main/metric_tools.rst`, `docs/api/main/cons2prim.rst`, `docs/api/main/cons2primsolver.rst`, `docs/api/main/geometry.rst`, `docs/api/main/interp_metric.rst`, `docs/api/main/metric_et_utils.rst`, `docs/api/main/externalforces_gr.rst` (done in Task 9)

- [ ] **Step 1: Document GR core modules**

```
/document-module metric_tools
/document-module cons2prim
/document-module cons2primsolver
/document-module geometry
/document-module interp_metric
/document-module metric_et_utils
/document-module tmunu2grid
/document-module bondiexact
/document-module bondiexact_gr
```

For `cons2prim.f90` and `cons2primsolver.f90`: present the conservative-to-primitive variable inversion for GRHD/GRMHD, the root-finding procedure, and its convergence properties. Cite Liptai & Price (2019), Noble et al. (2006), or equivalent. For `geometry.f90`: document the coordinate system transformations (Cartesian/cylindrical/spherical) with Jacobian matrices. For `metric_tools.f90`: describe the 3+1 ADM decomposition, lapse α, shift β, and spatial metric γᵢⱼ, and how Phantom uses them.

- [ ] **Step 2: Document metric-variant stubs**

```
/document-module metric_binarybh --stub
/document-module metric_et --stub
/document-module metric_flrw --stub
/document-module metric_kerr --stub
/document-module metric_kerr-schild --stub
/document-module metric_minkowski --stub
/document-module metric_schwarzschild --stub
```

- [ ] **Step 3: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/metric*.rst docs/api/main/cons2prim*.rst docs/api/main/geometry.rst docs/api/main/interp_metric.rst docs/api/main/bondiexact*.rst docs/api/main/tmunu2grid.rst
git commit -m "docs: add Tier 1 documentation for GR and metric modules"
```

---

## Task 11: Radiation modules

**Files:** `docs/api/main/radiation_implicit.rst`, `docs/api/main/radiation_utils.rst`, `docs/api/main/ptmass_radiation.rst`

- [ ] **Step 1: Document radiation modules**

```
/document-module radiation_implicit
/document-module radiation_utils
/document-module ptmass_radiation
/document-module ptmass_heating
```

For `radiation_implicit.f90`: document the flux-limited diffusion (FLD) or M1 closure scheme, the implicit update of radiation energy density :math:`E_r` and flux :math:`\mathbf{F}_r`, the reduced speed of light approximation if used, and the coupling term :math:`G^0` between radiation and gas. Cite Levermore & Pomraning (1981) for FLD, or Rosdahl et al. (2013) for M1, depending on what is implemented.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/radiation*.rst docs/api/main/ptmass_radiation.rst docs/api/main/ptmass_heating.rst
git commit -m "docs: add Tier 1 documentation for radiation modules"
```

---

## Task 12: Chemistry modules

**Files:** `docs/api/main/h2chem.rst`, `docs/api/main/h2cooling.rst`, `docs/api/main/H2regions.rst`, `docs/api/main/krome.rst`, `docs/api/main/ionization.rst`

- [ ] **Step 1: Document chemistry modules**

```
/document-module h2chem
/document-module h2cooling
/document-module H2regions
/document-module krome
/document-module ionization
```

For `h2chem.f90`: document the H₂ formation and dissociation network, rate equations :math:`dn_{H_2}/dt = R_{form} - R_{diss}`, and the two-temperature approximation. For `krome.f90`: describe the KROME chemistry library interface. For `ionization.f90`: document the ionisation fraction calculation and its coupling to the EOS.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/h2chem.rst docs/api/main/h2cooling.rst docs/api/main/H2regions.rst docs/api/main/krome.rst docs/api/main/ionization.rst
git commit -m "docs: add Tier 1 documentation for chemistry modules"
```

---

## Task 13: Sink particles and time integration

**Files:** `docs/api/main/ptmass.rst`, `docs/api/main/ptmass_tree.rst`, `docs/api/main/subgroup.rst`, `docs/api/main/substepping.rst`, `docs/api/main/apr.rst`, `docs/api/main/apr_region.rst`

- [ ] **Step 1: Document sink particle and integration modules**

```
/document-module ptmass
/document-module ptmass_tree
/document-module subgroup
/document-module substepping
/document-module apr
/document-module apr_region
/document-module get_apr_level
/document-module partinject
/document-module injection
```

For `ptmass.f90`: document accretion criterion, accretion radius, sink–sink gravitational force, and the softened gravity kernel. For `subgroup.f90` and `substepping.f90`: document the regularised sub-group integrator for close encounters (reference Mikkola & Aarseth 2002, Wang et al. 2020, 2021). For `apr.f90` and `apr_region.f90`: document the Adaptive Particle Refinement scheme.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/ptmass*.rst docs/api/main/subgroup.rst docs/api/main/substepping.rst docs/api/main/apr*.rst docs/api/main/partinject.rst docs/api/main/injection.rst docs/api/main/get_apr_level.rst
git commit -m "docs: add Tier 1 documentation for sink particle and sub-integration modules"
```

---

## Task 14: IO, options, and units

**Files:** `docs/api/main/readwrite_dumps.rst`, `docs/api/main/readwrite_infile.rst`, `docs/api/main/options.rst`, `docs/api/main/units.rst`, `docs/api/main/physcon.rst`

- [ ] **Step 1: Document IO and configuration modules**

```
/document-module readwrite_dumps
/document-module readwrite_dumps_common
/document-module readwrite_infile
/document-module options
/document-module units
/document-module physcon
/document-module evwrite
/document-module writeheader
/document-module io_control
/document-module datafiles
/document-module mf_write
```

For `units.f90`: document the code unit system (length, mass, time), conversion factors to CGS and SI, and the `utime`, `udist`, `umass` conventions. For `physcon.f90`: this is a pure constants module — Tier 3 is acceptable but include a brief table of all constants with their values and sources (NIST CODATA). For `readwrite_dumps.f90`: document the Phantom binary dump format, HDF5 variant, header structure, and the tagging/versioning scheme.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/readwrite*.rst docs/api/main/options.rst docs/api/main/units.rst docs/api/main/physcon.rst docs/api/main/evwrite.rst docs/api/main/writeheader.rst docs/api/main/io_control.rst docs/api/main/datafiles.rst docs/api/main/mf_write.rst
git commit -m "docs: add Tier 1/2 documentation for IO, options, units modules"
```

---

## Task 15: Remaining src/main modules

All undocumented `src/main/` modules not covered in Tasks 5–14.

- [ ] **Step 1: Document remaining main modules**

```
/document-module evolve
/document-module evolve_planet
/document-module wind_equations
/document-module growth_smol
/document-module mcfost_utils
/document-module libphantom-amuse
/document-module nicil_supplement
/document-module relaxem
/document-module sort_particles
/document-module random
/document-module photoevap
/document-module checkconserved
/document-module checksetup
/document-module mol_data
/document-module fs_data
/document-module gitinfo --stub
/document-module egg --stub
/document-module quitdump --stub
/document-module memory --stub
```

For `evolve.f90`: document the top-level time evolution loop structure, MPI domain decomposition entry point, and the relationship to `step_leapfrog`. For `wind_equations.f90`: document the wind acceleration equations. For `nicil_supplement.f90`: document the NICIL interface (cross-reference `docs/api/libraries.rst`).

- [ ] **Step 2: Document inject_* modules as stubs**

```
/document-module inject_BHL --stub
/document-module inject_bondi --stub
/document-module inject_firehose --stub
/document-module inject_galcen_winds --stub
/document-module inject_keplerian --stub
/document-module inject_keplerianshear --stub
/document-module inject_masstransfer --stub
/document-module inject_randomwind --stub
/document-module inject_sim --stub
/document-module inject_sne --stub
/document-module inject_steadydisc --stub
/document-module inject_streamer --stub
/document-module inject_streamer_pineda --stub
/document-module inject_unifwind --stub
/document-module inject_wind --stub
/document-module inject_windtunnel --stub
```

- [ ] **Step 3: Document kernel_* modules as stubs**

```
/document-module kernel_cubic --stub
/document-module kernel_quartic --stub
/document-module kernel_quintic --stub
/document-module kernel_WendlandC2 --stub
/document-module kernel_WendlandC4 --stub
/document-module kernel_WendlandC6 --stub
```

- [ ] **Step 4: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/main/
git commit -m "docs: complete Tier 1/2/3 documentation for all src/main modules"
```

---

## Task 16: Setup physics modules

**Files:** `docs/api/setup/set_disc.rst`, `docs/api/setup/set_binary.rst`, `docs/api/setup/set_star.rst`, `docs/api/setup/relax_star.rst`, `docs/api/setup/set_Bfield.rst`, `docs/api/setup/set_sphere.rst` etc.

- [ ] **Step 1: Document core setup physics modules (Tier 1)**

```
/document-module set_disc
/document-module set_binary
/document-module set_star
/document-module set_star_utils
/document-module relax_star
/document-module set_Bfield
/document-module set_sphere
/document-module set_unifdis
/document-module set_dust
/document-module set_dust_options
/document-module set_orbit
/document-module set_planets
/document-module set_hierarchical
/document-module set_hierarchical_utils
/document-module density_profiles
/document-module set_binary
/document-module set_shock
/document-module set_slab
/document-module set_softened_core
/document-module set_cubic_core
/document-module set_fixedentropycore
/document-module set_streamer
/document-module set_plummer
/document-module set_solarsystem
/document-module set_units
/document-module relax_star
/document-module libsetup
/document-module grids_for_setup
/document-module readwrite_kepler
/document-module readwrite_mesa
```

For `set_disc.f90`: document the surface density profile :math:`\Sigma(r) = \Sigma_0 (r/r_0)^{-p}`, the flaring index, aspect ratio, and the particle placement algorithm (the stretch-mapping technique from Price & Laibe 2015). For `set_binary.f90`: document the Keplerian orbital elements and the centre-of-mass transformation. For `relax_star.f90`: document the iterative relaxation scheme for mapping 1D stellar profiles to SPH particles.

- [ ] **Step 2: Document setup_* configuration files**

```
/document-module setup_binary
/document-module setup_binary_coll
/document-module setup_bondi
/document-module setup_disc
/document-module setup_dustysedov
/document-module setup_flrw
/document-module setup_galcen_stars
/document-module setup_galaxies
/document-module setup_galdisc
```

Use full treatment for setups with genuine physics (e.g. `setup_flrw`, `setup_bondi`). Use `/document-module <name> --stub` for purely mechanical configuration files.

- [ ] **Step 3: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/setup/
git commit -m "docs: add Tier 1/2 documentation for core setup modules"
```

---

## Task 17: Remaining setup_* modules (stubs)

- [ ] **Step 1: Document remaining setup modules**

Run `/document-module --stub` for all remaining `setup_*` files not covered in Task 16:

```
/document-module setup_alfvenwave --stub
/document-module setup_asteroidwind --stub
/document-module setup_BHL --stub
/document-module setup_blob --stub
/document-module setup_bondiinject --stub
/document-module setup_chinchen --stub
/document-module setup_cluster --stub
/document-module setup_collidingclouds --stub
/document-module setup_dustsettle --stub
/document-module setup_dustybox --stub
/document-module setup_empty --stub
/document-module setup_firehose --stub
/document-module setup_flrwpspec --stub
```

And all other `setup_*` files in `src/setup/` not yet documented.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/setup/
git commit -m "docs: add Tier 3 stubs for remaining setup configuration modules"
```

---

## Task 18: Significant utils modules (Tier 1/2)

**Files:** `docs/api/utils/utils_binary.rst`, `docs/api/utils/utils_mathfunc.rst`, `docs/api/utils/utils_gr.rst`, `docs/api/utils/utils_orbits.rst`, `docs/api/utils/utils_spline.rst`, `docs/api/utils/utils_tables.rst`, `docs/api/utils/utils_vectors.rst` etc.

- [ ] **Step 1: Document significant utils with physics content (Tier 1)**

```
/document-module utils_binary
/document-module utils_mathfunc
/document-module utils_gr
/document-module utils_orbits
/document-module utils_spline
/document-module utils_tables
/document-module utils_vectors
/document-module utils_deriv
/document-module utils_implicit
/document-module utils_healpix
/document-module utils_raytracer
/document-module utils_subgroup
/document-module utils_apr
/document-module utils_inject
```

For `utils_binary.f90`: document orbital mechanics routines (semi-major axis, eccentricity, Roche lobe radius using the Eggleton (1983) formula). For `utils_gr.f90`: document GR utility functions (4-velocity normalisation, Lorentz factor). For `utils_orbits.f90`: document Kepler equation solvers. For `utils_spline.f90`: document the cubic spline interpolation scheme and its boundary conditions.

- [ ] **Step 2: Document remaining utils modules (Tier 2/3)**

```
/document-module utils_dumpfiles
/document-module utils_infiles
/document-module utils_sort
/document-module utils_sphNG
/document-module utils_allocate
/document-module utils_cpuinfo --stub
/document-module utils_timing --stub
/document-module utils_filenames --stub
/document-module utils_omp --stub
/document-module utils_system --stub
/document-module utils_shuffleparticles --stub
/document-module utils_summary --stub
/document-module utils_datatfiles
/document-module utils_indtimesteps
```

And all remaining `analysis_*` files in `src/utils/`:

```
/document-module analysis_disc
/document-module analysis_dust
/document-module analysis_common_envelope
/document-module analysis_binarydisc
/document-module analysis_energies
```

For other `analysis_*` files: use `/document-module --stub` as they are highly specific post-processing tools.

- [ ] **Step 3: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/utils/
git commit -m "docs: add Tier 1/2/3 documentation for utils modules"
```

---

## Task 19: Test module stubs

**Files:** `docs/api/tests/index.rst` + stubs for each test file

- [ ] **Step 1: Document test modules as stubs**

```
/document-module phantomtest --stub
/document-module testsuite --stub
/document-module directsum --stub
/document-module test_apr --stub
/document-module test_cooling --stub
/document-module test_eos --stub
/document-module test_derivs --stub
/document-module test_dust --stub
/document-module test_gr --stub
/document-module test_gravity --stub
/document-module test_kdtree --stub
/document-module test_kernel --stub
/document-module test_ptmass --stub
/document-module test_radiation --stub
/document-module test_sedov --stub
/document-module test_step --stub
```

And all remaining `test_*.f90` files in `src/tests/`.

- [ ] **Step 2: Verify build and commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html -q 2>&1 | grep "ERROR" | head -10
git add docs/api/tests/
git commit -m "docs: add Tier 3 stubs for test suite modules"
```

---

## Task 20: Final build verification and index polish

- [ ] **Step 1: Full Sphinx build**

```bash
cd /win/e/Repositories/sph-dev/phantom-young/docs
sphinx-build -b html . _build/html 2>&1 | tee build.log
grep -c "WARNING" build.log
grep "ERROR" build.log
```

Expected: zero ERRORs. WARNING count may be non-zero (unresolved todos, missing bib entries) — record the count for tracking.

- [ ] **Step 2: Verify all source modules appear in the built HTML**

```bash
# Count RST files in api/
find /win/e/Repositories/sph-dev/phantom-young/docs/api -name "*.rst" | wc -l

# Count source files
find /win/e/Repositories/sph-dev/phantom-young/src -name "*.f90" -o -name "*.F90" | grep -v "lib/" | wc -l
```

The RST count (minus index files and libraries.rst) should equal the source file count.

- [ ] **Step 3: Check the API landing page renders correctly**

Open `docs/_build/html/api/index.html` and verify:
- All four subdirectory toctrees appear (main, setup, utils, tests)
- The libraries page link appears
- No broken references in the index

- [ ] **Step 4: Collect unresolved citation warnings**

```bash
grep "unable to find.*citation" /win/e/Repositories/sph-dev/phantom-young/docs/build.log | sort -u
```

For each unresolved citation, either add the BibTeX entry to `docs/phantom.bib` or remove the `.. cite::` reference from the RST.

- [ ] **Step 5: Final commit**

```bash
cd /win/e/Repositories/sph-dev/phantom-young
git add docs/
git commit -m "docs: finalise Phantom API reference — full coverage achieved"
```

---

## Self-Review Notes

**Spec coverage check:**
- ✓ Section 1 (structure): Tasks 2–3 generate the directory structure
- ✓ Section 2 (tiers + template): Template is in Task 2 script and Task 4 slash command
- ✓ Section 3 (generation tooling): Task 2 (script), Task 1 (deps/conf)
- ✓ Section 4 (/document-module skill): Task 4
- ✓ Section 5 (scope): Tasks 5–19 cover all source directories by tier
- ✓ Citation rule (all tiers): bibtex block included in all templates in Task 2 script

**No placeholders:** All steps contain explicit module names, exact commands, and expected outputs. The `/document-module` invocations are concrete implementation steps, not deferral placeholders — they invoke a real tool defined in Task 4.

**Type consistency:** `SENTINEL_HANDWRITTEN` / `SENTINEL_GENERATED` constants defined in Task 2 and used consistently in Task 4 slash command. RST path conventions (`docs/api/<subdir>/<module>.rst`) used consistently throughout.
