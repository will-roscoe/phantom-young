.. phantom-doc: hand-written

moddump_changemass
==================

Overview
--------

``moddump_changemass`` modifies the particle mass in an existing Phantom dump, rescaling all particles to a new total mass. The user is prompted to enter the desired new mass, and the routine divides the new mass equally among all live gas particles, updating the ``massoftype`` array.

This utility is useful for studies of how disc or cloud structure changes with total mass, enabling a single well-relaxed particle distribution to be rescaled without repeating the relaxation process. Since Phantom uses equal-mass particles within each particle type, changing the mass also changes the gravitational force and pressure, so the user should be aware of the physical implications.

The rescaling preserves particle positions and velocities while updating the mass per particle, which changes the surface density, density, and hence the sound speed and pressure for barotropic equations of state.

Physical & Mathematical Description
------------------------------------

The new mass per particle is :math:`m_\mathrm{new} = M_\mathrm{new} / N_\mathrm{gas}`, where :math:`M_\mathrm{new}` is the target total mass and :math:`N_\mathrm{gas}` is the number of live gas particles. The density at each particle is :math:`\rho_i = m_\mathrm{new} \sum_j W(|\mathbf{r}_i - \mathbf{r}_j|, h_i)`, so densities scale linearly with :math:`M_\mathrm{new}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_changemass.f90`` for the complete source.
