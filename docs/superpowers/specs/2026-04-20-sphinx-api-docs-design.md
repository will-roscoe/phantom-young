---
title: Phantom Sphinx API Documentation — Full Coverage Design
date: 2026-04-20
status: approved
---

# Phantom Sphinx API Documentation — Full Coverage Design

## Goal

Integrate a fully dedicated, comprehensive API reference section into the existing Phantom Sphinx documentation at `docs/`. Coverage spans the entire codebase (`src/main/`, `src/setup/`, `src/utils/`, `src/tests/`, `src/lib/`). Documentation depth is tiered by module significance. All methods derived from external works are properly cited via the existing `phantom.bib` bibliography. A `/document-module` Claude Code skill enables on-demand deep documentation of individual modules.

---

## 1. Directory Structure

The existing `docs/api/` directory is extended. The top-level `docs/index.rst` already references `api/index`, so no top-level changes are needed.

```
docs/api/
  index.rst            ← API reference landing page (rewritten)
  main/                ← src/main/ — Tier 1 full treatment
    index.rst
    <module>.rst       ← one file per .f90 / .F90
  setup/               ← src/setup/ — Tier 1 for physics-heavy; Tier 2 for helpers
    index.rst
    <module>.rst
  utils/               ← src/utils/ — Tier 2 for significant modules; Tier 3 for trivial utilities
    index.rst
    <module>.rst
  tests/               ← src/tests/ — Tier 3 stubs only (or omitted)
    index.rst
  libraries.rst        ← single summary page for NICIL and other discrete external libraries
```

`docs/api/index.rst` becomes a proper landing page with a short introduction to the API reference and toctrees to each subdirectory.

---

## 2. Documentation Tiers

### Tier 1 — Full (default for `/document-module`)

Applied to: all `src/main/`, physics-heavy `src/setup/` modules, significant `src/utils/` modules (e.g. `utils_binary`, `utils_mathfunc`).

```rst
<Module Name>
=============

Overview
--------
Narrative description: module purpose, role in the SPH algorithm or simulation
pipeline, key physical concepts introduced or assumed.

Physical & Mathematical Description
-------------------------------------
Prose explanation of governing equations with inline and display math::

   .. math::

      \frac{Dv_i}{Dt} = -\sum_j m_j \left[ \frac{P_i}{\Omega_i \rho_i^2} \nabla_i W_{ij}(h_i)
      + \frac{P_j}{\Omega_j \rho_j^2} \nabla_i W_{ij}(h_j) \right]

Assumptions, limits of applicability, and connections to other modules are noted here.

Derivations
-----------
Step-by-step derivation excerpts (where the method is non-trivial or derived
from a cited work). Numbered equations where referenced later. Not all modules
require this section — omit if the mathematics is fully covered above.

References
----------
.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------
.. f:autosrcfile:: ../../../src/main/<module>.f90
```

### Tier 2 — Medium

Applied to: most `src/setup/` modules, `src/utils/` modules with non-trivial logic.

Same template as Tier 1, but the Derivations section is abbreviated or omitted where the mathematics is simple or fully described in Overview/Physical Description. Citations still included where applicable.

### Tier 3 — Stub

Applied to: `src/tests/`, obviously trivial or highly individual-use utilities.

```rst
<Module Name>
=============

<One-sentence purpose statement.>

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. f:autosrcfile:: ../../../src/<dir>/<module>.f90
```

The `.. bibliography::` block is included even in stubs wherever a `.. cite::` reference appears anywhere in the file.

**Note on citations:** Citations are not tier-restricted. Any tier may use `.. cite::` inline references and a `.. bibliography::` block wherever external works underpin the implementation.

---

## 3. Generation Tooling

### Script: `docs/scripts/generate_api_docs.py`

Replaces the existing `docs/api/generate-docs.sh`. Responsibilities:

