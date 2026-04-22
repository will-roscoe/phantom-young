Runtime parameters (``.in`` file)
===================================

Phantom reads runtime parameters from a plain-text ``.in`` file.  The file is
generated automatically on the first run and updated after each full dump.
Parameters not present in the file take their compiled-in default values.

Format::

   key = value   ! description

Section comments start with ``#``.  The file is self-documenting: the
description field shows the allowed values or units.

.. contents:: Sections
   :local:
   :depth: 1

----

Job name
--------

.. list-table::
   :header-rows: 1
   :widths: 18 8 20 54

   * - Parameter
     - Type
     - Default
     - Description
   * - ``logfile``
     - string
     - ``<run>.log``
     - File to which log output is directed.
   * - ``dumpfile``
     - string
     - ``<run>_00000.tmp``
     - Starting dump file.  Phantom resumes from this file if it exists.

----

Run control and I/O
--------------------

.. list-table::
   :header-rows: 1
   :widths: 18 8 12 62

   * - Parameter
     - Type
     - Default
     - Description
   * - ``tmax``
     - real
     - —
     - End time (code units).
   * - ``dtmax``
     - real
     - —
     - Time between dump outputs (code units).
   * - ``nmax``
     - int
     - -1
     - Maximum number of timesteps.  ``0`` = evaluate derivatives once and
       stop; ``-1`` = unlimited.
   * - ``nout``
     - int
     - -1
     - Write a dump every *n* ``dtmax`` intervals.  ``-1`` = ignore (use
       ``dtmax`` directly).
   * - ``nmaxdumps``
     - int
     - -1
     - Stop after *n* full dumps.  ``-1`` = ignore.
   * - ``twallmax``
     - string
     - ``000:00``
     - Maximum wall-clock time (``hhh:mm``).  ``000:00`` = no limit.
   * - ``dtwallmax``
     - string
     - ``024:00``
     - Maximum wall time between dumps (``hhh:mm``).
   * - ``nfulldump``
     - int
     - 10
     - Write a full dump every *n* outputs; intervening outputs are small
       (positions and velocities only).
   * - ``iverbose``
     - int
     - 0
     - Log verbosity: ``-1`` quiet, ``0`` default, ``1`` all steps,
       ``2`` debug, ``5`` maximum.

Supplementary I/O options
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 18 8 12 62

   * - Parameter
     - Type
     - Default
     - Description
   * - ``rhofinal_cgs``
     - real
     - 0.0
     - Stop the run when any particle exceeds this density (g cm\ :sup:`-3`).
       ``≤ 0`` = disabled.
   * - ``dtmax_dratio``
     - real
     - 1.258
     - Dynamic ``dtmax``: reduce ``dtmax`` if the maximum density increases by
       more than this ratio in one dump interval.  ``≤ 0`` = disabled.
   * - ``dtmax_max``
     - real
     - -1.0
     - Dynamic ``dtmax``: upper bound on ``dtmax``.  ``≤ 0`` = use initial
       ``dtmax``.
   * - ``dtmax_min``
     - real
     - 0.0
     - Dynamic ``dtmax``: lower bound on ``dtmax``.
   * - ``calc_erot``
     - logical
     - F
     - Include rotational energy :math:`E_\mathrm{rot}` in the ``.ev`` file.

----

Accuracy
--------

.. list-table::
   :header-rows: 1
   :widths: 18 8 12 62

   * - Parameter
     - Type
     - Default
     - Description
   * - ``C_cour``
     - real
     - 0.3
     - Courant number: controls the CFL timestep constraint.
   * - ``C_force``
     - real
     - 0.25
     - Force timestep multiplier: controls the acceleration timestep
       constraint.
   * - ``tolv``
     - real
     - 1e-2
     - Tolerance on the velocity iteration in the leapfrog predictor–corrector.
   * - ``hfact``
     - real
     - 1.2
     - Smoothing-length prefactor: :math:`h = h_\mathrm{fact}(m/\rho)^{1/3}`.
       Typical values 1.0–1.5.
   * - ``tolh``
     - real
     - 1e-4
     - Tolerance on the iterative :math:`h`–:math:`\rho` solve.
   * - ``tree_accuracy``
     - real
     - 0.5
     - Tree opening criterion (Barnes–Hut multipole accuracy).  Range 0.0–1.0;
       smaller is more accurate.

----

Hydrodynamics and shock capturing
----------------------------------

