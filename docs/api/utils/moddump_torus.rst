.. phantom-doc: hand-written

moddump\_torus
==============

Overview
--------

``moddump_torus`` adds velocity and density perturbations to a relaxed torus dump, providing initial conditions for studying non-axisymmetric instabilities in accretion tori. It was written by Daniel Price. The perturbation follows the :math:`m = 3` azimuthal mode pattern described in Price & Bate (2007), with a fixed amplitude :math:`A = 0.05`.

The routine iterates over all particles, computes the cylindrical radius, and adds a sinusoidal velocity kick proportional to the local Keplerian speed. An accompanying density perturbation of the same azimuthal wavenumber seeds the Papaloizou-Pringle instability or other non-linear mode coupling mechanisms in the torus.

This moddump is designed to be applied to a torus that has already been relaxed to a steady configuration (e.g., using the Phantom torus setup), so that the perturbation evolves on top of a well-resolved background state.

Physical & Mathematical Description
------------------------------------

The azimuthal velocity perturbation is :math:`\delta v_\phi = A \, v_K(r) \cos(m \phi)`, where :math:`v_K(r) = \sqrt{G M / r}` is the Keplerian speed at cylindrical radius :math:`r`, :math:`\phi` is the azimuthal angle, and :math:`m = 3` is the azimuthal mode number. The torus major radius is :math:`R_\mathrm{tor} = 1` in code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_torus.f90`` for the complete source.
