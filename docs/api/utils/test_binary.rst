.. phantom-doc: hand-written

test_binary
===========

Overview
--------

``test_binary`` (module ``testbinary``) integrates a binary orbit numerically given input orbital elements (masses, semi-major axis, eccentricity, inclination, argument of pericentre, longitude of ascending node, and true anomaly at epoch) and writes the resulting position-velocity track to a file.

The module provides ``test_binary``, which calls ``set_binary`` to place the two bodies and then integrates the orbit using a simple leapfrog or similar symplectic integrator for one or more orbital periods. The output includes the 3D positions and velocities of both bodies at each time step, as well as the orbital separation and projected sky separation.

This module is used by the ``testbinary`` driver program to compare computed binary orbits with observed astrometric data, enabling fitting of orbital elements to observational constraints.

Physical & Mathematical Description
------------------------------------

The binary orbit is defined by the six Keplerian elements :math:`(a, e, i, \Omega, \omega, f_0)`. The initial Cartesian positions and velocities are computed by ``set_binary`` using the vis-viva equation :math:`v^2 = G(m_1+m_2)(2/r - 1/a)` and the orbital angular momentum :math:`\mathbf{L} = \mu \sqrt{G M_\mathrm{tot} a (1-e^2)} \hat{\mathbf{L}}`, where :math:`\mu = m_1 m_2 / (m_1 + m_2)` is the reduced mass.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/test_binary.f90
