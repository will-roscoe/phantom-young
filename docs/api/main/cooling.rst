.. phantom-doc: hand-written

cooling
=======

Overview
--------

The ``cooling`` module is the master dispatcher for all gas cooling physics in
Phantom. It presents a single, uniform interface — ``energ_cooling`` — through
which the time-derivative of the specific internal energy, :math:`\dot{u}`, is
returned to the integrator for any of the supported cooling prescriptions.
Initialisation, option input/output, and the temperature-floor enforcement are
likewise centralised here so that the rest of the code is insulated from the
details of whichever cooling model is selected at runtime.

The controlling integer parameter ``icooling`` (owned by the ``eos`` module and
re-exported here) selects the active prescription. The currently supported
options are:

- **0** — cooling disabled.
- **1** — cooling library (implicit/exact integration via ``cooling_solver``).
- **2** — cooling library (explicit integration via ``cooling_solver``).
- **3** — Gammie (2001) beta-cooling (explicit; ``cooling_gammie``).
- **4** — ISM chemistry-coupled multi-phase cooling, applied within the SPH
  step (``cooling_ism``).
- **5** — Koyama & Inutsuka (2002) two-phase ISM cooling (explicit;
  ``cooling_koyamainutsuka``).
- **6** — Koyama & Inutsuka (2002) two-phase ISM cooling (implicit;
  ``cooling_koyamainutsuka``).
- **7** — Gammie beta-cooling with a power-law radial profile (explicit;
  ``cooling_gammie_PL``).
- **8** — ISM chemistry-coupled multi-phase cooling, applied outside the SPH
  step (``cooling_ism``).
- **9** — Radiative-transfer approximation following Young et al. (2024)
  (implicit; ``cooling_radapprox``).

Cooling is applied only when an adiabatic equation of state is active
(``eos_allows_shock_and_work`` must return true), and both shock-heating and
:math:`P\,\mathrm{d}V` work contributions must be enabled. These constraints
are enforced in ``read_options_cooling``.

An optional temperature floor ``Tfloor`` (in Kelvin) may be set for all
cooling options. When active, the corresponding energy floor

.. math::

   u_\mathrm{floor} = \frac{k_\mathrm{B}\,T_\mathrm{floor}}{(\gamma-1)\,\bar{\mu}\,m_\mathrm{p}}

is computed in code units during initialisation and applied by the integrator
to prevent unphysical negative energies. The special case ``icooling = 9``
handles its own minimum energy internally via ``eos_stamatellos`` and therefore
sets ``ufloor = 0``.

Physical & Mathematical Description
------------------------------------

The energy equation solved by Phantom for each SPH particle takes the form

.. math::

   \frac{\mathrm{d}u}{\mathrm{d}t} = \left.\frac{\mathrm{d}u}{\mathrm{d}t}\right|_\mathrm{hydro}
   + \dot{u}_\mathrm{cool},

where :math:`u` is the specific internal energy (energy per unit mass),
:math:`\dot{u}_\mathrm{hydro}` contains the :math:`P\,\mathrm{d}V` and shock
heating contributions, and :math:`\dot{u}_\mathrm{cool}` is the net cooling
rate returned by ``energ_cooling``.

The relationship between internal energy and temperature for an ideal gas with
mean molecular weight :math:`\bar{\mu}` and adiabatic index :math:`\gamma` is

.. math::

   u = \frac{k_\mathrm{B}\,T}{(\gamma - 1)\,\bar{\mu}\,m_\mathrm{p}},

which defines the temperature used when evaluating cooling functions that are
expressed as functions of :math:`T`. When :math:`\gamma \leq 1`, the code uses
:math:`3/2` in place of :math:`1/(\gamma-1)` as a pragmatic fallback for the
floor calculation; this is a code convention, not a physically derived
isothermal limit.

The temperature floor condition is enforced as

.. math::

   u \geq u_\mathrm{floor} = \frac{k_\mathrm{B}\,T_\mathrm{floor}}{(\gamma-1)\,\bar{\mu}\,m_\mathrm{p}},

with ``Tfloor`` supplied in the ``.in`` file. Setting ``Tfloor = 0`` disables
the floor.

References
----------

Gammie, C. F. 2001, ApJ, 553, 174 (not yet in phantom.bib)

Koyama, H. & Inutsuka, S. 2002, ApJ, 564, L97 (not yet in phantom.bib)

Young, M. D. et al. 2024 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`eos` — converts specific energy to temperature for cooling rates.
   :doc:`force` — cooling energy loss accumulated here.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling.f90
