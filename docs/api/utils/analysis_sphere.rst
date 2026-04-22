.. phantom-doc: hand-written

analysis_sphere
===============

Overview
--------

``analysis_sphere`` computes the radial profile of a spherical gas (or dust) distribution, binning particles into ``nbins = 512`` bins in either linear or logarithmic radius. The centre can be fixed at the origin or reset to the densest particle position (``centre_rhomax = .true.``), making it suitable for both smooth and self-gravitating sphere simulations.

The routine computes the mean density, radial velocity, and specific angular momentum in each radial shell, writing results to a file at each dump. The radial range is set by ``rmin_pc`` and ``rmax_pc`` in parsecs, and particles below the density threshold ``rhothresh_cgs`` are optionally excluded.

This analysis is well suited to molecular cloud collapse simulations, protostellar envelope studies, and infall calculations, where the spherical approximation is appropriate and radial profiles are the key diagnostic.

Physical & Mathematical Description
------------------------------------

The mean density in radial shell :math:`[r, r + \Delta r]` is :math:`\bar{\rho}(r) = \sum_{i \in \mathrm{shell}} m_i / V_\mathrm{shell}`, where :math:`V_\mathrm{shell} = 4\pi r^2 \Delta r`. For logarithmic bins of width :math:`\Delta(\ln r) = \mathrm{const}`, the shell volume is :math:`V_\mathrm{shell} = 4\pi r^2 \cdot r \Delta(\ln r)`. The free-fall time at the mean density is :math:`t_\mathrm{ff} = \sqrt{3\pi / (32 G \bar{\rho})}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_sphere.f90`` for the complete source.
