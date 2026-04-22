.. phantom-doc: hand-written

analysis_jet
============

Overview
--------

``analysis_jet`` analyses the properties of jets and outflows in SPH simulations, originally written for sphNG jet calculations. It computes the total accreted mass, outflowing mass, and the mean and maximum radial velocities of particles in the jet, distinguishing infalling from outflowing material using a radial velocity cut.

The routine uses a characteristic radius ``rcut`` and velocity ``vr_cut`` to classify particles, and evaluates the free-fall time ``tff`` to provide a dimensionless measure of the evolutionary stage. Mass flow rates into and out of a sphere of radius ``rcut`` are computed by integrating the radial mass flux over all particle types.

Output statistics are printed to the terminal and can be redirected to a log file. The routine is useful for measuring mass-loading of jets, bipolar outflow efficiencies, and the fraction of infalling mass that is ejected versus accreted.

Physical & Mathematical Description
------------------------------------

The radial velocity of a particle at position :math:`\mathbf{r}` with velocity :math:`\mathbf{v}` is :math:`v_r = \mathbf{v} \cdot \hat{\mathbf{r}}`. The outflowing mass within radius :math:`r_\mathrm{cut}` is :math:`M_\mathrm{out} = \sum_{i: v_{r,i} > v_{r,\mathrm{cut}}, r_i < r_\mathrm{cut}} m_i`. The free-fall time at the mean density is :math:`t_\mathrm{ff} = \sqrt{3\pi / (32 G \bar{\rho})}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_jet.f90`` for the complete source.
