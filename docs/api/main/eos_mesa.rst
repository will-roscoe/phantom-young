.. phantom-doc: hand-written

eos_mesa — MESA Equation of State Wrapper
=========================================

Overview
--------

The ``eos_mesa`` module is a thin wrapper around the ``mesa_microphysics`` module
(see :doc:`eos_mesa_microphysics`) that integrates the MESA (Modules for
Experiments in Stellar Astrophysics) equation of state into Phantom.  MESA
provides a comprehensive thermodynamic description of stellar matter including
ideal-gas, Coulomb-correction, pressure-ionisation, radiation-pressure, and
partially-degenerate electron contributions across the full range of conditions
encountered inside stars.

This EOS is selected by ``ieos = 10`` in the Phantom input file and is the
recommended choice for simulations of stellar interiors, common-envelope evolution,
stellar mergers, and other problems requiring accurate stellar thermodynamics.
The tables are indexed by hydrogen mass fraction :math:`X` and metallicity
:math:`Z`, which are set at initialisation time and passed to the table reader.

Because MESA already accounts for radiation pressure internally, ``ieos = 10``
is incompatible with Phantom's radiation-transport module (``do_radiation =
.true.``): enabling both simultaneously would double-count the radiation-pressure
contribution, and the code raises an error in this case.

The module provides three principal query functions: one returning pressure,
temperature, and :math:`\Gamma_1` from :math:`(\rho, u)` in CGS units
(``get_eos_pressure_temp_gamma1_mesa``), one returning the inverse mean molecular
weight (``get_eos_1overmu_mesa``), and one inverting the relation to obtain
:math:`(u, T)` from :math:`(\rho, P)` (``get_eos_eT_from_rhop_mesa``).

Physical & Mathematical Description
-------------------------------------

The MESA EOS tables are functions of :math:`\log_{10}\rho` and
:math:`\log_{10} u` for fixed :math:`(X, Z)`.  The primary returned quantities are:

* **Pressure** :math:`P(\rho, u)` in dyn cm\ :sup:`-2`,
* **Temperature** :math:`T(\rho, u)` in K,
* **First adiabatic exponent** :math:`\Gamma_1 = (\partial\ln P/\partial\ln\rho)_s`,
* **Inverse mean molecular weight** :math:`1/\mu(\rho, u)`,
* **Specific entropy** :math:`s(\rho, u)` (accessible via ``getvalue_mesa``).

The sound speed returned by Phantom is

.. math::

   c_s = \sqrt{\frac{\Gamma_1\,P}{\rho}}.

The EOS tables cover the composition grid

.. math::

   Z \in \{0.00,\,0.02,\,0.04\}, \quad
   X \in \{0.0,\,0.2,\,0.4,\,0.6,\,0.8\}

with bicubic interpolation in :math:`(\log\rho, \log u)` at fixed :math:`(X, Z)`,
and linear interpolation in :math:`X` and :math:`Z` between table entries.

Derivations
-----------

The table-lookup procedure and interpolation scheme are implemented in
``mesa_microphysics``; see :doc:`eos_mesa_microphysics` for the cubic-spline
details.  The ``eos_mesa`` layer handles only unit conversions (CGS input/output)
and the Phantom-specific interface:

* The CGS density and internal energy are passed to ``getvalue_mesa``, which
  returns log-space thermodynamic quantities.
* :math:`P` is exponentiated and converted to code pressure units in the calling
  routine (:doc:`eos`).
* A warning is issued if the requested :math:`(\rho, u)` point lies outside the
  table range (extrapolation).

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Paxton, B. et al. 2011, ApJS, 192, 3 — MESA I: stellar evolution modules
- Paxton, B. et al. 2013, ApJS, 208, 4 — MESA II
- Paxton, B. et al. 2015, ApJS, 220, 15 — MESA III

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_mesa.f90
