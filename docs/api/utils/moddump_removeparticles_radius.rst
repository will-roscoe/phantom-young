.. phantom-doc: hand-written

moddump_removeparticles_radius
==============================

Overview
--------

``moddump_removeparticles_radius`` removes all SPH particles that lie outside a specified spherical radius from the origin, using ``delete_particles_outside_sphere`` from the ``part`` module. The user is prompted for the maximum radius in code units.

Particles at :math:`r = |\mathbf{r}| > r_\mathrm{max}` are removed by setting their smoothing length negative (the Phantom convention for dead particles). This moddump is useful for creating compact initial conditions from a larger particle distribution, or for removing distant halo particles that are not needed for the simulation of interest.

This is a simple but frequently needed utility, complementing ``moddump_removeparticles_cylinder`` for spherical rather than cylindrical geometry.

Physical & Mathematical Description
------------------------------------

A particle at radius :math:`r_i = |\mathbf{r}_i|` is removed if :math:`r_i > r_\mathrm{max}`. The number of retained particles is :math:`N_\mathrm{retain} = \sum_i \mathbf{1}[r_i \leq r_\mathrm{max}]`. After removal, ``npart`` is updated to count only retained particles, and the particle arrays are compacted.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_removeparticles_radius.f90`` for the complete source.
