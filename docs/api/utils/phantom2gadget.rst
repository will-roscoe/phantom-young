.. phantom-doc: hand-written

phantom2gadget
==============

Overview
--------

``phantom2gadget`` converts a Phantom binary dump file to GADGET-2 format, enabling Phantom initial conditions to be used as starting points for GADGET simulations, or vice versa. It reads the Phantom dump using ``read_dump``, computes the density from the smoothing length using the SPH relation, and writes a GADGET dump using ``write_gadgetdump``.

The program takes two command-line arguments: the input Phantom dump filename and the output GADGET dump filename. It uses the Phantom equation of state (``polyk``) to evaluate the thermal energy, setting the GADGET thermal energy column appropriately.

The GADGET format stores particle data in a binary header followed by separate blocks for position, velocity, particle ID, mass, and internal energy, following the GADGET-2 snapshot format specification.

Physical & Mathematical Description
------------------------------------

Particle densities are computed from the SPH smoothing length via :math:`\rho_i = (\eta m_i / h_i^3)` using the SPH density-smoothing length relation :math:`h_i = \eta (m_i / \rho_i)^{1/3}`, where :math:`\eta = ` ``hfact`` is the kernel normalisation constant (typically 1.2 for the M4 cubic spline). The internal energy in GADGET is the specific internal energy :math:`u_i` in units of ``(km/s)^2``, obtained from the Phantom thermal energy column.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom2gadget.f90
