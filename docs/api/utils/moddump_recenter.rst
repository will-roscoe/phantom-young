.. phantom-doc: hand-written

moddump_recenter
================

Overview
--------

``moddump_recenter`` resets all particle positions to be relative to the system centre of mass, using ``reset_centreofmass`` from the ``centreofmass`` module. Unlike ``moddump_CoM``, this variant is maintained by Josh Calcino and does not apply periodic boundary corrections.

The routine is functionally equivalent to ``moddump_CoM`` for non-periodic simulations and is included as an alternative implementation. Both routines compute the mass-weighted average position and velocity of all particles and sinks, then subtract these from every particle's position and velocity array.

This moddump is a basic housekeeping operation that is often applied before post-processing analysis tools that assume the centre of mass is at the origin.

Physical & Mathematical Description
------------------------------------

The centre of mass is :math:`\mathbf{R}_\mathrm{CoM} = \sum_i m_i \mathbf{r}_i / M_\mathrm{tot}`, where the sum includes all gas particles and all sink particles. The recentering operation :math:`\mathbf{r}_i \leftarrow \mathbf{r}_i - \mathbf{R}_\mathrm{CoM}` is applied to every particle, ensuring :math:`\sum_i m_i \mathbf{r}_i = \mathbf{0}` after the modification.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_recenter.f90`` for the complete source.
