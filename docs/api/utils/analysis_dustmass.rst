.. phantom-doc: hand-written

analysis_dustmass
=================

Overview
--------

``analysis_dustmass`` computes and monitors the conservation of total gas and dust mass in simulations using the one-fluid or two-fluid dust algorithm. It evaluates the total gas mass, total dust mass, and accreted mass at each post-processing dump, providing a check that the dust fraction is correctly conserved during the simulation.

The routine handles both the ``dustfrac`` (one-fluid) and separate particle (two-fluid) representations of dust, iterating over all live particles and summing contributions from each dust species. The initial masses are saved on the first call for comparison at subsequent times.

Output is a time series of total gas mass :math:`M_\mathrm{gas}(t)`, total dust mass :math:`M_\mathrm{dust}(t)`, and accreted mass :math:`M_\mathrm{acc}(t)`, written to a log file for easy verification of mass conservation.

Physical & Mathematical Description
------------------------------------

For the one-fluid dust method, the dust mass is :math:`M_\mathrm{dust} = \sum_i m_i \sum_k \epsilon_{i,k}`, where :math:`\epsilon_{i,k}` is the dust fraction for dust species :math:`k` in particle :math:`i`. The gas mass is :math:`M_\mathrm{gas} = \sum_i m_i (1 - \sum_k \epsilon_{i,k})`. Conservation requires :math:`M_\mathrm{gas} + M_\mathrm{dust} + M_\mathrm{acc} = \mathrm{const}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_dustmass.f90`` for the complete source.
