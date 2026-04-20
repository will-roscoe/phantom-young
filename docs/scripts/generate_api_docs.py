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
