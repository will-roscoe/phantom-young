.. phantom-doc: hand-written

moddump_addflyby
================

Overview
--------

``moddump_addflyby`` adds a flyby perturber — a sink particle on a parabolic or hyperbolic orbit — to an existing Phantom dump. Written by Cristiano Longarini, it uses the ``orbits`` module to compute the initial position and velocity of the perturber for a given mass, pericentre distance, inclination, and longitude of the ascending node.

The user is prompted for the perturber mass, accretion radius, minimum pericentre distance ``dma``, initial separation parameter ``n0``, orientation angles (``big_omega`` and inclination), and the reduced mass fraction. The routine then computes the initial position of the perturber at a large separation and places it on the specified hyperbolic orbit by calling ``get_T_flyby_par``.

This moddump is used to study tidal truncation of protoplanetary discs by stellar flybys and the dynamical heating of disc material by unbound perturbers.

Physical & Mathematical Description
------------------------------------

The flyby orbit is a parabolic (or hyperbolic) Keplerian trajectory with eccentricity :math:`e \geq 1` and pericentre distance :math:`r_p`. The initial position at time :math:`t_0` (when the perturber is at distance ``n0`` times the pericentre) is computed from the orbital elements using the eccentric anomaly. The orbital plane orientation is set by the inclination :math:`i` and longitude of ascending node :math:`\Omega` via rotation matrices.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_addflyby.f90`` for the complete source.
