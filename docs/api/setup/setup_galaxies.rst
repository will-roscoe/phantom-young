.. phantom-doc: hand-written

setup_galaxies
==============

Overview
--------

``setup_galaxies`` initialises a galaxy merger simulation by reading pre-computed initial conditions from Hydra output files (Couchman, Thomas & Pearce 1995; Thacker & Couchman 2006). The data describe two galaxies each composed of a dark matter halo, a stellar disc, and optionally a gaseous component, with unit systems of :math:`10^5 M_\odot`, kpc, and :math:`10^5` yr that are converted to Phantom's internal units.

Two resolution levels are available: a low-resolution run with :math:`N \approx 3.4 \times 10^5` particles and a fiducial-resolution run with :math:`N \approx 2.5 \times 10^6` particles, selected by the ``lowres`` flag. The galaxy models were constructed using the GalactICS code (Kuijken & Dubinski 1995; Widrow & Dubinski 2005) and the simulations were used in Wurster & Thacker (2013) to study the role of magnetic fields in galaxy mergers.

The collision orbit is encoded in the initial condition files; no additional orbital parameters are needed at setup time.

Physical & Mathematical Description
------------------------------------

Each galaxy's dark matter halo follows an NFW density profile :math:`\rho_\mathrm{NFW}(r) = \rho_s / [(r/r_s)(1 + r/r_s)^2]`, and the stellar disc has a Miyamoto-Nagai surface density :math:`\Sigma(R) \propto \exp(-R/R_d)` with scale length :math:`R_d`. The circular velocity curve is :math:`v_c(R) = \sqrt{G M(R)/R}` summed over halo, disc, and bulge components. The initial relative velocity of the two galaxies determines the orbital energy and whether the encounter leads to a merger or a fly-by.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_galaxies.f90`` for the complete source.
