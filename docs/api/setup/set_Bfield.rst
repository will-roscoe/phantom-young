.. phantom-doc: hand-written

set_Bfield
==========

Overview
--------

The ``set_Bfield`` module adds a magnetic field to an existing SPH
particle distribution.  It supports uniform fields, toroidal fields
whose amplitude scales with the local density, and user-supplied field
profiles passed via a callback.  The module is called after the particle
positions and densities have been set up; it only assigns the magnetic
field components stored in the Phantom ``Bxyz`` array.

Phantom uses the Euler-potential or divergence-cleaning formulation for
MHD, but the initial field is specified in terms of the physical
components :math:`(B_x, B_y, B_z)`.  The ``set_Bfield`` routine writes
these directly.  For toroidal configurations the field is constructed so
that :math:`\nabla\cdot\mathbf{B} = 0` is satisfied analytically to
machine precision; for uniform fields the divergence is identically zero
by construction.

Physical & Mathematical Description
------------------------------------

A uniform field is specified as a constant vector
:math:`\mathbf{B} = B_0\,\hat{e}`, where :math:`\hat{e}` is the chosen
direction.  For a toroidal field in cylindrical coordinates
:math:`(R, \phi, z)` the azimuthal component is

.. math::

   B_\phi(R) \propto \rho(R),

which is divergence-free in the toroidal direction because
:math:`\partial B_\phi / \partial \phi = 0`.  The plasma beta parameter,

.. math::

   \beta = \frac{2\mu_0 P}{B^2},

is a convenient dimensionless measure of the magnetic field strength
relative to the thermal pressure.  The field normalisation is often chosen
so that :math:`\beta` equals a target value at a representative location
(e.g., the stellar centre or the disc mid-plane).  The
:math:`\nabla\cdot\mathbf{B}=0` constraint is maintained throughout the
simulation by the hyperbolic divergence-cleaning scheme of
:cite:`triccoprice12`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_Bfield.f90
