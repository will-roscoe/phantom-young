.. phantom-doc: hand-written

partinject
==========

Overview
--------

The ``partinject`` module provides the utility routines used by all Phantom
injection modules to add new particles to or update existing particles in a
live simulation. It was separated from the ``part`` module to break a
circular dependency with ``timestep_ind``. The module exposes three public
routines: ``add_or_update_particle`` (inject a new SPH particle or refresh
an existing ghost particle at a given index), ``add_or_update_sink``
(equivalent for sink particles), and ``update_injected_particles`` (loop
over all injection modules to refresh boundary/ghost particles).

The ``add_or_update_particle`` routine handles all the bookkeeping required
when a new particle is added: it sets the particle type in ``iphase``,
initialises the smoothing length, thermal energy, magnetic field, and
abundance arrays, increments ``npart`` and the appropriate
``npartoftype`` counter, assigns an original particle index ``iorig``,
and — when individual timesteps are active — places the new particle in
the appropriate timestep bin via ``nbinmax``.

Physical & Mathematical Description
------------------------------------

New particles are given a smoothing length estimated from the local mean
inter-particle spacing, :math:`h \approx h_\text{fact} (m/\rho)^{1/3}`,
where :math:`\rho` is the density at the injection point. For ghost or
boundary particles that already have a slot in the particle array
(``particle_number <= npart``), only the position, velocity, and thermal
state are updated; no array reallocation occurs. The module sets the
``updated_particle`` flag to ``.true.`` when an existing particle has been
updated in place rather than injected fresh.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/partinject.f90
