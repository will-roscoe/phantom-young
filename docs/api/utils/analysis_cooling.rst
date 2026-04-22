.. phantom-doc: hand-written

analysis_cooling
================

Overview
--------

``analysis_cooling`` provides tests of the Phantom cooling solver module, maintained by Lionel Siess. It uses the ``cooling``, ``cooling_functions``, and ``cooling_solver`` modules together with the dust formation module to evaluate the cooling rate as a function of temperature and density, enabling validation of the thermal physics implementation.

The routine can compute and compare cooling functions for different chemical species, test the time integration of the cooling solver against analytic solutions, and validate the Bowen dust opacity :math:`\kappa_\mathrm{dust}` as a function of temperature. It reads physical constants from ``physcon`` and uses dust formation abundances initialised by ``set_abundances``.

The analysis is intended for code verification and calibration of the cooling physics, particularly in AGB stellar wind simulations where radiative cooling and dust formation strongly couple.

Physical & Mathematical Description
------------------------------------

The net cooling rate per unit mass is :math:`\Lambda_\mathrm{net} = \Lambda_\mathrm{cooling}(T, \rho, X_i) - \Gamma_\mathrm{heating}`, where :math:`\Lambda_\mathrm{cooling}` is the sum of contributions from line cooling, bremsstrahlung, and dust-gas coupling. The dust opacity is modelled with the Bowen (1988) formula :math:`\kappa_\mathrm{dust} = \kappa_\max / (1 + \exp[(T - T_\mathrm{cond})/\Delta T])`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_cooling.f90`` for the complete source.
