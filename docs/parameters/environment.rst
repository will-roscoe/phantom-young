Environment variables
=====================

Phantom and its build system read several environment variables.

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Variable
     - Description
   * - ``PHANTOM_DIR``
     - Path to the Phantom source tree.  Some setup tests and scripts use this
       to locate data files (e.g. ``data/cooling/``, ``data/eos/``).  Set
       automatically by the build-bot infrastructure; for manual runs it is
       optional but recommended.

       .. code-block:: bash

          export PHANTOM_DIR=/path/to/phantom
   * - ``SYSTEM``
     - Selects the Fortran compiler preset.  If unset, Phantom probes
       ``$PATH`` for ``gfortran``, ``ifort``, ``ifx``, etc. and picks the
       first found.  Equivalent to ``make SYSTEM=<value>`` on the command
       line.

       .. code-block:: bash

          export SYSTEM=gfortran
          make SETUP=disc
   * - ``OMP_NUM_THREADS``
     - Number of OpenMP threads.  Phantom is parallelised with OpenMP; set
       this to the number of physical cores on the compute node.

       .. code-block:: bash

          export OMP_NUM_THREADS=16
   * - ``SPLASH_DIR``
     - Path to the SPLASH visualisation library source.  Required only when
       building analysis utilities that link against SPLASH (e.g.
       ``make analysis``).  Defaults to ``$HOME/splash`` if that directory
       exists.

       .. code-block:: bash

          export SPLASH_DIR=$HOME/splash
   * - ``MCFOST_DIR``
     - Path to the MCFOST radiative transfer code source.  Required only when
       compiling with MCFOST coupling (``SETUP=mcfost``).
   * - ``HDF5_DIR``
     - Path to an HDF5 installation.  Required only when building the
       ``phantom2hdf5`` utility.
