.. phantom-doc: hand-written

analysis_CoM
============

Overview
--------

``analysis_CoM`` is a simple post-processing routine that computes the centre of mass position and velocity of the entire SPH system (gas plus sink particles) and writes the result to a file at each dump. It is used for monitoring the global momentum conservation of a simulation and for recentring analysis.

The routine calls ``get_centreofmass`` from the ``centreofmass`` module, which performs a mass-weighted average over all particle types including sink particles from the ``xyzmh_ptmass`` array. The output file is named ``<prefix>_com.dat`` where the prefix is extracted from the dump filename.

This routine is straightforwardly applicable to any Phantom simulation and requires no configuration parameters. It is useful for diagnosing momentum drift in long simulations, or for checking that the initial conditions correctly place the centre of mass at the origin.

Physical & Mathematical Description
------------------------------------

The centre of mass position is :math:`\mathbf{R}_\mathrm{CoM} = \sum_i m_i \mathbf{r}_i / \sum_i m_i`, summing over all live SPH particles and all sink particles. The centre of mass velocity is :math:`\mathbf{V}_\mathrm{CoM} = \sum_i m_i \mathbf{v}_i / \sum_i m_i`. Both are written in code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_CoM.f90`` for the complete source.
