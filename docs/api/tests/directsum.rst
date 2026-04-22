.. phantom-doc: hand-written

directsum
=========

Overview
--------

The ``directsum`` module implements a brute-force O(N²) gravitational summation over all
particle pairs, providing a reference solution against which the Phantom k-d tree gravity
solver can be validated. The single public routine ``directsum_grav`` iterates over every
pair :math:`(i,j)` of active particles and accumulates both the gravitational force and
the total potential, using the same kernel softening as the tree code so that the
comparison is exact in the limit of large particle number.

Because the algorithm scales as O(N²) it is only practical for the small particle counts
used in unit tests (typically a few hundred to a few thousand particles). The routine
correctly handles the ``iphase`` array so that only active non-accreted particles
contribute to the sum, and it supports the adaptive particle refinement (APR) extension
by reading per-level masses from ``aprmassoftype`` when the ``use_apr`` flag is set.

Kernel softening is applied consistently with the production tree code: the gravitational
force and potential are computed from the softening kernel :math:`\phi(q)` where
:math:`q = r/h`, so that the direct-sum result converges to the tree result as the
opening angle criterion is tightened. This makes ``directsum_grav`` the ground truth for
tests in the ``test_gravity`` and ``test_gnewton`` modules.

Physical & Mathematical Description
------------------------------------

The routine solves the gravitational Poisson equation
:math:`\nabla^2 \phi = 4\pi G \rho` by direct pair summation.
For each pair the softened force and potential are computed from the kernel functions
``grkern`` and ``kernel_softening`` as :math:`f_{ij} = G m_j \nabla W(r_{ij},h_i)` and
similarly for the symmetric :math:`j \to i` contribution. The total potential ``phitot``
is accumulated as a double sum with a factor of one-half to avoid double-counting.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/directsum.f90
