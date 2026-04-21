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
