.. phantom-doc: hand-written

moddump_CoM
===========

Overview
--------

``moddump_CoM`` resets all particle positions to be relative to the centre of mass of the system, ensuring that the total linear momentum is zero in the new frame. It calls ``reset_centreofmass`` from the ``centreofmass`` module, which computes the mass-weighted position and velocity of all gas and sink particles and subtracts them from every particle.

This modification is required for some plotting tools and analysis routines that assume the centre of mass is at the origin. It is also useful as a pre-processing step before computing angular momenta or orbital elements, which should be defined relative to the system centre of mass.

The routine handles periodic boundary conditions by also shifting the boundary origin if the ``periodic`` flag is set.

Physical & Mathematical Description
------------------------------------

The centre of mass position is :math:`\mathbf{R}_\mathrm{CoM} = \sum_i m_i \mathbf{r}_i / M_\mathrm{tot}` and velocity :math:`\mathbf{V}_\mathrm{CoM} = \sum_i m_i \mathbf{v}_i / M_\mathrm{tot}`. After the reset, every particle position is updated to :math:`\mathbf{r}_i \leftarrow \mathbf{r}_i - \mathbf{R}_\mathrm{CoM}` and every velocity to :math:`\mathbf{v}_i \leftarrow \mathbf{v}_i - \mathbf{V}_\mathrm{CoM}`, ensuring that :math:`\sum_i m_i \mathbf{r}_i = \mathbf{0}` and :math:`\sum_i m_i \mathbf{v}_i = \mathbf{0}` in the new frame.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_CoM.f90`` for the complete source.
