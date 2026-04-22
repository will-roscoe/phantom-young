.. phantom-doc: hand-written

set_slab
========

Overview
--------

The ``set_slab`` module sets up a thin three-dimensional slab — a box
with a large extent in :math:`x` and :math:`y` but a small extent in
:math:`z` — for quasi-two-dimensional test problems.  Particles are
placed on a close-packed lattice inside the box
:math:`[0, L_x] \times [0, L_y] \times [0, L_z]` with
:math:`L_z \ll L_x, L_y`.  Periodic boundary conditions in all three
directions make the slab effectively infinite in :math:`x` and :math:`y`
while remaining three-dimensional in the SPH sense.

Typical applications include Kelvin–Helmholtz instability tests, MHD
wave propagation, and radiative shock problems where translational
symmetry in two directions is desired.  The slab thickness in
:math:`z` is usually chosen to contain two or three particle layers so
that the SPH kernel spans the full depth without truncation, preserving
the three-dimensional neighbour structure.

Physical & Mathematical Description
------------------------------------

The aspect ratio of the slab is characterised by the ratio
:math:`\delta = L_z / L_x \ll 1`.  For a uniform particle number density
:math:`n = N / (L_x L_y L_z)` the inter-particle spacing is
:math:`\Delta x = n^{-1/3}` and the particle mass is

.. math::

   m = \rho\,\Delta x^3.

The smoothing length :math:`h` is set so that the kernel contains
approximately :math:`N_\mathrm{neigh}` neighbours in 3D, i.e.\
:math:`h = \eta\,\Delta x` where :math:`\eta \approx 1.2` for the cubic
spline kernel.  Because the slab is periodic, the first-particle images
at :math:`z \pm L_z` contribute to the kernel sum of boundary particles,
ensuring that the density estimate is uniform everywhere in the slab even
with only a single particle layer in :math:`z`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_slab.f90
