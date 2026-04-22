.. phantom-doc: hand-written

setup_prtest
============

Overview
--------

``setup_prtest`` configures the Poynting-Robertson drag test, as described in Figure 18 of Price et al. (2018, PASA 35, e031). A spherical distribution of non-interacting (massless in the hydrodynamic sense) particles is placed on circular Keplerian orbits around a central star. The Poynting-Robertson drag force decelerates each particle, causing the orbit to decay inward at a rate determined by the stellar luminosity.

The particles are placed using the ``set_sphere`` module with the Poynting-Robertson external force (``iext_prdrag``) active, and the central star mass is set by ``mass1``. No inter-particle pressure forces act; each particle evolves independently under gravity and the radiation drag. The analytic solution for the spiral inspiral can be compared directly with the numerical trajectory.

This setup isolates the Poynting-Robertson implementation from SPH pressure effects, verifying that the radiation drag term is correctly implemented in the external force module.

Physical & Mathematical Description
------------------------------------

The Poynting-Robertson drag deceleration on a particle of mass :math:`m` at radius :math:`r` moving with velocity :math:`\mathbf{v}` is :math:`\mathbf{a}_\mathrm{PR} = -(L / 4\pi r^2 c^2 m)(2 \dot{r} \hat{r} + v_\phi \hat{\phi})`, where :math:`L` is the stellar luminosity. For a circular orbit the tangential component removes angular momentum, causing the orbit to decay as :math:`\dot{r} = -2 L / (4\pi G M_* c^2 m / r)`. The inspiral timescale is :math:`t_\mathrm{PR} = 4\pi G M_* m c^2 r_0^2 / L`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_prtest.f90`` for the complete source.
