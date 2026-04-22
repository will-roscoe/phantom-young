.. phantom-doc: hand-written

moddump\_sink
=============

Overview
--------

``moddump_sink`` provides an interactive interface for modifying the properties of sink particles already present in a Phantom dump. It was written by Mike Lau. The user selects a sink by index and is prompted for new values of accretion radius, softening radius, mass, position, and luminosity.

The routine also supports deletion of a sink particle and optional reset of the centre of mass to the origin. Changes to luminosity are stored in the ``ilum`` array and can activate the ``ptmass_heating`` module for feedback from a nuclear-burning or accreting source.

This utility is useful when continuing a simulation with updated stellar or compact-object parameters, for example after a mass-transfer episode or when inserting a new mass-loss prescription.

Physical & Mathematical Description
------------------------------------

Sink particle masses are updated in place in ``xyzmh_ptmass``. The luminosity is set in physical units (solar luminosities), converted via :math:`L = L_\odot \, (\mathrm{unit\_energ} / \mathrm{utime})^{-1}`. The accretion radius :math:`r_\mathrm{acc}` determines the volume within which SPH gas particles are accreted, with the criterion :math:`r < r_\mathrm{acc}` applied at each time-step.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_sink.f90`` for the complete source.
