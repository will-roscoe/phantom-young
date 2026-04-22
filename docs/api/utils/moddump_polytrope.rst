.. phantom-doc: hand-written

moddump_polytrope
=================

Overview
--------

``moddump_polytrope`` applies a radial velocity perturbation to a relaxed polytropic stellar model, exciting the fundamental radial oscillation mode. The perturbation amplitude is set via the ``--amp`` command-line flag (default :math:`10^{-4}`).

Each particle's radial velocity is perturbed as :math:`v_{r,i} \leftarrow v_{r,i} + \mathrm{amp} \cdot r_i / R_*`, where :math:`r_i = |\mathbf{r}_i|` is the particle's distance from the stellar centre and :math:`R_*` is the stellar radius. This linear radial profile corresponds to the fundamental mode displacement pattern, where the surface moves the most and the centre is stationary.

This moddump is used to test the accuracy of Phantom's SPH hydrodynamics for stellar oscillation problems, providing a known perturbation whose frequency can be compared with the analytic fundamental mode frequency from linear stellar oscillation theory.

Physical & Mathematical Description
------------------------------------

The fundamental radial oscillation frequency of a polytrope is approximately :math:`\omega_0^2 \approx (3\gamma - 4) G M_* / R_*^3` for a uniform density star, where :math:`\gamma` is the adiabatic index. The perturbation velocity :math:`\delta v_r = A r / R_*` with amplitude :math:`A = \mathrm{amp} \cdot v_\mathrm{sound,0}` excites the :math:`n = 0` mode while minimising higher mode contamination.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_polytrope.f90`` for the complete source.
