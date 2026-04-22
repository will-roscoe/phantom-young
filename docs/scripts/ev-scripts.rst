Energy-file scripts
===================

Phantom writes time-series diagnostics (total energy, momentum, max density,
etc.) to ``.ev`` files.  The following Python 3 scripts process these files.
They all share the ``evfiles`` helper module for consistent parsing and output.

All scripts require Python 3 and ``numpy``; ``evcat``, ``evcut``, ``ev2dot``,
and ``evsmooth`` also require ``pandas``.

----

evhead
------

Print the column names found in an ``.ev`` file.

.. code-block:: bash

   evhead.py <file>

**Arguments**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Argument
     - Description
   * - ``file``
     - Path to a Phantom ``.ev`` file.

**Output:** one column name per line, in the order they appear in the file.

----

evcat
-----

Concatenate multiple ``.ev`` files into a single time series, removing
overlapping timesteps at the join points, and write to stdout.

.. code-block:: bash

   evcat.py file1.ev file2.ev [file3.ev ...]

**Arguments**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Argument
     - Description
   * - ``file ...``
     - Two or more ``.ev`` files, assumed to be in chronological order.

Files are assumed to share the same column header.  Overlapping rows (where the
time in an earlier file exceeds the start time of the next file) are removed
before concatenation.

----

evcut
-----

Extract a subset of columns from one or more ``.ev`` files and write to stdout.

.. code-block:: bash

   evcut.py -f file1.ev [file2.ev ...] -c col1 [col2 ...]

**Options**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Option
     - Description
   * - ``-f``, ``--file``
     - One or more ``.ev`` files (required).
   * - ``-c``, ``--columns``
     - Column names or 1-based integer indices to extract (required).

Multiple files are concatenated with overlap removal before the column
selection is applied.

----

ev2dot
------

Compute the time derivative of selected columns in one or more ``.ev`` files.

.. code-block:: bash

   ev2dot.py -f file1.ev [file2.ev ...] [-c col1 col2 ...] [-dt dtmin]

**Options**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Option
     - Description
   * - ``-f``, ``--file``
     - One or more ``.ev`` files (required).
   * - ``-c``, ``--columns``
     - Column names or integer indices to differentiate.  If omitted, all
       columns except time are differentiated.
   * - ``-dt``, ``--dtmin``
     - Minimum time interval over which to compute the derivative.
       Rows closer than ``dtmin`` in time are skipped.

Output columns are named ``<original> dot``.  The time column is preserved.
Multiple files are concatenated with overlap removal before differentiation.

----

evsmooth
--------

Smooth ``.ev`` file data by averaging adjacent rows separated by at least
a given time interval.

.. code-block:: bash

   evsmooth.py file1.ev [file2.ev ...] [-dt dt]

**Options**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Option
     - Description
   * - ``evfiles``
     - One or more ``.ev`` files.
   * - ``-dt``
     - Time interval for smoothing (default: 0, i.e. no smoothing).

Averaging uses a simple trapezoidal scheme: output value at step *i* is the
mean of the raw values at step *i* and the previous retained step.

----

evfiles (library)
-----------------

``evfiles.py`` is a shared helper module imported by the scripts above.  It
provides:

``load_file(filename)``
   Read a single ``.ev`` file into a ``pandas.DataFrame`` with column names
   derived from the ``# [N name]`` header.

``load_files(filenames)``
   Load and concatenate multiple ``.ev`` files, removing overlapping rows.

``get_column_names(filename)``
   Return a list of column names extracted from the file header via regex.

``printev(data, labels)``
   Write a data array to stdout in ``.ev`` format with a conformant header.

----

readPhantomDump
---------------

``readPhantomDump.py`` provides a low-level binary dump reader and a
``Simulation`` class that wraps Phantom's Fortran library via ``ctypes``.

.. code-block:: python

   from readPhantomDump import Simulation
   sim = Simulation('myrun.in', tmax=10.0, dtmax=0.1)

The ``Simulation`` class calls ``libphantom.so`` (which must be built
separately with ``make libphantom``) to advance the simulation and expose
particle data.  Exceptions raised for common problems:

- ``UnableToReadDumpFile``
- ``IncorrectNumberOfParticles``
- ``SpecificEnergyNotStored``
- ``MagneticFieldNotStored``

.. seealso::

   :doc:`pyphantom` — pure-Python alternative for reading dump files without
   requiring a compiled Fortran library.

   :doc:`../api/main/readwrite_dumps` — Fortran module that writes the binary
   dump format consumed by these scripts.