.. list-table::
   :header-rows: 1
   :widths: 18 8 12 62

   * - Parameter
     - Type
     - Default
     - Description
   * - ``alpha``
     - real
     - 1.0
     - Artificial viscosity switch amplitude (Cullen & Dehnen 2010 limiter).
   * - ``alphamax``
     - real
     - 1.0
     - Maximum value of the time-varying artificial viscosity switch.
   * - ``alphau``
     - real
     - 1.0
     - Artificial thermal conductivity coefficient.
   * - ``beta``
     - real
     - 2.0
     - Von Neumann–Richtmyer viscosity coefficient.
   * - ``alphaB``
     - real
     - 1.0
     - Artificial resistivity coefficient (MHD only).
   * - ``psidecayfac``
     - real
     - 1.0
     - Divergence-cleaning decay factor for :math:`\psi` (MHD only).
   * - ``avdecayconst``
     - real
     - 0.1
     - Decay constant for the artificial viscosity switch.

----

Equation of state
-----------------

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``ieos``
     - int
     - 1
     - EOS selector (see table below).
   * - ``mu``
     - real
     - 2.46
     - Mean molecular weight (used when ``ieos`` requires it).
   * - ``gamma``
     - real
     - 5/3
     - Adiabatic index (required when ``ieos = 2``).
   * - ``ipdv_heating``
     - int
     - 1
     - Include PdV compressional heating: ``0`` off, ``1`` on.
   * - ``ishock_heating``
     - int
     - 1
     - Include artificial viscosity shock heating: ``0`` off, ``1`` on.

**Conditional on** ``ieos``

.. list-table:: EOS selector values and conditionally required parameters
   :header-rows: 1
   :widths: 10 45 45

   * - ``ieos``
     - Description
     - Additional parameters
   * - 1
     - Isothermal (:math:`P = c_s^2 \rho`)
     - ``cs0`` (sound speed)
   * - 2
     - Adiabatic (:math:`P = (\gamma-1)\rho u`)
     - ``gamma``
   * - 3
     - Locally isothermal (disc; :math:`c_s \propto r^{-q}`)
     - ``qfacdisc``, ``cs0``
   * - 6
     - Piecewise polytrope (stellar interiors)
     - ``gamma``, density/pressure breakpoints
   * - 8
     - Barotropic (star formation)
     - ``rhocore``, ``gamma``
   * - 9
     - Piecewise adiabatic + isothermal
     - ``gamma``, ``rhocrit``
   * - 10
     - MESA EOS table
     - ``EOS_file``
   * - 12
     - Ideal gas + radiation
     - ``mu``, ``gamma``
   * - 15
     - Helmholtz free-energy EOS
     - ``EOS_file``
   * - 20
     - Ideal gas
     - ``mu``, ``gamma``
   * - 24
     - Radiative cooling approximation (Lombardi)
     - ``EOS_file``, ``icooling`` options

----

Cooling
-------

The cooling section is only written when the code is compiled with thermal
energy (``maxvxyzu ≥ 4``).

.. list-table::
   :header-rows: 1
   :widths: 18 8 12 62

   * - Parameter
     - Type
     - Default
     - Description
   * - ``icooling``
     - int
     - 0
     - Cooling function selector (see table below).
   * - ``C_cool``
     - real
     - 0.05
     - Timestep factor controlling the cooling sub-step.

**Conditional on** ``icooling``

.. list-table::
   :header-rows: 1
   :widths: 10 35 55

   * - ``icooling``
     - Description
     - Additional parameters
   * - 0
     - No cooling
     - —
   * - 1
     - Library cooling (step function)
     - ``ufloor``
   * - 2
     - Library cooling (force evaluation)
     - ``ufloor``
   * - 3
     - Gammie (1996) irradiated disc cooling
     - ``beta_cool``
   * - 4
     - ISM cooling (Koyama & Inutsuka 2002)
     - ``ufloor``
   * - 5, 6
     - Koyama & Inutsuka (2002) exact
     - ``ufloor``
   * - 7
     - Power-law cooling
     - ``beta_cool``, ``T0``
   * - 9
     - Radiative approximation (Lombardi et al.)
     - ``EOS_file``, ``OD method``, ``Lstar``, ``do FLD``, ``Tfloor``
   * - 10
     - Full molecular/atomic network
     - ``ufloor``, network files
   * - 11
     - Cooling lookup table
     - ``EOS_file``

