.. phantom-doc: hand-written

inject_sim
==========

Overview
--------

The ``inject_sim`` module (module name ``inject``, ``inject_type = 'sim'``)
injects particles by reading them from the output files of a previous or
concurrently running Phantom simulation. Its primary use case is tidal
disruption event (TDE) simulations, where a pre-computed outflow dump file
provides the initial conditions for a stream of debris particles injected
at a sphere of radius ``r_inject``. The module reads successive dump files
using ``getnextfilename`` and extracts particle positions, velocities, and
thermodynamic state to inject at the specified radius.

The runtime parameter ``r_inject`` (in cm) sets the injection sphere radius.
The module uses ``readwrite_dumps_common`` to extract particle data from
the source dump files and ``partinject`` to add the resulting particles to
the live simulation. This mechanism is restricted to Category B (parser
excluded) because the module name ``inject`` conflicts with other injection
implementations.

Physical & Mathematical Description
------------------------------------

Particles are injected on a sphere of radius :math:`r_\text{inject}` with
positions, velocities, and internal energies taken directly from the source
simulation dump. No additional kinematic or thermodynamic transformation is
applied. The injected particle spacing and mass are inherited from the source
simulation, so the numerical resolution of the injected stream matches that
of the source run.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
