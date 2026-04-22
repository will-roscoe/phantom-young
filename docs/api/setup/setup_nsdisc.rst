.. phantom-doc: hand-written

setup_nsdisc
============

Overview
--------

``setup_nsdisc`` sets up an accretion disc around a neutron star. The neutron star is represented by an external potential (``iext_prdrag``) combining Newtonian gravity with Poynting-Robertson drag, appropriate for modelling accretion in X-ray binary systems where radiation pressure and radiation drag are significant. The disc is built with the ``setdisc`` module using standard power-law surface density and temperature profiles.

Key parameters include the neutron star mass (in solar masses) and radius (in kilometres), the disc inner and outer radii, and the Shakura-Sunyaev viscosity parameter ``alpha``. The disc equation of state is locally isothermal. Units are set in kilometres and solar masses, appropriate for the neutron star scale.

This setup is intended for studying the inner disc structure near the magnetospheric radius, the propeller effect when the neutron star spin period is short, and the Poynting-Robertson drag on orbiting dust or gas in low-luminosity accreting systems.

Physical & Mathematical Description
------------------------------------

The magnetospheric (Alfven) radius where the magnetic pressure balances the ram pressure of the accreting gas is :math:`r_A = (B^4 R^{12} / (2 G M \dot{M}^2))^{1/7}`, where :math:`B` is the surface field and :math:`R` is the neutron star radius. The Keplerian angular velocity at the inner disc edge is :math:`\Omega_K(r_A) = \sqrt{GM/r_A^3}`. Poynting-Robertson drag decelerates orbiting particles at a rate :math:`\dot{v}_r = -L v_r / (4\pi r^2 c^2 m)` where :math:`L` is the luminosity.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_nsdisc.f90`` for the complete source.
