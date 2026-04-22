.. phantom-doc: hand-written

utils_shuffleparticles
======================

Overview
--------

The ``utils_shuffleparticles`` module provides iterative particle relaxation
routines that adjust particle positions to match a target density profile
using only the particles' own positions (without computing SPH forces). The
public subroutine ``shuffleparticles`` accepts an input particle distribution
and iteratively displaces particles to achieve a uniform density, a
sphere-in-box profile, a Bonnell-Ebert sphere profile, or an arbitrary
user-supplied density array. This is used during setup (``phantomsetup``)
to create relaxed initial conditions.

The algorithm works by computing the SPH density of each particle, comparing
it to the target profile, and moving particles in the direction that reduces
the discrepancy. The procedure is repeated until the maximum fractional
density error falls below a tolerance. Periodic boundary conditions are
supported via the ``mpidomain`` module. The module supports ``iuniform``,
``isphereinbox``, and ``iarray`` profile identifiers.

Physical & Mathematical Description
------------------------------------

The shuffle step for particle :math:`i` is a displacement proportional to
the gradient of the density error:

.. math::

   \Delta\mathbf{r}_i \propto -\nabla\!\left(\frac{\rho_i - \rho_\text{target}(\mathbf{r}_i)}
   {\rho_\text{target}(\mathbf{r}_i)}\right),

where :math:`\rho_i` is the SPH-computed density and
:math:`\rho_\text{target}` is the desired profile. The step size is reduced
geometrically each iteration to ensure convergence. The algorithm requires
recomputing the SPH density via the k-d tree neighbour search at each step,
which makes it expensive for large particle counts but robust for complex
target profiles.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_shuffleparticles.F90
