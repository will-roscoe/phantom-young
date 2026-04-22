.. phantom-doc: hand-written

setup_mhdwave
=============

Overview
--------

``setup_mhdwave`` sets up a simple MHD wave propagation test following Section 5.1 of Iwasaki (2015). A uniform background with a magnetic field is perturbed by a small-amplitude transverse velocity perturbation in a 1D periodic slab geometry, exciting a linearly polarised Alfven wave. The wave amplitude, background field strength, and density can be controlled via the source code. The simulation is run until the wave has propagated a fixed number of box-crossing times.

Particles are placed using the ``set_slab`` module and the Alfven wave perturbation is applied analytically as a sinusoidal velocity kick. After the wave has travelled a prescribed distance the numerical amplitude and phase are compared with the analytic solution to measure numerical dissipation and dispersion.

This complements ``setup_alfvenwave`` (which supports multiple wave types and rotation) with a simpler, single-mode Alfven wave test that is closer to the formulation used in some published convergence studies.

Physical & Mathematical Description
------------------------------------

The Alfven wave dispersion relation in ideal MHD is :math:`\omega = k v_A \cos\theta`, where :math:`\theta` is the angle between the wave vector :math:`\mathbf{k}` and the background field :math:`\mathbf{B}_0`, and :math:`v_A = B_0 / \sqrt{4\pi\rho}` is the Alfven speed. For propagation along the field (:math:`\theta = 0`) the wave speed is exactly :math:`v_A`. The fractional numerical damping rate per wavelength is :math:`\Delta A / A = 1 - \exp(-\alpha_\nu k^2 h v_A)` where :math:`\alpha_\nu` is the numerical viscosity coefficient and :math:`h` is the smoothing length. See :cite:`pricemonaghan05` for the MHD SPH formulation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_mhdwave.f90`` for the complete source.
