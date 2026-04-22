.. phantom-doc: hand-written

setup_gwdisc
============

Overview
--------

``setup_gwdisc`` initialises a circumbinary disc around a compact binary that is inspiralling due to gravitational wave emission. The binary is represented by two sink particles with masses, accretion radii, and an initial separation ``a0`` set at runtime; the disc is built using the ``setdisc`` module around this central binary. The setup tests how the disc responds to the shrinking binary separation and the eventual merger.

Key disc parameters include the inner and outer radii ``R_in`` and ``R_out``, the aspect ratio ``HoverRinput``, the surface density profile index ``p_indexinput``, the sound speed profile index ``q_indexinput``, and the Shakura-Sunyaev viscosity parameter ``alphaSS``. An option to place the disc around the primary only (``disc_around_primary``) is available for circumprimary disc configurations. The disc inclination ``inc`` relative to the binary orbital plane can also be set.

This setup is used to study the interaction between gravitational wave-driven inspiral and the circumbinary disc, including the effect of disc-driven orbital migration and the resonant truncation of the inner disc edge.

Physical & Mathematical Description
------------------------------------

The gravitational wave luminosity of a circular binary is :math:`P_\mathrm{GW} = 32 G^4 m_1^2 m_2^2 (m_1+m_2) / (5 c^5 a^5)`, causing the semi-major axis to shrink as :math:`\dot{a} = -64 G^3 m_1 m_2 (m_1+m_2) / (5 c^5 a^3)`. The disc inner edge is truncated by tidal torques at the 2:1 Lindblad resonance radius :math:`R_\mathrm{in} \approx 2.1 a`. The viscous disc responds to the changing binary potential on the viscous timescale :math:`t_\nu \approx R^2 / \nu` where :math:`\nu = \alpha c_s H` is the kinematic viscosity.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_gwdisc.f90`` for the complete source.
