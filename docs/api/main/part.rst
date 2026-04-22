.. phantom-doc: hand-written

part
====

Overview
--------

The ``part`` module is the central data store for all particle information in
Phantom. It declares and allocates the arrays that hold the physical state of
every SPH particle, sink particle, and dust grain, and it defines the integer
constants used to index particle types in the ``iphase`` flag array. Every
Phantom routine that needs to read or write particle data imports from this
module, ensuring that there is a single, authoritative memory layout for the
particle state.

The four core arrays define the minimum state required to advance the
simulation. ``xyzh(4,maxp)`` packs the three Cartesian positions and the
smoothing length into a single contiguous array: ``xyzh(1:3,i)`` are
:math:`(x, y, z)` and ``xyzh(4,i)`` is :math:`h_i`. Similarly,
``vxyzu(4,maxp)`` packs the three velocity components and specific internal
energy: ``vxyzu(1:3,i)`` are :math:`(v_x, v_y, v_z)` and ``vxyzu(4,i)`` is
:math:`u_i`. This packing strategy keeps the most frequently accessed
quantities in adjacent memory locations, which is beneficial for cache
performance in the neighbour loop.

For MHD simulations, two additional arrays are used. ``Bevol(maxBevol,maxp)``
stores the evolved magnetic variable :math:`\mathbf{B}/\rho` together with
the divergence-cleaning scalar :math:`\psi`: the four components are labelled
``('Bx/rho', 'By/rho', 'Bz/rho', 'psi')``. The physical magnetic field
:math:`\mathbf{B}` is reconstructed on the fly and stored in
``Bxyz(3,maxp)``. Individual artificial viscosity and resistivity switches
are held in ``alphaind(nalpha,maxp)``, while divergence and curl of both
velocity and magnetic field are accumulated into ``divcurlv(ndivcurlv,maxp)``
and ``divcurlB(ndivcurlB,maxp)`` respectively.

Particle types are encoded in the integer array ``iphase(maxp)``. The
constants ``igas``, ``idust``, ``iboundary``, ``istar``, and ``idarkmatter``
identify the different types; routines use these constants via
``iamtype(iphase(i))`` to branch on particle type without hard-coding magic
numbers. The scalar ``npart`` and the array ``npartoftype(maxtypes)`` record
the particle count, while ``massoftype(maxtypes)`` stores the mass of each
particle type (constant per type in equal-mass simulations).

Physical & Mathematical Description
------------------------------------

The 4-component packing of ``xyzh`` and ``vxyzu`` exploits the fact that the
SPH density sum and force loop access position, velocity, and energy
simultaneously for each particle. Placing all four components contiguously
for a given particle (structure-of-arrays within a fixed stride) gives the
best balance between sequential access and SIMD vectorisation.

The magnetic induction variable stored in ``Bevol`` is :math:`\mathbf{B}/\rho`
rather than :math:`\mathbf{B}` itself. This choice follows from the ideal MHD
induction equation in Lagrangian form :cite:`price12`,

.. math::

   \frac{\mathrm{d}}{\mathrm{d}t}\!\left(\frac{\mathbf{B}}{\rho}\right)
   = \left(\frac{\mathbf{B}}{\rho}\cdot\nabla\right)\mathbf{v}
   - \frac{\mathbf{B}}{\rho}\,(\nabla\cdot\mathbf{v}),

which shows that :math:`\mathbf{B}/\rho` is the natural variable evolved by
the Lagrangian SPH operator in the absence of dissipation. Evolving
:math:`\mathbf{B}/\rho` directly reduces the amplitude of divergence errors
compared with evolving :math:`\mathbf{B}` :cite:`price12`.

Individual smoothing-length-dependent artificial viscosity is governed by

.. math::

   \alpha_i = \max\!\left(\alpha_\mathrm{min},\;
              \alpha_i - \frac{\Delta t}{\tau_i}(\alpha_i - \alpha_\mathrm{min})\right)
              + \text{source term},

where the source and decay timescale :math:`\tau_i` are computed from local
velocity divergence and signal speed. The value is stored in
``alphaind(1,i)`` for viscosity and ``alphaind(2,i)`` for resistivity.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/part.F90
