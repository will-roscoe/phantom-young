.. phantom-doc: hand-written

moddump_addplanets
==================

Overview
--------

``moddump_addplanets`` adds one or more planet sink particles to an existing disc dump. The user is prompted for the number of planets (up to 9), and for each planet specifies the mass, orbital radius, and accretion radius. Planets are placed on circular Keplerian orbits in the disc midplane.

For each planet, the routine computes the Keplerian orbital velocity :math:`v_\phi = \sqrt{G M_\mathrm{enc}(r) / r}` where :math:`M_\mathrm{enc}` includes the disc mass interior to the planet's orbit (estimated from the disc surface density profile). The planet is added to the ``xyzmh_ptmass`` and ``vxyz_ptmass`` arrays as a new sink particle.

This moddump enables a pre-relaxed disc simulation to be converted into a planet-disc simulation without re-running the initial conditions setup, which can be computationally expensive for settled disc simulations.

Physical & Mathematical Description
------------------------------------

The planet orbital velocity is :math:`v_\phi = \sqrt{G(M_* + M_\mathrm{disc}(<r)) / r}`, where :math:`M_\mathrm{disc}(<r)` is the disc mass enclosed within radius :math:`r`. The enclosed mass is estimated by summing all gas particles at cylindrical radii :math:`R_i < r` (``disc_m_within_r``). Each planet is positioned at :math:`\mathbf{r}_\mathrm{planet} = r (\cos\phi, \sin\phi, 0)` with :math:`\phi` chosen randomly.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_addplanets.f90`` for the complete source.
