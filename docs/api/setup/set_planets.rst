.. phantom-doc: hand-written

set_planets
===========

Overview
--------

The ``set_planets`` module adds planet particles — implemented as Phantom
sink particles — to an existing disc or stellar setup.  Each planet is
characterised by its mass, semi-major axis, eccentricity, inclination,
and accretion radius.  The routine places the planet sink at the correct
position and velocity on its Keplerian orbit around the central star (or
barycentre) and appends it to the sink-particle arrays.

The module is typically called after the gas disc has been populated by
``set_disc``, so that the planet orbital parameters can be defined relative
to the disc plane.  Multiple planets can be added in sequence; each call
increments the sink-particle counter ``nptmass`` and initialises the new
sink's mass, position, and velocity from the specified orbital elements.

Physical & Mathematical Description
------------------------------------

A planet of mass :math:`m_p` on a circular orbit of radius :math:`a`
around a star of mass :math:`M_\star` has orbital velocity

.. math::

   v_\mathrm{orb} = \sqrt{\frac{G M_\star}{a}}.

For an eccentric orbit with eccentricity :math:`e` the planet is placed
at the specified true anomaly :math:`f` using the conic-section formula
for the radial distance,

.. math::

   r = \frac{a(1 - e^2)}{1 + e\cos f},

and the velocity components follow from the vis-viva equation.  The
orbital plane can be inclined by an angle :math:`i` relative to the disc
mid-plane.  The planet's Hill radius,

.. math::

   r_H = a\left(\frac{m_p}{3 M_\star}\right)^{1/3},

is a natural scale for the accretion radius and for measuring gap-opening
in the disc.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_planets.f90
