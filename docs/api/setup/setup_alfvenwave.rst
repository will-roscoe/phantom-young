.. phantom-doc: hand-written

setup_alfvenwave
================

Overview
--------

``setup_alfvenwave`` configures Phantom for ideal-MHD wave propagation tests in three dimensions. It supports five wave modes selectable at runtime via the ``iselect`` parameter: a non-linear circularly polarised Alfven wave, linear fast and slow magnetosonic waves, a linear Alfven wave, and a linear entropy wave. This breadth of modes makes it a standard convergence and accuracy benchmark for the MHD solver.

The domain is a uniform periodic box with a background magnetic field **B**\ :sub:`0`. A wave perturbation of specified amplitude and wavelength is superimposed on the uniform state. The optional ``rotated`` flag rotates the wave vector with respect to the grid, testing the code's ability to handle oblique wave propagation and avoid grid-alignment artefacts (following Stone et al. 2008 and Gardiner & Stone 2008).

Particle positions are placed on a uniform Cartesian lattice via ``set_unifdis``, with the perturbation applied analytically at setup time. Because the exact analytic solution is known for each wave type, errors in amplitude and phase after propagation over one wavelength provide a precise measure of numerical dissipation and dispersion.

Physical & Mathematical Description
------------------------------------

For a circularly polarised Alfven wave propagating along **B**\ :sub:`0` the transverse velocity and field perturbations satisfy :math:`\delta B / B_0 = \delta v / v_A`, where :math:`v_A = B_0 / \sqrt{4\pi\rho}` is the Alfven speed. Linear wave modes obey the MHD dispersion relation :math:`\omega^2 = k^2 (v_A^2 + c_s^2) \pm k^2 \sqrt{(v_A^2 + c_s^2)^2 - 4 v_A^2 c_s^2 \cos^2\theta}` for fast/slow modes, where :math:`\theta` is the angle between **k** and **B**\ :sub:`0`. See :cite:`pricemonaghan05` for the SPH MHD formulation used in Phantom.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_alfvenwave.f90`` for the complete source.
