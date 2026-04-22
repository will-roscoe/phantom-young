.. phantom-doc: hand-written

analysis_clumpfind
====================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_clumpfind`` implements the CLUMPFIND algorithm for identifying self-gravitating objects (clumps) in an SPH simulation. It locates local potential minima and uses particle neighbour lists to assign particles to clumps, tracking clump membership across timesteps using standard merger tree algorithms.

The algorithm begins by identifying potential minima among all particles, then grows each clump outward through the neighbour network. Clumps are matched across successive dumps so that mass accretion histories and merger events can be traced. Up to ``nclumpmax = 1000`` clumps can be tracked simultaneously.

Optional bound-checking and sink-particle association are supported. Particles within ``sinkclumprad`` times the accretion radius of a sink are automatically assigned to that sink's clump. The routine writes per-clump data files and a global summary for each dump.

Physical & Mathematical Description
------------------------------------

A clump is gravitationally bound if its total mechanical energy :math:`E = E_k + E_p < 0`, where :math:`E_k = \frac{1}{2} \sum_i m_i v_i^2` and :math:`E_p = \sum_{i<j} -G m_i m_j / r_{ij}`. The centre of a clump is the local minimum of the gravitational potential :math:`\phi_i = -\sum_j G m_j / |\mathbf{r}_i - \mathbf{r}_j|`, estimated via the SPH particle neighbour list.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_clumpfind.F90`` for the complete source.
