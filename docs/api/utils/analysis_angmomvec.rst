.. phantom-doc: hand-written

analysis_angmomvec
====================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_angmomvec`` is a lightweight post-processing routine that tracks the direction of the total angular momentum vector of all SPH particles as a function of time. At each dump it computes the unit angular momentum vector :math:`\hat{\mathbf{L}}`, together with the inclination angle and rotation angle relative to the :math:`z`-axis, and appends the result to ``angmomvec.ev``.

The routine is suitable for studying precession of misaligned discs or evolving stellar spin vectors, providing a compact time series of the angular momentum orientation without computing the full energy budget.

Output columns are: time, :math:`L_x`, :math:`L_y`, :math:`L_z` (unit vector components), inclination, and rotation angle.

Physical & Mathematical Description
------------------------------------

The total specific angular momentum direction is :math:`\hat{\mathbf{L}} = \mathbf{L} / |\mathbf{L}|`, with :math:`\mathbf{L} = \sum_i m_i \mathbf{r}_i \times \mathbf{v}_i`. The inclination is :math:`\iota = \arccos(\hat{L}_z)` and the rotation (position angle) is :math:`\phi = \arctan(\hat{L}_y / \hat{L}_x)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_angmomvec.f90`` for the complete source.
