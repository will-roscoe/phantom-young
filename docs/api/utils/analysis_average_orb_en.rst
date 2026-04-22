.. phantom-doc: hand-written

analysis_average_orb_en
=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_average_orb_en`` computes the average orbital energy of all non-accreted particles in a Phantom simulation at each post-processing dump. It separately evaluates the mean kinetic energy, mean potential energy, and total mean orbital energy, writing a time series to ``orbitalenergy.ev``.

This routine is particularly useful for tidal disruption event (TDE) simulations, where the spread in orbital energy of the disrupted stellar debris determines the mass fallback rate. Tracking the mean energy as a function of time monitors how efficiently angular momentum and energy are redistributed among particles.

Output columns are time, mean kinetic energy :math:`\langle E_k \rangle`, mean potential energy :math:`\langle E_p \rangle`, and mean total orbital energy :math:`\langle E \rangle`.

Physical & Mathematical Description
------------------------------------

For each live particle the specific kinetic energy is :math:`e_k = \frac{1}{2}|\mathbf{v}|^2` and the specific gravitational potential energy is :math:`e_p = -GM/r`. The average orbital energy is :math:`\langle E \rangle = \langle e_k \rangle + \langle e_p \rangle`, averaged over all non-accreted particles.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_average_orb_en.f90`` for the complete source.
