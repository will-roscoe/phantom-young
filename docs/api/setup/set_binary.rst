.. phantom-doc: hand-written

set_binary
==========

Overview
--------

The ``set_binary`` module places two point masses (or extended stellar
bodies) on a Keplerian orbit specified by the standard set of osculating
orbital elements.  It returns the Cartesian positions and velocities of
both objects in the centre-of-mass frame and optionally computes the
co-rotation angular velocity for frame-rotating simulations.  The
orbital conventions used are compatible with those produced by the
``imorbel`` code (Pearce, Wyatt & Kennedy 2015, MNRAS 448, 3679), which
fits observed binary arcs on the sky.

The module also re-exports the Roche-lobe estimate from the ``orbits``
module and provides the L1 Lagrange point location.  These quantities are
used by accretion-disc and mass-transfer setups to choose sensible sink-
particle accretion radii.  Error flags are returned for unphysical inputs
such as negative masses, super-unity eccentricity, or missing companion
stars in hierarchical configurations.

Physical & Mathematical Description
------------------------------------

The Roche-lobe radius of the secondary is estimated using the fitting
formula of :cite:`eggleton83`,

.. math::

   \frac{R_L}{a} = \frac{0.49\,q^{2/3}}{0.6\,q^{2/3} +
                   \ln\!\left(1 + q^{1/3}\right)},

where :math:`q = m_2/m_1` is the mass ratio and :math:`a` is the
semi-major axis.  This formula is accurate to 1 % for all mass ratios.

The orbital position and velocity are computed from the six classical
orbital elements: semi-major axis :math:`a`, eccentricity :math:`e`,
inclination :math:`i`, argument of periapsis :math:`\omega`, longitude
of the ascending node :math:`\Omega`, and true anomaly :math:`f`.
The separation and speed at true anomaly :math:`f` follow from the
conic-section relations

.. math::

   r = \frac{a(1-e^2)}{1 + e\cos f}, \qquad
   v^2 = GM\!\left(\frac{2}{r} - \frac{1}{a}\right),

where :math:`M = m_1 + m_2` is the total mass and the vis-viva equation
gives the orbital speed.  The result is then rotated by the three Euler
angles :math:`(i, \omega, \Omega)` into the simulation frame.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_binary.f90
