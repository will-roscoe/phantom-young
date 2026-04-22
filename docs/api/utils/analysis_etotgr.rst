.. phantom-doc: hand-written

analysis_etotgr
===============

Overview
--------

``analysis_etotgr`` computes the total conserved energy in a general relativistic SPH simulation. Written by David Liptai, it evaluates the relativistic energy for each particle using the four-momentum and the covariant metric tensor, providing a post-processing check of energy conservation in GR Phantom simulations.

The routine initialises the metric at each dump via ``init_metric``, then loops over all particles to compute the four-velocity normalisation :math:`U^0` from the constraint :math:`g_{\mu\nu} U^\mu U^\nu = -1`, and the specific total energy as the zeroth covariant four-momentum component.

Output is written to an output file as a time series, enabling verification that the Hamiltonian constraint is satisfied and that the conserved energy is indeed constant during the evolution.

Physical & Mathematical Description
------------------------------------

In general relativity the specific conserved energy (for a geodesic) is :math:`e = -p_0 / m = -g_{0\mu} U^\mu`, where :math:`p_\mu = m g_{\mu\nu} U^\nu` is the covariant four-momentum and :math:`U^\mu` is the four-velocity. The normalisation :math:`g_{\mu\nu} U^\mu U^\nu = -1` (in :math:`-+++` signature) is used to determine :math:`U^0 = 1/\sqrt{-g_{00} - 2g_{0i}v^i - g_{ij}v^i v^j}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_etotgr.f90`` for the complete source.
