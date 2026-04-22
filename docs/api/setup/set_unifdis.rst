.. phantom-doc: hand-written

set_unifdis
===========

Overview
--------

The ``set_unifdis`` module places SPH particles on a perfectly uniform
lattice inside an arbitrary volume.  Several lattice geometries are
supported: simple cubic (SC), hexagonal close-packed (HCP), face-centred
cubic (FCC), and a generic close-packed arrangement in which successive
layers are offset so that every interior particle is in contact with twelve
neighbours.  The close-packed lattice produces the lowest SPH density
errors for a fixed particle count and is the default choice for most
Phantom setups.

The module handles MPI domain decomposition transparently: a masking
function (``i_belong``) assigns each particle to the correct MPI rank so
that only the locally owned particles are stored, avoiding any replicated
work.  The routine also returns the exact number of particles placed in
each coordinate direction, which is needed when constructing periodic
boxes or setting up paired simulations with different resolutions.

Physical & Mathematical Description
------------------------------------

For a close-packed arrangement the particle spacing in the
:math:`x`-direction is :math:`\Delta x` and the layers are offset by
:math:`(\Delta x/2,\, \Delta y/2)` in alternate planes.  The layer
spacing in :math:`z` is :math:`\Delta z = \Delta x \sqrt{2/3}` so that
each particle has twelve equidistant neighbours at distance
:math:`\Delta x`.

The particle mass is set from the target density and the volume assigned
to each lattice site.  For a simple cubic lattice the cell volume is
:math:`V_\mathrm{cell} = \Delta x^3`, giving

.. math::

   m = \rho\, V_\mathrm{cell} = \rho\,\Delta x^3.

For close-packed arrangements the unit-cell volume is
:math:`\sqrt{2}\,\Delta x^3`, yielding a packing fraction of
:math:`\pi/(3\sqrt{2}) \approx 0.7405`, the maximum possible for equal
spheres.  The helper function ``get_ny_nz_closepacked`` computes the
number of layers in :math:`y` and :math:`z` required to fill a box of
given dimensions with the specified inter-particle spacing.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_unifdis.f90
