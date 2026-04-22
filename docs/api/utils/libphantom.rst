.. phantom-doc: hand-written

libphantom
==========

Overview
--------

``libphantom`` exposes a set of C-callable Fortran routines that allow Phantom to be linked as a library by external C or Python applications. The interface provides subroutines for adding or updating individual particles (``inject_or_update_particle``), setting particle masses, querying particle counts, advancing the simulation by one step, and reading dump files.

The library interface is used by the Einstein Toolkit coupling (via the ``einsteintk_wrapper`` module) and can be used by any external code that needs to drive Phantom from C or Python. All physical quantities are passed in code units, with the caller responsible for unit conversion.

The interface was developed by Daniel Price and Steven Toupin and is subject to specific written permission for use. It provides a stable ABI for external code to interact with Phantom without needing to use Fortran directly.

Physical & Mathematical Description
------------------------------------

Particles are added via ``inject_or_update_particle(particle_number, mass, position, velocity, h, u, boundary)``, where ``position`` and ``velocity`` are 3-element double-precision arrays in code units. The particle mass is set in code units of :math:`M_\odot` (for typical Phantom simulations) and the smoothing length ``h`` in code length units. The ``boundary`` flag selects between gas (type ``igas``) and boundary (type ``iboundary``) particle types.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/libphantom.f90
