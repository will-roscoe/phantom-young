.. phantom-doc: hand-written

analysis_common_envelope
========================

Overview
--------

``analysis_common_envelope`` is a comprehensive post-processing analysis routine for common envelope (CE) evolution simulations. Maintained by Mike Lau, it provides a wide range of diagnostics including energy accounting, density profiles, Roche lobe overflow, recombination fractions, and the L1 Lagrange point location.

The routine uses the full suite of Phantom EOS modules (gas+radiation, MESA tables, recombination) to evaluate thermodynamic properties at each particle's density and internal energy, enabling physically self-consistent energy budget computations. The analysis can be run interactively with the user selecting which diagnostics to compute, or automatically for all dumps.

Key outputs include the binding energy :math:`E_\mathrm{bind}`, kinetic energy :math:`E_k`, thermal energy :math:`E_\mathrm{therm}`, recombination energy, and the standard common envelope efficiency parameters :math:`\alpha_\mathrm{CE}` and :math:`\lambda`.

Physical & Mathematical Description
------------------------------------

The common envelope energy criterion is :math:`\alpha_\mathrm{CE} (E_{k,\mathrm{final}} - E_{k,\mathrm{initial}}) = E_{\mathrm{bind}}`, where :math:`E_{\mathrm{bind}} = \int_{M_c}^{M_*} (-G M(r) / r + u) \, dm` is the envelope binding energy including internal energy, and the :math:`\alpha` parameter characterises how efficiently orbital energy is deposited into the envelope.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_common_envelope.f90`` for the complete source.
