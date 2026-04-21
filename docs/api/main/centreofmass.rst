.. phantom-doc: hand-written

centreofmass
============

Overview
--------
The ``centreofmass`` module provides utility routines for computing and
manipulating the centre-of-mass (CoM) position, velocity, and acceleration of
the particle system. These routines are used at initial conditions setup, during
turbulent driving to remove spurious bulk flows, and within the gravitational
wave strain calculator in ``energies``.

The module is OpenMP-parallel and MPI-aware. All reduction operations are
performed via double-precision accumulators to minimise floating-point error
in the sum over potentially millions of particles. MPI reduction is applied
after the local OpenMP reduction to produce global values on all processes.

The public interface comprises six routines:

- ``reset_centreofmass`` — shifts all particle positions and velocities so that
  the CoM lies at the origin with zero bulk velocity; optionally includes sink
  particles.
- ``get_centreofmass`` — returns the mass-weighted CoM position and velocity,
  with optional inclusion of sink particles and total mass output.
- ``get_centreofmass_accel`` — returns the mass-weighted CoM acceleration,
  including both SPH and external force contributions from all particle types
  and sink particles.
- ``correct_bulk_motions`` — removes the bulk momentum from all particle
  velocities and accelerations, primarily used after a turbulent forcing step.
- ``get_total_angular_momentum`` — computes the total angular momentum vector
  of the system including both SPH particles and sink particles.
- ``get_particle_extent`` and ``print_particle_extent`` — report the spatial
  extent of the particle distribution.

Physical & Mathematical Description
-------------------------------------
The mass-weighted centre-of-mass position is defined as

.. math::
   :label: com_pos

   \mathbf{r}_{\rm com} = \frac{\displaystyle\sum_a m_a\,\mathbf{r}_a
                               + \sum_s M_s\,\mathbf{R}_s}
                               {\displaystyle\sum_a m_a + \sum_s M_s},

where the first sum runs over all live SPH particles with mass :math:`m_a` at
position :math:`\mathbf{r}_a`, and the second sum runs over sink particles
with mass :math:`M_s` at position :math:`\mathbf{R}_s`. The analogous
expression for the CoM velocity :math:`\mathbf{v}_{\rm com}` uses
particle velocities in place of positions.

The CoM acceleration, required for computing the gravitational wave quadrupole
moment, is

.. math::
   :label: com_accel

   \mathbf{a}_{\rm com} = \frac{\displaystyle\sum_a m_a\,(\mathbf{f}_a
                                + \mathbf{f}_a^{\rm ext})
                               + \sum_s M_s\,\mathbf{F}_s}
                               {M_{\rm tot}},

where :math:`\mathbf{f}_a` is the SPH specific force, :math:`\mathbf{f}_a^{\rm
ext}` is the external specific force, and :math:`\mathbf{F}_s` is the
acceleration of sink particle :math:`s`.

The total angular momentum about the origin is

.. math::
   :label: ang_mom

   \mathbf{L} = \sum_a m_a\,(\mathbf{r}_a \times \mathbf{v}_a)
              + \sum_s M_s\,(\mathbf{R}_s \times \mathbf{V}_s),

computed using the cross product via ``cross_product3D`` from the
``vectorutils`` module.

The ``correct_bulk_motions`` routine removes the mean velocity

.. math::

   \mathbf{v}_{\rm bulk} = \frac{\sum_a m_a\mathbf{v}_a}{M_{\rm tot}}

from all particle velocities and the mean acceleration from all particle
accelerations, ensuring that turbulent driving routines do not impart a net
translational drift to the simulation.

Derivations
-----------
The centre-of-mass formulae :eq:`com_pos`–:eq:`ang_mom` are the standard
Newtonian definitions applied to a discrete particle system. The mass-weighted
average is the exact SPH analogue of the continuum centre of mass
:math:`\mathbf{r}_{\rm com} = M^{-1}\!\int \rho\,\mathbf{r}\,dV`, with the
volume integral replaced by the sum :math:`\sum_a m_a\,\mathbf{r}_a`. No
approximation beyond the particle discretisation is involved. This is a
trivial computation with no corresponding external literature reference.

References
----------

No external literature reference is required for this computation; the method follows directly from standard discretisation principles.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/centreofmass.f90
