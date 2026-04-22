.. phantom-doc: hand-written

moddump_infall
==============

Overview
--------

``moddump_infall`` adds infalling material (either a sphere or an ellipse) to an existing simulation on a specified orbit (bound, parabolic, or hyperbolic). Written by Josh Calcino, it generates a new particle distribution representing the infalling cloud or clump and places it on the desired orbit with respect to the existing system.

The routine provides extensive parameter control via the ``.params`` file, including the infall mass, shape (sphere or ellipse with semi-axes), the orbit type and eccentricity, the closest approach distance, the initial distance, and the spatial orientation (rotation angles around x, y, z axes). Optional turbulence can be added to the infalling material.

This moddump is useful for modelling external accretion onto an existing disc or star, environmental infall in star-forming regions, and cloud-cloud collision scenarios.

Physical & Mathematical Description
------------------------------------

For a bound orbit (:math:`e < 1`) the infalling material's centre of mass follows a Keplerian ellipse with semi-major axis :math:`a = r_\mathrm{close} / (1 - e)`, where :math:`r_\mathrm{close}` is the pericentre distance. The initial position at distance :math:`r_\mathrm{init}` is found from the orbital equation :math:`r = a(1 - e^2)/(1 + e \cos f)`, solving for the true anomaly :math:`f`. Velocities are computed from :math:`v^2 = G M (2/r - 1/a)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_infall.f90`` for the complete source.
