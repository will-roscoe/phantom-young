.. phantom-doc: hand-written

analysis_GalMerger
==================

Overview
--------

``analysis_GalMerger`` is a post-processing tool for galaxy merger simulations. It tracks the centre of mass of each galaxy throughout the merger by assigning particles to their initial galaxy of origin (stars, dark matter, and gas are distinguished by particle type) and computing mass-weighted centroids for each galaxy separately.

The routine also computes maximum and average densities for gas, stellar, and dark matter particles, providing an overview of the structural evolution of each galaxy as the merger progresses. Distances are reported in megaparsecs and times in years, using the unit conversion factors from ``units``.

Output is written to a time-series file with separate columns for each galaxy's centre of mass position and velocity, enabling orbital decay curves and merger timescales to be extracted.

Physical & Mathematical Description
------------------------------------

The centre of mass of galaxy :math:`g` at time :math:`t` is :math:`\mathbf{R}_g(t) = \sum_{i \in g} m_i \mathbf{r}_i / \sum_{i \in g} m_i`, where the sum is over all live particles initially assigned to galaxy :math:`g`. Particle type flags (``igas``, ``istar``, ``idarkmatter``) from the ``part`` module distinguish the baryonic and dark matter components.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_GalMerger.f90`` for the complete source.
