.. phantom-doc: hand-written

Stress-Energy Tensor Grid Projection
======================================

Overview
--------

The ``tmunu2grid`` module projects the SPH particle stress-energy tensor
:math:`T^{\mu\nu}` onto a regular Cartesian grid, a step required when Phantom is coupled
to the Einstein Toolkit for self-consistent numerical relativity. The Einstein Toolkit
evolves the spacetime geometry in response to the matter distribution; it requires
:math:`T^{\mu\nu}` evaluated on its grid at every coupling step.

The principal routine ``get_tmunugrid_all`` loops over all SPH particles, assembles a
per-particle array of the 16 independent components of :math:`T_{\mu\nu}` (indexed as a
:math:`4\times 4` matrix flattened to a vector of length 16), and then calls the
vectorised SPH interpolation routine ``interpolate3D_vecexact`` from the ``interpolations3D``
module to spread these values onto the Einstein Toolkit grid with kernel-weighted summation.

The grid geometry (origin, spacing, and size) is obtained from ``einsteintk_utils``. The
interpolation weight for particle :math:`a` is the standard SPH kernel weight
:math:`w_a = m_a/(\rho_a h_a^3)`, and the interpolation is performed with periodic
boundary conditions matching the domain.

Utility subroutines ``check_conserved_dens`` and ``check_conserved_p`` can compute the
total mass and momentum on the grid for conservation diagnostics. The helper
``get_particle_domain`` maps the SPH domain boundaries to grid indices, accounting for the
offset between the particle domain and the larger Einstein Toolkit grid that includes
boundary ghost zones.

Physical & Mathematical Description
-------------------------------------

The stress-energy tensor for a perfect relativistic fluid is:

.. math::

   T^{\mu\nu} = \rho h\, u^\mu u^\nu + P g^{\mu\nu}

where :math:`h = 1 + u + P/\rho` is the specific enthalpy, :math:`\rho` is the rest-frame
mass density, :math:`P` is the pressure, and :math:`u^\mu` is the 4-velocity. In the
covariant form:

.. math::

   T_{\mu\nu} = \rho h\, u_\mu u_\nu + P g_{\mu\nu}

The grid value at node :math:`(i,j,k)` is constructed by the SPH interpolation:

.. math::

   T^{\mu\nu}_{ijk} = \frac{\sum_a m_a T^{\mu\nu}_a W(\mathbf{x}_{ijk} - \mathbf{x}_a, h_a)}
                           {\sum_a m_a W(\mathbf{x}_{ijk} - \mathbf{x}_a, h_a)}

where :math:`W` is the SPH smoothing kernel and the sum runs over all particles in the
domain. The normalisation (``normalise = .true.``) ensures that a uniform field is
exactly reproduced on the grid.

The lower grid index corresponding to physical coordinate :math:`x` is:

.. math::

   i_{\rm low} = \mathrm{nint}\!\left(\frac{x - x_{\rm origin}}{\Delta x}\right) + 1

References
----------

Magnall, Price, Lasky & Macpherson (2023), Phys. Rev. D 108, 103534 — not yet in
phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/tmunu2grid.f90
