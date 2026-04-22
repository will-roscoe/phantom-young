.. phantom-doc: hand-written

mcfost_utils
============

Overview
--------

The ``mcfost_utils`` module contains the runtime options and helper routines
for the live interface between Phantom and the MCFOST Monte Carlo radiative
transfer code. When compiled with ``-DMCFOST``, Phantom can call MCFOST at
each dump to compute dust temperatures, synthetic SEDs, and images from the
current SPH particle distribution, allowing self-consistent radiation
hydrodynamics simulations of protoplanetary discs.

The module stores configuration flags such as ``use_mcfost`` (enable/disable
the MCFOST call), ``mcfost_computes_Lacc`` (whether MCFOST computes
accretion luminosity), ``mcfost_uses_PdV`` (whether MCFOST includes PdV
heating), and ``mcfost_dust_subl`` (dust sublimation). The
``set_defaults_mcfost``, ``write_options_mcfost``, and
``read_options_mcfost`` subroutines manage the ``.in`` file integration
for these parameters.

Physical & Mathematical Description
------------------------------------

The MCFOST integration uses a Voronoi tessellation of the SPH particle
positions to construct the density grid passed to the Monte Carlo radiative
transfer solver. The dust temperature is computed by propagating photon
packets through the disc opacity structure and is fed back into Phantom's
equation of state. The coupling is one-way per dump for the standard
Phantom+MCFOST mode, but can be made iterative within a single timestep
using the ``mcfost_uses_PdV`` flag.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mcfost_utils.f90
