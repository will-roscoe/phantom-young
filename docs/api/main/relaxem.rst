.. phantom-doc: hand-written

relaxem
=======

Overview
--------

The ``relaxem`` module provides iterative particle relaxation for Phantom's
adaptive particle refinement (APR) system. When new particles are split from
coarser-resolution particles, they are initially placed on a regular
sub-lattice. The ``relax_particles`` subroutine then iteratively displaces
these new particles toward their equilibrium positions by minimising the
difference between the force on each new particle (computed from the full SPH
density and force routines) and a reference force field interpolated from
the parent particle distribution.

The relaxation loop calls ``get_derivs_global`` to compute SPH accelerations
at all particle positions, then ``get_reference_accelerations`` to
interpolate the parent-particle accelerations to the new particle positions
by weighted SPH interpolation, and finally ``shift_particles`` to move each
new particle in the direction that reduces the discrepancy. Convergence is
measured by the kinetic energy ratio :math:`E_k / E_{k,0}` and by the
maximum displacement; the loop terminates when either falls below
``shuffle_tol = 0.05`` or after at most ``nshifts`` iterations.

Physical & Mathematical Description
------------------------------------

The relaxation displacement for particle :math:`i` is proportional to the
force residual :math:`\delta \mathbf{f}_i = \mathbf{f}_i^{\rm SPH} -
\mathbf{f}_i^{\rm ref}`, where :math:`\mathbf{f}_i^{\rm ref}` is the
reference acceleration at position :math:`\mathbf{r}_i` interpolated from
the parent grid using standard SPH kernel interpolation. The kinetic energy
proxy :math:`E_k = \sum_i |\delta \mathbf{f}_i|^2` decreases monotonically
under this scheme if the step size is small enough, providing a convergence
criterion that does not require resolving actual particle dynamics.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/relaxem.f90
