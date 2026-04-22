.. phantom-doc: hand-written

krome
=====

Overview
--------

The ``krome_interface`` module provides the coupling layer between Phantom
and the KROME astrochemistry library (Grassi et al. 2014). KROME is an
external library that solves a network of chemical rate equations coupled to
a gas temperature equation for a user-defined set of atomic and molecular
species. This module handles initialisation of KROME, passing Phantom's
particle data (density, temperature, abundances) to KROME's integration
routines, and retrieving the updated abundances and temperatures after each
chemical timestep.

The public subroutine ``initialise_krome`` sets up the KROME chemical network
and initial elemental abundances for H, He, C, N, O, S, Fe, Si, Mg, Na, P,
and F. The ``update_krome`` subroutine is called each SPH timestep to advance
the chemistry for each particle, and ``write_KromeSetupFile`` outputs a
KROME network summary for diagnostic purposes.

Physical & Mathematical Description
------------------------------------

KROME integrates the chemical rate equations

.. math::

   \frac{dn_i}{dt} = \sum_j k_j(T) n_{j_1} n_{j_2} - \sum_k k_k(T) n_i n_{k_2}

for species number densities :math:`n_i`, where the rate coefficients
:math:`k_j(T)` are functions of gas temperature :math:`T`. The coupled
temperature equation includes contributions from line cooling, chemical
heating, cosmic-ray ionisation, and photoheating. Phantom passes the local
density and temperature to KROME, which advances the chemistry over the SPH
particle timestep and returns updated abundances and temperature.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/krome.f90
