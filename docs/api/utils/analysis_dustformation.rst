.. phantom-doc: hand-written

analysis_dustformation
======================

Overview
--------

``analysis_dustformation`` tracks the formation time of dust grains in each SPH particle during an AGB stellar wind simulation using the nucleation model. Written in connection with Bermudez-Bustamante et al. (submitted to MNRAS, 2023), it records the first dump at which each particle's nucleation rate exceeds a threshold, assigning a formation time :math:`t_\mathrm{form}` to each grain-hosting particle.

On subsequent dumps the routine checks whether newly active particles (those with non-zero nucleation rates ``K0`` and ``K1``) have already been assigned a formation time, using a persistent ``t_formation`` array. The distribution of formation times across all particles provides a record of the spatial and temporal history of dust nucleation.

Output is written to a file per dump listing particle indices and their associated formation times in years, enabling post-processing maps of the dust nucleation front in the wind.

Physical & Mathematical Description
------------------------------------

Dust nucleation is tracked through the nucleation rate coefficients :math:`J_* \propto K_0 / K_1`, where :math:`K_0` and :math:`K_1` are the zeroth and first moment of the grain size distribution from the moment method. A particle is considered to have formed dust when :math:`K_0 > 0`, and its formation time is assigned at that dump, converted to years via ``utime`` and the ``physcon.years`` constant.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_dustformation.f90`` for the complete source.
