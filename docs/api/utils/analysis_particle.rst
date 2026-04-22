.. phantom-doc: hand-written

analysis_particle
=================

Overview
--------

``analysis_particle`` computes the orbital properties of all SPH particles, treating each particle as a test body in the gravitational field of the central point mass. For each particle it evaluates the orbital energy, angular momentum magnitude, and eccentricity, writing these to output files at each dump.

The routine is designed for studying the orbital distribution of debris in tidal disruption event simulations or particle distributions in disc simulations with a central sink. It computes the Laplace-Runge-Lenz vector to obtain the eccentricity and the argument of pericentre.

Output is written to separate files for the eccentricity distribution and orbital parameters, enabling comparison with analytic TDE debris distributions or Keplerian disc models.

Physical & Mathematical Description
------------------------------------

For each particle the specific orbital energy is :math:`E = v^2/2 - GM/r`, angular momentum is :math:`L = |\mathbf{r} \times \mathbf{v}|`, and eccentricity is obtained from :math:`e = |\mathbf{e}|` where the Laplace-Runge-Lenz vector is :math:`\mathbf{e} = \mathbf{v} \times \mathbf{L}/(GM) - \hat{\mathbf{r}}`. The orbit is bound if :math:`E < 0` and parabolic if :math:`E = 0`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_particle.f90`` for the complete source.
