.. phantom-doc: hand-written

dustywaves
==========

Overview
--------

``dustywaves`` provides the analytic exact solution for linear dusty waves in a gas-dust mixture, using the dispersion relation from Price & Laibe (2015). The module ``dustywaves`` implements the routine ``exact_dustywave``, which computes the time-dependent velocity and density profiles of both the gas and dust components for given wave parameters.

The routine takes the wave amplitude, sound speed, drag coefficient, wavelength, and initial mean densities, then solves the cubic dispersion relation (via ``cubicsolve_complex``) to obtain the three complex mode frequencies. The wave solution is a superposition of these three modes (two of which are usually complex conjugate pairs), yielding damped oscillations with a characteristic timescale set by the drag coefficient.

This analytic solution is used by ``evol_dustywaves`` and the Phantom test suite to validate the SPH dust-gas drag implementation against the exact linear theory.

Physical & Mathematical Description
------------------------------------

For a dusty gas with dust-to-gas ratio :math:`\epsilon = \rho_d / \rho_g` and drag coefficient :math:`K` (stopping rate), the dispersion relation for the wave frequency :math:`\omega` at wavenumber :math:`k` is the cubic :math:`\omega^3 + i K (1 + \epsilon) \omega^2 - k^2 c_s^2 \omega - i K k^2 c_s^2 = 0` (Price & Laibe 2015). The three roots give one pure damping mode and two propagating-but-damped sound wave modes.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/dustywaves.f90
