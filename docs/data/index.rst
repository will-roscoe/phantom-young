Data files
==========

The ``data/`` directory contains supporting data files used by Phantom during
setup, at runtime, or in post-processing.  The subdirectories are described
below.

.. contents:: Subdirectories
   :local:
   :depth: 1

----

cooling/
--------

Cooling function lookup tables and example input files for setups that use
radiative cooling.  Contains ``.dat`` tables read by the cooling modules (e.g.
``eos_lom.dat`` for the Lombardi radiative approximation) as well as reference
``.in`` and ``.setup`` files for a pressure-confined isothermal sphere
simulation used in testing.

.. seealso:: :doc:`../api/main/cooling`

eos/
----

Equation of state tables used when ``ieos`` selects a tabulated EOS option
(e.g. the MESA or Helmholtz EOS).  Files are read by the EOS module at
initialisation.

.. seealso:: :doc:`../api/main/eos`

forcing/
--------

Stochastic turbulent forcing data for driven-turbulence setups
(``SETUP=turbdrive``).  Contains pre-generated random forcing fields that are
applied to the velocity field via the ``forcing`` module to maintain a target
turbulent Mach number.

galaxy_merger/
--------------

Initial condition files for galaxy merger simulations.  Contains particle
position/velocity tables for two interacting galactic discs used with the
``galaxy_merger`` setup.

galcen/
-------

Setup and potential data files for galactic centre simulations (``SETUP=galcen``).
Contains stellar wind injection parameters and potential model tables for the
central few parsecs of the Milky Way.

gal_radii_cdfs/
---------------

Cumulative distribution function tables of galactic disc surface density
profiles.  Used by the galactic disc setup (``SETUP=galdisc``) to distribute
SPH particles according to an observed surface density.

isolatedgalaxy/
---------------

Initial condition files for isolated galaxy disc simulations (``SETUP=galdisc``).
Contains stellar and dark matter halo model parameters.

Krome/
------

Interface data for the KROME chemistry network library.  KROME provides
a full gas-phase chemical network; this directory contains the rate tables
and network configuration files.

neutronstar/
------------

Neutron star equation of state and stellar model files used by the
``SETUP=neutronstar`` setup.

orbits/
-------

Orbital parameter files for binary and hierarchical multiple systems.
Used by the ``set_hierarchical`` and related setup modules to initialise
particle positions from Keplerian orbital elements.

starcluster/
------------

Initial condition tables for stellar cluster setups (``SETUP=starcluster``).
Contains mass functions and position distributions for N-body plus SPH
cluster simulations.

star_data_files/
----------------

Stellar structure profiles for initialising realistic stellar interiors.
Includes pre-computed profiles from MESA or analytic polytrope models used
by ``SETUP=polytrope``, ``SETUP=wd``, and related star setups.

.. seealso:: :doc:`../api/setup/readwrite_mesa`

velfield/
---------

Pre-generated divergence-free velocity fields for turbulent initial conditions.
Files contain Fourier modes for a Kolmogorov-type power spectrum used by the
turbulence setup (``SETUP=turb``, ``SETUP=turbdrive``) to seed initial velocity
perturbations.
