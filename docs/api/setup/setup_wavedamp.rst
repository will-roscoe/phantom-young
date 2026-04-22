.. phantom-doc: hand-written

setup_wavedamp
==============

Overview
--------

``setup_wavedamp`` sets up a wave damping test following Wurster, Price & Ayliffe (2014) and Wurster, Price & Bate (2016), originally based on Choi et al. (2009). A sinusoidal wave (either a sound wave selected by ``isowave = .true.`` or an Alfven wave) of amplitude ``amplitude`` and wavenumber ``kwave`` is initialised in a periodic 1D slab. Non-ideal MHD effects — Ohmic resistivity, the Hall effect, and ambipolar diffusion — can be individually enabled to measure their effect on the wave damping rate.

The setup is highly configurable for testing non-ideal MHD implementations: ``use_ohm``, ``use_hall``, and ``use_ambi`` flags activate the respective resistive terms; ``realvals`` switches between physical (cgs) and arbitrary code units; and the initial magnetic field ``Bxin`` sets the Alfven speed. The wave can be initialised in x or z (``vx_vz`` flag) and with cubic or rectangular close-packed grids.

Comparison of the numerical damping rate with the analytic prediction :math:`\exp(-\eta k^2 t)` (for Ohmic) or the corresponding ambipolar/Hall expressions provides a systematic test of Phantom's non-ideal MHD module.

Physical & Mathematical Description
------------------------------------

For Ohmic resistivity :math:`\eta_\mathrm{OR}` the Alfven wave amplitude decays as :math:`B \propto \exp(-\eta_\mathrm{OR} k^2 t / 2)`, where :math:`k = 2\pi / \lambda`. For ambipolar diffusion the effective diffusivity is :math:`\eta_\mathrm{AD} = B^2 / (\gamma_\mathrm{AD} \rho_i \rho_n)`, giving a similar exponential decay for the wave amplitude. The Hall effect does not damp the wave but causes circular polarisation and rotation of the wave polarisation plane at a rate :math:`\Omega_H = \eta_H k^2 / 2`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_wavedamp.f90`` for the complete source.
