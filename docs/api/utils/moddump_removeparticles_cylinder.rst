.. phantom-doc: hand-written

moddump_removeparticles_cylinder
================================

Overview
--------

``moddump_removeparticles_cylinder`` removes all SPH particles that lie outside a specified cylinder, using the ``delete_particles_outside_cylinder`` routine from the ``part`` module. This is used to trim a 3D particle distribution to a cylindrical geometry, for example to create a thin disc or cylindrical jet from a full 3D setup.

The cylinder is specified by its half-height ``zcyl`` and radius ``rcyl`` in code units. Particles with :math:`R = \sqrt{x^2 + y^2} > r_\mathrm{cyl}` or :math:`|z| > z_\mathrm{cyl}` are removed by setting their smoothing length to a negative value (marking them as dead particles), and the particle count ``npart`` and ``npartoftype`` are updated accordingly.

This moddump is useful for creating cylindrical simulation domains from spherical initial conditions, or for discarding the disc halo when only the thin midplane region is needed for further analysis.

Physical & Mathematical Description
------------------------------------

A particle at position :math:`(x, y, z)` is outside the cylinder if :math:`\sqrt{x^2 + y^2} > r_\mathrm{cyl}` or :math:`|z| > z_\mathrm{cyl}`. The cylinder volume is :math:`V = 2\pi r_\mathrm{cyl}^2 z_\mathrm{cyl}`. After removing exterior particles, the particle count decreases and the simulation domain effectively becomes the cylindrical region of interest.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_removeparticles_cylinder.f90`` for the complete source.