1. **Scan** all `.f90` / `.F90` files in `src/main/`, `src/setup/`, `src/utils/`, `src/tests/`
2. **Classify** each file into Tier 1/2/3 based on:
   - Source directory (main → Tier 1 default)
   - A configurable skip-list (`SKIP_MODULES`) for known trivial or single-use modules (→ Tier 3)
   - A configurable promote-list (`DEEP_MODULES`) for utils modules warranting full treatment (→ Tier 1)
3. **Generate** RST stubs using the appropriate template — files containing the sentinel `.. phantom-doc: hand-written` are not overwritten (only their `index.rst` entry is ensured)
4. **Write or update** `index.rst` for each `docs/api/` subdirectory, preserving existing entries
5. **Generate** `docs/api/libraries.rst` as a summary page for NICIL and other discrete external libraries
6. **Report** files added, skipped, and updated to stdout

### Sentinel

Hand-written RST files include the comment:
```rst
.. phantom-doc: hand-written
```
on line 1. The generation script treats such files as protected and will not overwrite them.

### Dependencies

`docs/requirements.txt` additions:
```
sphinxcontrib-bibtex>=2.0
sphinx-fortran
```

`docs/conf.py` additions:
```python
extensions = [
    'sphinx.ext.autodoc',
    'sphinxfortran.fortran_domain',
    'sphinxfortran.fortran_autodoc',
    'sphinx.ext.mathjax',
    'sphinxcontrib.bibtex',          # ← add
]

bibtex_bibfiles = ['phantom.bib']   # ← add
bibtex_default_style = 'plain'      # ← add
```

---

## 4. `/document-module` Skill

### Location

`.claude/skills/document-module.md`

### Invocation

```
/document-module <module>
/document-module <module> --stub
```

`<module>` accepts: bare name (`eos`), filename (`eos.f90`), or relative/absolute path.

### Behaviour

1. **Resolve** the module: search `src/` subdirectories for the file. Fail clearly if ambiguous or not found.
2. **Read** the full source file.
3. **Determine tier**: check directory and skip/promote lists. Default to **Tier 1** regardless of classification — the skill assumes the user wants depth. `--stub` overrides to Tier 3.
4. **Check existing docs**: if `docs/api/<subdir>/<module>.rst` exists:
   - Contains `.. phantom-doc: hand-written` → upgrade mode (fill gaps, extend sections, do not discard existing content)
   - Contains only a generated stub → replace with full content
   - Does not exist → generate fresh
5. **Generate content**: full RST matching the established template and tone:
   - Narrative overview grounded in the source code's own comments and logic
   - Physics/math with `.. math::` blocks
   - Derivation excerpts where the method is non-trivial
   - `.. cite::` refs for any method traceable to an external work; search `phantom.bib` for matches; flag unresolved citations explicitly
   - `f:autosrcfile::` autodoc block
   - Add `.. phantom-doc: hand-written` sentinel on line 1
6. **Write** the RST to `docs/api/<subdir>/<module>.rst`
7. **Update** the relevant `docs/api/<subdir>/index.rst` toctree if the module was not previously listed
8. **Report** the path written and any unresolved citations

### Tone & Style

- Physics-textbook register: precise, formal, self-contained
- Equations typeset via LaTeX (`.. math::`)
- Numbered equations where cross-referenced within the page
- Citations in plain bibliography style matching `phantom.bib`
- No first-person, no colloquialisms

---

## 5. Scope Summary

| Source directory | Files | Tier | Depth |
|---|---|---|---|
| `src/main/` | ~186 | 1 | Full physics/math/derivations/citations |
| `src/setup/` | ~92 | 1–2 | Full for physics-heavy; medium for setup helpers |
| `src/utils/` | ~160 | 2–3 | Medium for significant modules; stub for trivial utilities |
| `src/tests/` | ~30 | 3 | Stubs only (or omitted) |
| `src/lib/NICIL` | — | — | Single summary page in `libraries.rst` |

---

## 6. Out of Scope

- Narrative prose pages for `getting-started/`, `user-guide/`, `developer-guide/` (these exist and are not changed)
- Automated git pre-commit hook triggering doc generation (deferred to future iteration)
- Full treatment of `src/tests/` beyond stubs
