.. phantom-doc: hand-written

moddump_recalcuT
================

Overview
--------

``moddump_recalcuT`` recalculates the internal energy and temperature of all gas particles using a specified equation of state, updating the ``vxyzu`` array to be self-consistent with the new EOS choice. Written by Mike Lau, it is useful for converting between EOS models or for applying a new temperature profile to an existing particle distribution.

The user selects the EOS index and associated parameters (``gmw``, ``X_in``, ``Z_in``, ``gamma``, ``irecomb``) interactively. The routine then calls ``calc_temp_and_ene`` for each particle to compute the temperature from the density and internal energy, and vice versa, depending on which is held fixed.

This moddump is typically used to reinitialise the thermodynamics of a simulation after changing the EOS (e.g. from a simple polytrope to the MESA EOS for stellar structure studies).

Physical & Mathematical Description
------------------------------------

For the ideal-gas EOS, the temperature and specific internal energy are related by :math:`u = c_V T = k_B T / (\mu m_H (\gamma - 1))`, where :math:`\mu` is the mean molecular weight ``gmw``. For the gas-plus-radiation EOS, the conversion is implicit and requires solving :math:`u_\mathrm{tot} = u_\mathrm{gas} + a T^4 / \rho` for :math:`T` given :math:`u_\mathrm{tot}` and :math:`\rho`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_recalcuT.f90`` for the complete source.
