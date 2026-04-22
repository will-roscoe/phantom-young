.. phantom-doc: hand-written

grids_for_setup
===============

Overview
--------

The ``grids_for_setup`` module loads external density or velocity fields
from ASCII or binary grid files and interpolates them onto SPH particle
positions.  It is used when the initial conditions are computed by an
external code (e.g.\ a grid-based MHD code or a stellar evolution code)
and the resulting field needs to be mapped onto the Phantom particle
distribution without re-running the SPH setup from scratch.

The module handles both uniform Cartesian grids and spherically symmetric
1D profiles, performing trilinear (3D) or linear (1D) interpolation as
appropriate.  It is called from disc, cloud, and stellar setup routines
when the ``iwarp`` or ``iprofile`` flags indicate that an external file
should be read.  The grid dimensions and coordinate bounds are detected
automatically from the file header.

Physical & Mathematical Description
------------------------------------

For a three-dimensional Cartesian grid with :math:`N_x \times N_y \times N_z`
cells, the cell centres are at positions
:math:`x_i = x_\mathrm{min} + (i-1/2)\,\Delta x` (and similarly in
:math:`y` and :math:`z`).  Trilinear interpolation of a field
:math:`f` to a particle at position :math:`(x_p, y_p, z_p)` gives

.. math::

   f(x_p, y_p, z_p) = \sum_{i=0}^{1}\sum_{j=0}^{1}\sum_{k=0}^{1}
   w_i(x_p)\,w_j(y_p)\,w_k(z_p)\,f_{i_0+i,\,j_0+j,\,k_0+k},

where :math:`(i_0, j_0, k_0)` is the index of the cell containing the
particle and the weights are :math:`w_i = 1 - |x_p - x_{i_0+i}|/\Delta x`.
For 1D spherical profiles the equivalent formula uses linear interpolation
in :math:`r`.  The module checks that every particle falls within the grid
bounds and issues a warning (but does not abort) if extrapolation is
needed at the boundary.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/grids_for_setup.f90
