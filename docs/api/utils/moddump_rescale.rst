.. phantom-doc: hand-written

moddump_rescale
===============

Overview
--------

``moddump_rescale`` changes the physical units of a Phantom dump file, rescaling particle positions and velocities to a new choice of code units. Written by Josh Calcino, it prompts the user to select which units to change (time ``utime``, distance ``udist``, mass ``umass``) and by what factor, then rescales the particle data accordingly.

The user can fix any combination of the three fundamental units and the routine computes the implied rescaling factors for positions, velocities, internal energies, and smoothing lengths. This is useful when a simulation was run with suboptimal unit choices and the dump needs to be converted to a more physical unit system.

After rescaling, the dump header is updated with the new unit values, and the rescaled dump can be continued in the new unit system.

Physical & Mathematical Description
------------------------------------

Rescaling from old to new units requires multiplying positions by :math:`f_x = u_\mathrm{dist}^\mathrm{old} / u_\mathrm{dist}^\mathrm{new}`, velocities by :math:`f_v = (u_\mathrm{dist}^\mathrm{old} / u_\mathrm{time}^\mathrm{old}) / (u_\mathrm{dist}^\mathrm{new} / u_\mathrm{time}^\mathrm{new})`, and internal energies by :math:`f_u = f_v^2`. Masses are unchanged if ``umass`` is the same, or rescaled by :math:`f_m = u_\mathrm{mass}^\mathrm{old} / u_\mathrm{mass}^\mathrm{new}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_rescale.f90`` for the complete source.
