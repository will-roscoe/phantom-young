.. phantom-doc: hand-written

set_solarsystem
===============

Overview
--------

The ``set_solarsystem`` module populates a simulation with solar system
bodies — planets, moons, and optionally minor bodies — as Phantom sink
particles.  It contains a built-in table of planetary masses, orbital
semi-major axes, eccentricities, and inclinations derived from JPL
Horizons ephemerides, so no external data file is required for standard
solar system setups.  Each body is placed on its current or mean Keplerian
orbit around the Sun (or around the appropriate parent body for moons)
using ``set_orbit``.

The module is primarily used for testing and for disc–planet interaction
studies where an accurate initial placement of the solar system planets is
needed.  It can place any subset of the eight planets and optionally add
selected moons or test particles.  The Sun is represented as a sink
particle with the tabulated solar mass, and the whole system is placed in
the centre-of-mass frame.

Physical & Mathematical Description
------------------------------------

Each planet is initialised on a Keplerian orbit using the mean orbital
elements tabulated in the module.  The osculating element set
:math:`(a, e, i, \omega, \Omega, M_0)` is converted to a Cartesian state
vector :math:`(\mathbf{r}, \mathbf{v})` at the reference epoch by first
solving Kepler's equation

.. math::

   M = E - e\sin E

for the eccentric anomaly :math:`E` from the mean anomaly
:math:`M = n(t - t_0)`, where :math:`n = 2\pi/T` is the mean motion.
The true anomaly :math:`f` is then obtained from :math:`E` via

.. math::

   \tan\frac{f}{2} = \sqrt{\frac{1+e}{1-e}}\,\tan\frac{E}{2},

and the result is passed to ``set_orbit`` to generate the Cartesian
position and velocity.  Masses are in solar units; distances default to
astronomical units with the code unit conversion applied by ``set_units``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_solarsystem.f90
