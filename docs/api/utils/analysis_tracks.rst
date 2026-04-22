.. phantom-doc: hand-written

analysis_tracks
===============

Overview
--------

``analysis_tracks`` is a post-processing routine that tracks the orbital trajectories of selected SPH particles as a function of time, monitoring their passage through specified radial shells and height-to-radius ratio bins in a disc simulation. Up to ``maxtrack = 200`` particles can be tracked simultaneously, with their identifiers and initial positions stored in a persistent array across dumps.

On the first call, the user is prompted to select the radial bins ``radtrack`` and the height-to-radius ratio bins ``zoverrtrack`` at which particles are to be tracked. Particles passing through the specified shell are flagged and their subsequent trajectories are written to individual output files named ``particle_NNNNN.ev``.

This routine is particularly useful for studying accretion pathways in protoplanetary discs, radial mixing in disc simulations, and the dynamics of test particles in binary systems.

Physical & Mathematical Description
------------------------------------

A particle is assigned to a radial shell if its cylindrical radius satisfies :math:`|R_i - R_\mathrm{track}| < R_\mathrm{track} \cdot \delta_R` where :math:`\delta_R` is the relative tolerance ``rtol = 0.1``. Similarly, height-to-radius constraints require :math:`|z_i / R_i - (z/R)_\mathrm{track}| < \delta_{z/R}`. Once selected, a particle's six-dimensional phase-space coordinates are written at each subsequent dump.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_tracks.f90`` for the complete source.
