.. phantom-doc: hand-written

utils_implicit
==============

Overview
--------

The ``implicit`` module provides the data structures and memory management
routines for Phantom's implicit radiative diffusion solver. Implicit
diffusion requires solving a sparse linear system that couples each SPH
particle to its neighbours; to do this efficiently the module builds and
stores a compacted neighbour-list representation in which only the
non-zero off-diagonal entries of the diffusion matrix are retained.

The module declares the arrays ``vari``, ``varij``, ``varij2``, ``varinew``
(per-particle and per-pair radiative variables), ``ivar`` (compact pair
index table), ``ijvar`` (pair-particle index), and ``mask`` (particle
inclusion flag). The routine ``allocate_memory_implicit`` allocates these
arrays based on the expected number of compact pairs, estimated from the
particle count, kernel radius, and smoothing-length normalisation factor.
An ``nneigh_average`` parameter tracks the mean number of neighbours.

Physical & Mathematical Description
------------------------------------

The implicit radiation diffusion equation

.. math::

   \frac{\partial E_r}{\partial t} = \nabla \cdot \left(\frac{c\lambda}{\kappa_R\rho}\nabla E_r\right)

is discretised in the SPH particle representation as a sparse matrix
equation :math:`A \mathbf{x} = \mathbf{b}`. The compacted neighbour list
stores only the pairs :math:`(i,j)` with :math:`|r_{ij}| < 2h` that
contribute non-zero entries to :math:`A`. The number of compact pairs scales
as :math:`N \times N_\text{neigh} / 2`, which determines the memory
allocation in ``allocate_memory_implicit``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_implicit.f90