Parameters active when ``icooling = 9``:

.. list-table::
   :header-rows: 1
   :widths: 18 8 12 62

   * - Parameter
     - Type
     - Default
     - Description
   * - ``EOS_file``
     - string
     - ``eos_lom.dat``
     - Tabulated EOS/opacity file for the radiative approximation.
   * - ``OD method``
     - int
     - 4
     - Optical depth estimator: 1 = Stamatellos, 2 = Lombardi, 3 = combined,
       4 = modified Lombardi.
   * - ``Lstar``
     - real
     - 0.0
     - Host star luminosity (:math:`L_\odot`) used to set :math:`T_\mathrm{min}`.
       0 = no irradiation.
   * - ``do FLD``
     - int
     - 1
     - Enable flux-limited diffusion: ``1`` yes, ``0`` no.
   * - ``Tfloor``
     - real
     - 5.0
     - Temperature floor (K).  Active when ``> 0``.

.. seealso:: :doc:`../api/main/cooling`

----

Sink particles
--------------

The sink-particle section is written only when ``nptmass > 0`` or when
self-gravity is compiled in.

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``isink_potential``
     - int
     - 0
     - Sink gravitational softening: ``0`` = 1/r, ``1`` = surface smoothing.
   * - ``icreate_sinks``
     - int
     - 0
     - Allow automatic sink creation from dense clumps.
   * - ``h_soft_sinksink``
     - real
     - 0.0
     - Softening length for sink–sink gravitational interactions.
   * - ``f_acc``
     - real
     - 0.8
     - Particles within ``f_acc × h_acc`` of a sink are accreted without
       further checks.

**Conditional on** ``icreate_sinks = 1``:

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``h_acc``
     - real
     - —
     - Accretion radius for sink creation.
   * - ``r_crit``
     - real
     - —
     - Critical radius for bound-particle check during sink creation.
   * - ``rho_crit_cgs``
     - real
     - —
     - Density threshold for sink creation (g cm\ :sup:`-3`).

.. seealso:: :doc:`../api/main/ptmass`

----

External forces
---------------

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``iexternalforce``
     - int
     - 0
     - External potential selector (see below).

.. list-table:: External force options
   :header-rows: 1
   :widths: 5 20 75

   * - Value
     - Name
     - Description
   * - 0
     - none
     - No external force.
   * - 1
     - star
     - Central stellar point mass.
   * - 2
     - corotating
     - Co-rotating reference frame (binary potential).
   * - 3
     - binary
     - External binary potential (fixed orbit).
   * - 4
     - Poynting–Robertson
     - Radiation pressure and PR drag.
   * - 5
     - torus
     - Torus potential.
   * - 6
     - toy stars
     - Toy-star potential.
   * - 7
     - external file
     - Potential read from file.
   * - 8
     - spiral
     - Spiral arm perturbation.
   * - 9
     - Lense–Thirring
     - Frame-dragging precession potential.
   * - 10
     - density
     - Density-dependent potential.
   * - 11
     - Einstein
     - Post-Newtonian correction.

.. seealso:: :doc:`../api/main/externalforces`

----

Physical viscosity
------------------

Written only when ``DISC_VISCOSITY=no`` at compile time.

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``irealvisc``
     - int
     - 0
     - Physical viscosity type: ``0`` none, ``1`` constant shear, ``2``
       Shakura–Sunyaev :math:`\alpha`-disc.
   * - ``shearparam``
     - real
     - 0.1
     - Shear viscosity coefficient (``irealvisc=1``) or
       :math:`\alpha_\mathrm{SS}` (``irealvisc=2``).
   * - ``bulkvisc``
     - real
     - 0.0
     - Bulk viscosity coefficient.

----

Particle injection and removal
-------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``rkill``
     - real
     - -1.0
     - Deactivate (kill) particles beyond this radius.  ``< 0`` = disabled.

----

Gravitational waves
-------------------

Written only when compiled with GR support.

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``gw``
     - logical
     - F
     - Calculate and output gravitational wave strain tensor.

----

Output flags
------------

.. list-table::
   :header-rows: 1
   :widths: 20 8 12 60

   * - Parameter
     - Type
     - Default
     - Description
   * - ``curlv``
     - logical
     - F
     - Write :math:`\nabla \times \mathbf{v}` to dump files.
   * - ``track_lum``
     - logical
     - F
     - Write :math:`du/dt` to dump files (approximate lightcurve proxy).
