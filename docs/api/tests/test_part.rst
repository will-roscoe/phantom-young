.. phantom-doc: hand-written

test_part
=========

Overview
--------

The ``test_part`` module (Fortran module ``testpart``) tests the core particle-array
management routines in Phantom's ``part`` module. The primary sub-test
``test_accrete_and_kill_routines`` sets up a uniform distribution of gas particles in a
periodic box, then exercises ``kill_particle``, ``count_dead_particles``,
``accrete_particles_outside_sphere``, ``delete_dead_or_accreted_particles``, and
``shuffle_part`` in sequence, checking that ``npart`` and ``npartoftype`` are updated
correctly after each operation.

The accretion test places an accretion sphere at the origin and calls
``accrete_particles_outside_sphere`` with a radius that encloses a known fraction of the
particles, then checks that the number of accreted particles matches the expected count
from the geometric fraction. The kill-and-shuffle test kills a prescribed set of particles
by index, calls ``shuffle_part`` to compact the live list, and verifies that no duplicate
or missing indices appear in the particle arrays after compaction.

Physical & Mathematical Description
------------------------------------

The correctness criteria are purely combinatorial: ``npart`` must decrease by exactly the
number of particles killed or accreted, and ``npartoftype(igas)`` must track ``npart``
consistently. The accreted particle count is checked against the geometric expectation
:math:`N_{\rm acc} = N_{\rm tot} (4\pi/3) r_{\rm acc}^3 \rho_0 / M_{\rm tot}`, which
reduces to the number of particles inside the sphere for a uniform distribution, with an
integer tolerance of zero.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_part.f90
