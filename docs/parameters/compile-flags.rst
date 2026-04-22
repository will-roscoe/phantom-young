Compile-time flags
==================

Phantom's physics modules are selected at compile time via Makefile flags.
The ``SETUP=`` variable selects a preset configuration; individual flags can
also be overridden on the ``make`` command line.

.. code-block:: bash

   make SETUP=disc
   make SETUP=disc MHD=yes        # override a flag

.. contents:: Sections
   :local:
   :depth: 1

----

Physics flags
-------------

These flags enable or disable physics modules.  Each is set to ``yes`` or
``no`` (default ``no`` unless noted).

.. list-table::
   :header-rows: 1
   :widths: 22 10 68

   * - Flag
     - Default
     - Effect
   * - ``MHD``
     - no
     - Compile magnetohydrodynamics.  Adds :math:`\mathbf{B}` and :math:`\psi`
       arrays, divergence cleaning, and artificial resistivity.
   * - ``GRAVITY``
     - no
     - Enable self-gravity via a Barnes–Hut tree.  Required for sink particle
       creation and stellar collapse setups.
   * - ``ISOTHERMAL``
     - no
     - Use isothermal EOS (``ieos=1``).  Disables internal energy array
       (``maxvxyzu=3``), saving significant memory.
   * - ``RADIATION``
     - no
     - Enable flux-limited diffusion radiation transport.  Adds radiation
       energy and flux arrays.
   * - ``DUST``
     - no
     - Include one-fluid or two-fluid dust. Adds dust fraction / dust velocity
       arrays depending on the dust method.
   * - ``DUST_GROWTH``
     - no
     - Enable dust grain growth (Smoluchowski coagulation).  Requires
       ``DUST=yes``.
   * - ``GR``
     - no
     - Compile general-relativistic SPH (GRMHD).  Selects a spacetime metric
       and replaces Newtonian equations of motion.
   * - ``H2CHEM``
     - no
     - Include simplified H₂/HI/H⁺ chemistry network for galactic disc
       simulations.
   * - ``DRIVING``
     - no
     - Enable stochastic turbulent driving (Ornstein–Uhlenbeck forcing).
       Used with ``SETUP=turb``, ``turbdrive``.
   * - ``PERIODIC``
     - no
     - Use periodic boundary conditions.  Activates the Ewald correction for
       self-gravity and periodic ghost-particle treatment.

----

Numerical flags
---------------

.. list-table::
   :header-rows: 1
   :widths: 22 10 68

   * - Flag
     - Default
     - Effect
   * - ``IND_TIMESTEPS``
     - no
     - Enable individual particle timesteps (block timestep hierarchy).
       Strongly recommended for problems with large dynamic range.
   * - ``DISC_VISCOSITY``
     - no
     - Replace the standard SPH artificial viscosity with the disc
       :math:`\alpha`-viscosity formulation of Lodato & Price (2010).  When
       ``yes``, the ``irealvisc`` block is omitted from the ``.in`` file.
   * - ``KERNEL``
     - cubic
     - SPH smoothing kernel: ``cubic`` (M₄), ``quartic`` (M₅), ``quintic``
       (M₆), ``WendlandC2``, ``WendlandC4``, ``WendlandC6``.

----

SETUP presets
-------------

The ``SETUP`` variable selects a physics preset and setup file in one step.
The table below lists the most commonly used targets; the full list is in
``build/Makefile_setups``.

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - ``SETUP=``
     - Description and flags enabled
   * - ``disc``
     - Locally isothermal gas disc. ``ISOTHERMAL=yes``, ``IND_TIMESTEPS=yes``
   * - ``dustydisc``
     - Dusty gas disc. ``ISOTHERMAL=yes``, ``IND_TIMESTEPS=yes``, ``DUST=yes``
   * - ``adiabaticdisc``
     - Adiabatic disc (full energy equation).
   * - ``raddisc``
     - Adiabatic disc with FLD radiation. ``RADIATION=yes``
   * - ``binarydisc``
     - Disc around a binary star. ``ISOTHERMAL=yes``, ``IND_TIMESTEPS=yes``
   * - ``turb``
     - Periodic driven turbulence. ``ISOTHERMAL=yes``, ``PERIODIC=yes``,
       ``DRIVING=yes``, ``IND_TIMESTEPS=yes``
   * - ``turbdrive``
     - Driven turbulence (uniform-density IC). ``ISOTHERMAL=yes``,
       ``PERIODIC=yes``, ``DRIVING=yes``
   * - ``dustyturb``
     - Dusty periodic turbulence. Adds ``DUST=yes`` to ``turb`` flags.
   * - ``galdisc``
     - Galactic disc with H₂ chemistry. ``IND_TIMESTEPS=yes``, ``H2CHEM=yes``
   * - ``galdiscmhd``
     - Magnetised galactic disc. Adds ``MHD=yes``, ``ISOTHERMAL=yes``
   * - ``galcen``
     - Galactic centre wind injection.
   * - ``polytrope``
     - Polytropic star. ``GRAVITY=yes``
   * - ``wd``
     - White dwarf from stellar model. ``GRAVITY=yes``
   * - ``neutronstar``
     - Neutron star with nuclear EOS. ``GRAVITY=yes``
   * - ``tde``
     - Tidal disruption event. ``GRAVITY=yes``
   * - ``grtde``
     - GR tidal disruption event. ``GR=yes``, ``GRAVITY=yes``,
       ``IND_TIMESTEPS=yes``
   * - ``collgr``
     - Colliding binary stars (GR). ``GR=yes``, ``GRAVITY=yes``,
       ``IND_TIMESTEPS=yes``
   * - ``grdisc``
     - Disc around a black hole (GR). ``IND_TIMESTEPS=yes``
   * - ``shock``
     - Hydrodynamic shock tube.
   * - ``mhdshock``
     - MHD shock tube. ``MHD=yes``
   * - ``dustyshock``
     - Dusty shock tube. ``DUST=yes``
   * - ``solarsystem``
     - Planets/minor bodies (N-body + dust). ``GRAVITY=yes``, ``DUST=yes``
   * - ``starcluster``
     - Stellar cluster (N-body + gas).
   * - ``empty``
     - Empty setup for externally driven simulations. ``IND_TIMESTEPS=yes``
   * - ``taylorgreen``
     - Taylor–Green vortex. ``ISOTHERMAL=yes``, ``PERIODIC=yes``,
       ``KERNEL=quintic``

----

SYSTEM presets
--------------

The ``SYSTEM`` variable selects the Fortran compiler and its flags.  Phantom
auto-detects it by probing ``$PATH`` if not set.

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - ``SYSTEM=``
     - Compiler / platform
   * - ``gfortran``
     - GNU Fortran (default on most Linux systems)
   * - ``ifort``
     - Intel Fortran Classic
   * - ``ifx``
     - Intel Fortran LLVM (oneAPI)
   * - ``aocc``
     - AMD Optimizing C/C++ Compiler (Flang-based)
   * - ``pgf90``
     - PGI/NVHPC Fortran
   * - ``g95``
     - G95 Fortran
   * - ``cray``
     - Cray Fortran (``ftn`` wrapper)

.. code-block:: bash

   # Auto-detect (recommended):
   make SETUP=disc

   # Force a specific compiler:
   make SETUP=disc SYSTEM=ifort

   # Debug build:
   make SETUP=disc DEBUG=yes
