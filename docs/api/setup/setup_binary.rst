.. phantom-doc: hand-written

setup_binary
============

Overview
--------

``setup_binary`` builds one or more stars in a binary or hierarchical stellar system. Each stellar component is constructed using the ``setstar`` module, which supports polytropic models as well as tabulated profiles from stellar evolution codes such as MESA and KEPLER. Orbital parameters — semi-major axis, eccentricity, inclination, and argument of periapsis — are configured through the ``setorbit`` module, and the system can optionally be placed in a co-rotating frame to study tidal interactions and mass transfer.

The setup supports both Newtonian and general-relativistic configurations (controlled by the ``gr`` compile-time flag), enabling its use for neutron-star or compact-object binary simulations as well as standard stellar pairs. A relaxation step can be applied to each star prior to the dynamical run to remove initial transients arising from the mapping from a 1D profile to 3D SPH particles.

The Roche lobe geometry determines whether the system is detached, semi-detached, or in contact. The volumetric Roche lobe radius is estimated using the formula of :cite:`eggleton83`, which provides a compact and accurate approximation over the full range of mass ratios.

Physical & Mathematical Description
------------------------------------

The binary orbital period follows Kepler's third law, :math:`T_\mathrm{orb} = 2\pi \sqrt{a^3 / G(M_1 + M_2)}`, where :math:`a` is the semi-major axis and :math:`M_1, M_2` are the stellar masses. The volumetric Roche lobe radius of the primary is approximated by :math:`R_{L,1}/a \approx 0.49 q^{2/3} / [0.6 q^{2/3} + \ln(1 + q^{1/3})]` where :math:`q = M_1/M_2` (:cite:`eggleton83`). After independent construction, each star's particles are shifted and velocity-boosted into the co-orbital frame.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_binary.f90`` for the complete source.
