.. phantom-doc: hand-written

combinedustdumps
================

Overview
--------

``combinedustdumps`` is a utility program for combining multiple two-fluid dust+gas Phantom dumps into a single multi-grain dump. The gas particle positions are taken from the first dump file on the command line, and the dust particles from each subsequent dump are appended to the combined output. The program assumes that all input dumps have the same number of gas particles and that the dust particles in each dump correspond to different grain species.

The program takes multiple input filenames as command-line arguments followed by the output filename. It reads each input dump using ``read_dump``, extracts the dust particle data (positions, velocities, grain sizes, and densities), and assembles them into a single multi-grain output dump written by ``write_fulldump``. The output file can be used directly in Phantom simulations with multiple large grain species.

This utility is primarily used when a simulation is run separately for each grain size (to reduce computational cost) and the results need to be combined for post-processing with multi-grain analysis tools.

Physical & Mathematical Description
------------------------------------

The combined dump contains :math:`N_\mathrm{gas}` gas particles from the first input file and :math:`N_\mathrm{dust} \times N_\mathrm{species}` dust particles from the remaining input files. Grain sizes are stored in ``grainsize(k)`` and grain material densities in ``graindens(k)`` for species :math:`k = 1, \ldots, N_\mathrm{species}`. Particle types are set using ``set_particle_type`` with type ``idust``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/combinedustdumps.f90
