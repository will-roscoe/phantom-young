.. phantom-doc: hand-written

testbinary
==========

Overview
--------

``testbinary`` is the driver program that calls the ``test_binary`` module to compare computed binary orbit trajectories with observed astrometric measurements. It reads orbital element guesses (either from command-line arguments or interactively) and a data file of observed separations and velocities, then integrates the orbit and computes a chi-squared goodness-of-fit.

The program reads the observation file to extract the sky separations :math:`\Delta x`, :math:`\Delta y`, :math:`\Delta z` and velocities :math:`\Delta v_x`, :math:`\Delta v_y`, :math:`\Delta v_z`, together with a chi-squared column if available. It then calls ``test_binary`` with the specified orbital elements and computes the residuals between the computed and observed positions.

This tool is useful for fitting the orbital elements of binary star or exoplanet systems to radial velocity and astrometric data, enabling parameter estimation without a full MCMC framework.

Physical & Mathematical Description
------------------------------------

The chi-squared statistic is :math:`\chi^2 = \sum_k [(\Delta x_k^\mathrm{obs} - \Delta x_k^\mathrm{calc})^2 / \sigma_{x,k}^2 + (\Delta v_{x,k}^\mathrm{obs} - \Delta v_{x,k}^\mathrm{calc})^2 / \sigma_{v_x,k}^2 + \ldots]`, summing over all observations :math:`k`. The orbital period is obtained from ``get_orbital_period`` using Kepler's third law :math:`P = 2\pi \sqrt{a^3 / (G M_\mathrm{tot})}` in AU, solar masses, and years.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/testbinary.f90
