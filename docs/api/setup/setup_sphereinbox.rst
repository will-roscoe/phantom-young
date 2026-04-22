.. phantom-doc: hand-written

setup_sphereinbox
=================

Overview
--------

``setup_sphereinbox`` places a cold, dense gas sphere inside a warm, low-density ambient medium that fills the rest of a periodic box. The two regions are initialised in pressure equilibrium with a specified density contrast (``density_contrast``). This configuration is used for star formation collapse calculations, isolated cloud evolution, and tests of cloud-medium interaction — setting ``density_contrast = 1`` reduces it to decaying turbulence in a uniform box.

The sphere geometry is highly configurable: it can be a uniform sphere, a Bonnor-Ebert sphere (configured via ``iBE_options``), or a sphere with an imposed density perturbation amplitude ``rho_pert_amp``. Magnetic fields with a specified mass-to-flux ratio ``masstoflux`` and orientation relative to the rotation axis ``ang_Bomega`` can be included. Rotation is set by either an angular velocity ``angvel`` or a rotational-to-gravitational energy ratio ``beta_r``.

This is the most feature-rich of the spherical collapse setups, providing access to a broad parameter space for studying the role of turbulence, magnetic fields, rotation, and the surrounding medium in determining the fragmentation outcome and stellar mass function.

Physical & Mathematical Description
------------------------------------

The Bonnor-Ebert sphere is a pressure-confined isothermal equilibrium sphere with a non-dimensional radius :math:`\xi_\mathrm{max}` satisfying the Lane-Emden equation :math:`d^2\theta/d\xi^2 + (2/\xi) d\theta/d\xi + e^\theta = 0`. The critical Bonnor-Ebert mass is :math:`M_\mathrm{BE} = 1.18 c_s^4 / (G^{3/2} P_\mathrm{ext}^{1/2})`. The mass-to-flux ratio in units of the critical value is :math:`\mu_\Phi = M / (\Phi / 2\pi\sqrt{G})` where :math:`\Phi = \pi R^2 B_z` is the magnetic flux threading the sphere.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_sphereinbox.f90`` for the complete source.
