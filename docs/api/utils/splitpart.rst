.. phantom-doc: hand-written

splitpart
=========

Overview
--------

``splitpart`` provides the module-level routines for splitting and merging SPH particles to increase or decrease simulation resolution. The ``split_all_particles`` routine splits every gas particle into ``nchild`` children using a geodesic (icosahedron-based) or random lattice placement, preserving the total mass and momentum.

The splitting algorithm calls ``split_a_particle`` from ``splitmergeutils``, which places child particles on a local icosahedral lattice around the parent, rescaling the smoothing length as :math:`h_\mathrm{child} = h_\mathrm{parent} / n_\mathrm{child}^{1/3}`. The ``merge_all_particles`` companion routine (via ``fancy_merge_into_a_particle``) merges particles by conserving mass, momentum, and energy.

This module is used by the ``moddump_splitpart`` and ``moddump_mergepart`` moddump routines and by the adaptive particle refinement (APR) framework in Phantom.

Physical & Mathematical Description
------------------------------------

When splitting a parent particle of mass :math:`m_p` and smoothing length :math:`h_p` into :math:`N_\mathrm{child}` children, each child has mass :math:`m_c = m_p / N_\mathrm{child}` and is placed at position :math:`\mathbf{r}_c = \mathbf{r}_p + \Delta \mathbf{r}_c`, where :math:`\Delta \mathbf{r}_c` is a geodesic lattice offset of magnitude :math:`\approx h_p / 2`. The child smoothing lengths are :math:`h_c = h_p / N_\mathrm{child}^{1/3}` to preserve the local resolution.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/splitpart.f90
