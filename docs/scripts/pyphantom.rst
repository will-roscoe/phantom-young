pyphantom
=========

``scripts/pyphantom/`` is a pure-Python package for reading Phantom binary
dump files without needing a compiled Fortran library.  It was written by
Lionel Siess and Stéven Toupin and uses ``numpy`` memory-mapped I/O for
efficient access to large dumps.

.. note::

   This package is experimental and was last tested with dumps produced around
   2021.  It targets 64-bit machines and does not support MHD dumps.  For
   production use, the ``splash`` or ``mcfost`` interfaces are more robust.

Installation
------------

No installation step is required.  Add the ``scripts/`` directory to your
``PYTHONPATH``:

.. code-block:: bash

   export PYTHONPATH=/path/to/phantom/scripts:$PYTHONPATH

Usage
-----

.. code-block:: python

   from pyphantom import pyphantom

   # Read a dump file
   dump = pyphantom.read('blast_00010')

   # Access particle positions and densities
   x, y, z = dump.x, dump.y, dump.z
   rho      = dump.rho
   h        = dump.h

The module reads the Phantom binary header to determine the number of
particles and stored arrays, then memory-maps the data arrays for efficient
access.

Package contents
----------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - File
     - Description
   * - ``pyphantom.py``
     - Main dump reader; provides ``read()`` entry point.
   * - ``pyphantomobjects.py``
     - Data container classes for particles, sinks, and header metadata.
   * - ``pyphantomplotting.py``
     - Convenience plotting routines wrapping ``matplotlib``.
   * - ``phantomanalysis.py``
     - Analysis utilities (column density, velocity dispersion, etc.).
   * - ``constants_cgs.py``
     - Physical constants in CGS units matching Phantom's internal values.

.. seealso::

   :doc:`ev-scripts` — scripts for reading ``.ev`` time-series files.

   :doc:`../api/main/readwrite_dumps` — Fortran source for the binary dump
   format.
