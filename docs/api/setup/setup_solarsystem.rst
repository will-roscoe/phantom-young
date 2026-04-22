.. phantom-doc: hand-written

setup_solarsystem
=================

Overview
--------

``setup_solarsystem`` sets up solar system N-body simulations using planetary orbital elements from the IAU Minor Planet Center. The eight planets are added as sink particles with masses and Keplerian orbital elements read from the ephemeris; optionally, asteroid populations (including named bodies such as Apophis) can be included as additional particles. The ``epoch`` parameter allows the initial conditions to be set to any calendar date, making it straightforward to set up specific close-approach or impact scenarios.

Near-Earth object Apophis can be represented as a full SPH sphere (``np_apophis`` particles), a single sink particle, or omitted. The asteroid belt and trans-Neptunian objects can be added as km-sized dust particles (``asteroids = .true.``). Time parameters ``tmax_in`` and ``dtmax_in`` accept human-readable strings (e.g., ``"3 days"``, ``"1 hr"``), making it easy to set up short-duration high-precision simulations.

This setup is used for studying planetary close approaches, asteroid deflection scenarios, and the long-term dynamical stability of the solar system within an SPH framework.

Physical & Mathematical Description
------------------------------------

Each planet is placed on its Keplerian orbit with position and velocity computed from the classical orbital elements :math:`(a, e, i, \Omega, \omega, M_0)` via the eccentric anomaly :math:`E` satisfying Kepler's equation :math:`M = E - e\sin E`. The gravitational parameter of the Sun is :math:`\mu_\odot = GM_\odot = 1.327 \times 10^{20}\,\mathrm{m}^3\,\mathrm{s}^{-2}`. The Hill sphere radius of a planet of mass :math:`m_p` at semi-major axis :math:`a_p` is :math:`r_H = a_p (m_p / 3 M_\odot)^{1/3}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_solarsystem.f90`` for the complete source.
