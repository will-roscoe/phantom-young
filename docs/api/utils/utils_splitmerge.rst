.. phantom-doc: hand-written

utils_splitmerge
================

Overview
--------

``utils_splitmerge`` (module ``splitmergeutils``) provides the fundamental particle splitting and merging operations used by the adaptive particle refinement (APR) framework and the ``splitpart`` module. The ``split_a_particle`` routine places ``nchild`` daughter particles around a parent particle using either a geodesic icosahedral lattice or a random placement, while ``fancy_merge_into_a_particle`` merges a set of children back into a single particle conserving mass, momentum, and energy.

The splitting uses icosahedral vertices (from the ``icosahedron`` module) for the geodesic lattice placement, which provides a rotationally invariant distribution of child particle positions. The child smoothing lengths and velocities are inherited from the parent, with the mass divided equally among all children.

This module is the computational core of Phantom's particle splitting capability, enabling resolution refinement in regions of interest (e.g. collapsing cores, disc gaps) without a full AMR grid.

Physical & Mathematical Description
------------------------------------

For splitting into :math:`N_\mathrm{child}` children with ``lattice_type = 0`` (geodesic), each child is placed at :math:`{\bf r}_c = {\bf r}_p + \Delta r \hat{{\bf n}}_c`, where :math:`\hat{{\bf n}}_c` is a unit vector toward one of the icosahedral lattice points at resolution ``ires`` and :math:`\Delta r \sim h_p / 2`. Child masses are :math:`m_c = m_p / N_\mathrm{child}` and smoothing lengths are :math:`h_c = h_p / N_\mathrm{child}^{1/3}`. Velocities are inherited from the parent to conserve momentum.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_splitmerge.f90
