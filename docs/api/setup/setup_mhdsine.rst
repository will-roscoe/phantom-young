.. phantom-doc: hand-written

setup_mhdsine
=============

Overview
--------

``setup_mhdsine`` sets up a sinusoidal magnetic field decay test in a 1D slab geometry. A sinusoidal perturbation :math:`B_x = B_0 \sin(2\pi x)` is imposed on an otherwise uniform background with zero velocity. In the presence of resistivity (Ohmic or ambipolar diffusion), the amplitude of the sine wave decays exponentially at a rate set by the diffusivity and the wavenumber, providing an analytic test for the numerical implementation of non-ideal MHD terms.

The slab geometry is achieved using the ``set_slab`` module with periodic boundary conditions. No velocity perturbation is applied, isolating the diffusion of the magnetic field from any fluid motion. The test verifies that the decay rate agrees with the analytic prediction :math:`\exp(-\eta k^2 t)` where :math:`\eta` is the magnetic diffusivity and :math:`k = 2\pi/\lambda` is the wavenumber.

This test is particularly important for verifying the Ohmic resistivity and ambipolar diffusion implementations in Phantom's non-ideal MHD module.

Physical & Mathematical Description
------------------------------------

The sinusoidal field :math:`B_x(x, 0) = B_0 \sin(2\pi x / L)` decays under Ohmic resistivity as :math:`B_x(x, t) = B_0 \sin(2\pi x / L) \exp(-\eta_\mathrm{OR} (2\pi/L)^2 t)`, where :math:`\eta_\mathrm{OR}` is the Ohmic resistivity coefficient. For ambipolar diffusion the effective diffusivity is :math:`\eta_\mathrm{AD} = B^2 / (\gamma_\mathrm{AD} \rho_i \rho_n)`. The analytic amplitude at time :math:`t` provides the reference against which numerical results are compared.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_mhdsine.f90`` for the complete source.
