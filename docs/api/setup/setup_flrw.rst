.. phantom-doc: hand-written

setup_flrw
==========

Overview
--------

``setup_flrw`` initialises a uniform-density distribution of SPH particles in a Friedmann-Lemaître-Robertson-Walker (FLRW) cosmological spacetime, as described by Magnall et al. (2023). The particles are placed on a cubic or close-packed lattice filling a periodic comoving box, with density ``rhozero`` and sound speed ``cs0`` set in code units. The background metric is implemented through Phantom's general-relativistic framework, allowing tests of cosmological fluid evolution.

The setup supports both matter-dominated and radiation-dominated universes via the ``radiation_dominated`` flag. Optional sinusoidal density or velocity perturbations with prescribed amplitude, wavelength, and phase offset can be added along a selected direction, enabling linear perturbation theory tests. The scale factor :math:`a(t)` evolves according to the Friedmann equation as the simulation progresses.

This is used to validate Phantom's GR cosmological capabilities against analytic FLRW solutions and against independent numerical relativity codes.

Physical & Mathematical Description
------------------------------------

The Friedmann equation governing the scale factor is :math:`H^2 = (\dot{a}/a)^2 = 8\pi G \rho / 3 - k/a^2 + \Lambda/3`, where :math:`H` is the Hubble parameter, :math:`k` is the spatial curvature, and :math:`\Lambda` is the cosmological constant. For linear density perturbations :math:`\delta = \delta\rho/\bar{\rho}` in the matter-dominated era, the growing mode scales as :math:`\delta \propto a(t) \propto t^{2/3}`. The SPH equations are formulated in a comoving frame where peculiar velocities and comoving coordinates are the evolved quantities.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_flrw.f90`` for the complete source.
