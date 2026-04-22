.. phantom-doc: hand-written

setup_wind
==========

Overview
--------

``setup_wind`` is a comprehensive AGB star / binary stellar wind injection setup following Siess et al. (2022). It configures binary or triple star systems in which the primary (AGB) star ejects a slow, radiation-driven wind, and a companion star (or tight inner binary) modifies the wind through its gravitational influence. The primary, secondary, and optional tight inner binary are all placed as sink particles with masses, effective radii, temperatures, luminosities, and accretion radii specified at runtime.

Runtime parameters include the eccentricity and inclination of the inner and outer orbits, the wind temperature ``T_wind``, the wind mass-loss rate, and the particle mass ``mass_of_particles``. The wind is injected at run time through the wind injection module. Physical units are set in solar masses and astronomical units.

This setup underpins studies of wind-Roche-lobe overflow (WRLOF), spiral wind morphology in symbiotic binaries, and the formation of planetary nebulae from binary AGB systems, as in the simulations of Siess et al. (2022).

Physical & Mathematical Description
------------------------------------

The radiation-driven wind terminal velocity for an AGB star is approximately :math:`v_\infty \approx 2 v_\mathrm{esc} \sqrt{\Gamma - 1}` where :math:`\Gamma = L/(4\pi G M c / \kappa)` is the Eddington ratio and :math:`v_\mathrm{esc} = \sqrt{2GM/R}` is the escape velocity. The gravitational focusing parameter :math:`\zeta = G M_\mathrm{comp} / (v_\mathrm{rel}^2 a)` determines the degree of wind capture by the companion, where :math:`v_\mathrm{rel}` is the relative wind-companion velocity at the companion's location.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_wind.f90`` for the complete source.
