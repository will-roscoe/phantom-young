.. phantom-doc: hand-written

analysis_mcfost
===============

Overview
--------

``analysis_mcfost`` is the interface routine that calls the MCFOST Monte Carlo radiative transfer code from within ``phantomanalysis``. It initialises MCFOST on the first call and runs a full radiative transfer calculation on each dump, computing dust temperatures and synthetic observables using the particle positions and densities from the Phantom SPH data.

The routine passes SPH particle data (positions, smoothing lengths, dust fractions, and grain sizes) to MCFOST via the ``mcfost2phantom`` interface, which handles the conversion of SPH densities to the grid structure used by MCFOST. Results are returned as temperature updates that can optionally be fed back into the Phantom internal energy.

This tightly coupled Phantom-MCFOST interface enables self-consistent radiation-hydrodynamics simulations where the dust temperature field is computed by full Monte Carlo radiative transfer rather than a local approximation.

Physical & Mathematical Description
------------------------------------

MCFOST solves the radiative transfer equation :math:`\frac{dI_\nu}{ds} = -\kappa_\nu \rho I_\nu + j_\nu` using Monte Carlo photon packet propagation through the SPH density field, with scattering and absorption cross-sections provided by Mie theory for the specified grain size distribution. The resulting temperature field satisfies radiative equilibrium :math:`\int_0^\infty \kappa_\nu B_\nu(T) d\nu = \int_0^\infty \kappa_\nu J_\nu d\nu`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_mcfost.f90`` for the complete source.
