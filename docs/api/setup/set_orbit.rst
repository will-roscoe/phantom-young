.. phantom-doc: hand-written

set_orbit
=========

Overview
--------

The ``set_orbit`` module sets the position and velocity of a body on a
Keplerian orbit given the six classical orbital elements: semi-major axis
:math:`a`, eccentricity :math:`e`, inclination :math:`i`, argument of
periapsis :math:`\omega`, longitude of the ascending node :math:`\Omega`,
and true anomaly :math:`f`.  It is the lowest-level orbital mechanics
routine in the Phantom setup library; higher-level modules such as
``set_binary`` and ``set_hierarchical`` call it for each body in the
system.

The routine handles both elliptic (:math:`e < 1`) and parabolic
(:math:`e = 1`) orbits.  Hyperbolic orbits (:math:`e > 1`) are also
supported for fly-by and tidal-disruption setups.  All calculations are
performed in double precision to avoid round-off errors in the orbital
elements.

Physical & Mathematical Description
------------------------------------

The radial distance at true anomaly :math:`f` is given by the conic
section formula

.. math::

   r = \frac{a(1-e^2)}{1 + e\cos f},

and the orbital speed follows from the vis-viva equation,

.. math::

   v^2 = GM\!\left(\frac{2}{r} - \frac{1}{a}\right),

where :math:`M` is the total mass of the system and :math:`G` is the
gravitational constant.  The velocity components in the orbital plane are

.. math::

   v_r = \sqrt{\frac{GM}{p}}\,e\sin f,\qquad
   v_\phi = \sqrt{\frac{GM}{p}}\,(1 + e\cos f),

where :math:`p = a(1-e^2)` is the semi-latus rectum.  The Euler rotation
by :math:`(\omega, i, \Omega)` maps these components into the simulation
frame.  For a parabolic orbit :math:`a \to \infty` and the formulae
reduce to :math:`v^2 = 2GM/r` with :math:`r = q(1 + \cos f)`, where
:math:`q` is the pericentre distance.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc is not available for this file (excluded from Fortran index due to parser incompatibility).
