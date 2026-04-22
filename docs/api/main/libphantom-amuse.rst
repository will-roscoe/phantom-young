.. phantom-doc: hand-written

libphantom-amuse
================

Overview
--------

The ``AmusePhantom`` module implements the interface between Phantom and the
AMUSE (Astrophysical Multipurpose Software Environment) framework. AMUSE is a
Python-based platform that allows coupling of different astrophysical codes
(N-body, SPH, stellar evolution, etc.) into multi-physics simulations. This
module exposes Phantom as a shared library with an API matching the AMUSE
hydrodynamics interface, allowing AMUSE scripts to control Phantom simulations
directly.

The module maintains a lookup table ``amuse_id_lookup`` that maps AMUSE
32-bit particle indices to Phantom's internal particle indices, which may
change during a run due to particle sorting, injection, and accretion. Public
functions follow the AMUSE convention and include routines to get and set
particle positions, velocities, densities, smoothing lengths, and internal
energies, as well as functions to commit particle changes and advance the
simulation by a specified timestep.

Physical & Mathematical Description
------------------------------------

The module itself contains no new physics; it is purely an interface layer
that translates between AMUSE's particle-centric data model and Phantom's
internal array-based representation. The AMUSE index mapping is rebuilt
whenever particles are added, removed, or reshuffled by Phantom, using
Phantom's ``iorig`` original particle index array to maintain consistent
identification across sort and injection operations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/libphantom-amuse.f90
