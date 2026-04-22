.. phantom-doc: hand-written

setup_planetdisc
================

Overview
--------

``setup_planetdisc`` initialises the de Val-Borro et al. (2006) planet-disc comparison problem, a standard benchmark for protoplanetary disc codes. A gas disc is built around a central star using the ``setdisc`` module, and a planet of mass ``m2`` is placed on a fixed circular orbit using a time-dependent external potential rather than a live sink particle. This prescribed-orbit approach is common in comparison studies because it removes the planet-disc feedback and isolates the disc response.

The disc spans from ``R_in`` to ``R_out`` with a power-law surface density :math:`\Sigma \propto R^{-p}` (index ``p_index``) and sound speed :math:`c_s \propto R^{-q}` (index ``q_index``). The planet-to-star mass ratio ``m2`` determines the Hill radius and the strength of the spiral density waves driven in the disc. Accretion onto the star and planet is controlled by ``accradius1`` and ``accradius2``.

Comparison with other disc codes and with analytic predictions for the spiral wave torque makes this setup a key convergence test for Phantom's disc module.

Physical & Mathematical Description
------------------------------------

The planet's Hill radius is :math:`r_H = a (m_p / 3 M_*)^{1/3}`, where :math:`a` is the semi-major axis and :math:`m_p/M_*` is the planet-to-star mass ratio. The Lindblad torque per unit disc mass at a resonance location :math:`R` from the planet is :math:`T_L \propto (m_p/M_*)^2 (a/\Delta)^4 \Sigma a^2 \Omega_p^2`, where :math:`\Delta = |R - a|`. The co-rotation torque from horseshoe orbits has a width :math:`x_s \approx 1.68 a (m_p / 3 M_*)^{1/2}`. The normalised gap depth depends on the ratio of the Hill radius to the disc scale height :math:`H`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_planetdisc.f90`` for the complete source.
