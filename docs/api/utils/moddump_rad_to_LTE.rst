.. phantom-doc: hand-written

moddump_rad_to_LTE
==================

Overview
--------

``moddump_rad_to_LTE`` converts a Phantom radiation-hydrodynamics dump back to an LTE (local thermodynamic equilibrium) dump using the ``ieos = 12`` ideal-gas-plus-radiation equation of state. Written by Mike Lau, it is the inverse of ``moddump_LTE_to_rad``.

The conversion removes the explicit radiation energy variable from the ``rad`` array and redistributes the total (gas + radiation) energy as an LTE thermal energy consistent with the gas temperature. This is useful for restarting a radiation-hydrodynamics simulation as an LTE simulation after the radiation field has equilibrated.

The routine requires that the ``do_radiation`` compile flag was set when the dump was written, and checks for this condition before proceeding.

Physical & Mathematical Description
------------------------------------

The LTE conversion sets the specific internal energy :math:`u_\mathrm{gas}` from the total energy :math:`u_\mathrm{tot} = u_\mathrm{gas} + e_\mathrm{rad}/\rho` via the LTE condition :math:`e_\mathrm{rad} = a T^4 / \rho`, where the temperature :math:`T` satisfies the ideal-gas-plus-radiation EOS. The radiation field index ``iradxi`` in the ``rad`` array is set to zero after the conversion.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_rad_to_LTE.f90`` for the complete source.
