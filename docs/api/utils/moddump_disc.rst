.. phantom-doc: hand-written

moddump_disc
============

Overview
--------

``moddump_disc`` applies an inclination or warp to an existing disc dump by rotating the particle distribution around a specified axis. It uses ``set_incline_or_warp`` from the ``setdisc`` module to apply the desired transformation, and optionally adds a magnetic field to the warped disc.

The user is prompted for the warp/inclination parameters (tilt angle, warp radius, warp width). The routine then computes the rotation for each particle and applies it to both the position and velocity vectors. If the MHD flag is active, a magnetic field aligned with the disc angular momentum can also be added.

This moddump is useful for creating initially misaligned or warped disc configurations without re-running the full disc setup, enabling studies of disc precession, Bardeen-Petterson alignment, and Kozai-Lidov oscillations to start from a pre-relaxed disc structure.

Physical & Mathematical Description
------------------------------------

The inclination of the disc is applied by rotating the particle positions and velocities by a matrix :math:`\mathbf{R}(\theta, \hat{\mathbf{n}})`, where :math:`\theta` is the tilt angle and :math:`\hat{\mathbf{n}}` is the rotation axis (typically :math:`\hat{x}`). For a warped disc the rotation angle varies with cylindrical radius: :math:`\theta(R) = \theta_0 \tanh[(R - R_\mathrm{warp}) / \Delta R]`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_disc.f90`` for the complete source.
