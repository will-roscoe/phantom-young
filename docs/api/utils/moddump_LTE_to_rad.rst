.. phantom-doc: hand-written

moddump_LTE_to_rad
==================

Overview
--------

``moddump_LTE_to_rad`` converts a Phantom dump computed with the LTE (local thermodynamic equilibrium) equation of state (``ieos = 12``, ideal gas plus radiation) to a radiation-hydrodynamics dump that includes the explicit radiation energy density field. Written by Mike Lau, it is used to initialise Phantom-MCFOST coupled radiation transport simulations from a pre-relaxed LTE snapshot.

The conversion computes the radiation energy density :math:`e_\mathrm{rad}` for each particle from its temperature, using the Stefan-Boltzmann radiation pressure formula, and sets the radiation energy field ``rad`` accordingly. The internal energy in the non-radiation dump is partitioned between gas and radiation contributions assuming LTE.

After conversion, the dump can be evolved using Phantom's radiation-hydrodynamics solver with the full radiation transport equation active.

Physical & Mathematical Description
------------------------------------

In LTE the radiation energy density is :math:`e_\mathrm{rad} = a T^4`, where :math:`a = 4\sigma/c` is the radiation density constant, :math:`\sigma` is the Stefan-Boltzmann constant, and :math:`T` is the gas temperature determined from the LTE EOS. The radiation field index in the ``rad`` array is ``iradxi``. The total internal energy density is partitioned as :math:`e_\mathrm{tot} = e_\mathrm{gas} + e_\mathrm{rad}`, with :math:`e_\mathrm{gas} = c_V T \rho`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_LTE_to_rad.f90`` for the complete source.
