.. phantom-doc: hand-written

moddump\_tdesink
================

Overview
--------

``moddump_tdesink`` adds a sink particle representing a black hole or compact object to an existing Phantom dump for use in tidal disruption event (TDE) simulations. It was written by Megha Sharma. The user specifies the sink mass and accretion radius interactively, and the routine positions the sink at the centre of mass of the particle distribution.

Particles found within the specified accretion radius are immediately removed via ``delete_particles_inside_radius``, creating a clean central cavity. The centre of mass is then reset to the origin. The routine uses ``sortutils`` to identify the innermost particles and ``physcon`` for unit conversion (solar masses and solar radii).

This moddump allows an existing stellar SPH dump to be quickly modified for TDE setup: the star is placed on an incoming orbit and the central black hole sink is inserted without running a new setup from scratch.

Physical & Mathematical Description
------------------------------------

The tidal disruption radius is :math:`r_t = r_\star (M_\bullet / m_\star)^{1/3}`, where :math:`M_\bullet` is the black hole mass and :math:`r_\star`, :math:`m_\star` are the stellar radius and mass. The penetration factor :math:`\beta = r_t / r_\mathrm{peri}` controls how deeply the star penetrates; disruption requires :math:`\beta \gtrsim 1`. The sink accretion radius ``rcore`` should be set to a fraction of :math:`r_t` to allow the debris stream to form.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_tdesink.f90`` for the complete source.
