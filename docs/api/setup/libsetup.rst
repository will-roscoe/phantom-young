.. phantom-doc: hand-written

libsetup
========

Overview
--------

The ``libsetup`` module defines the public API for the Phantom setup
library, re-exporting the most commonly used setup routines under a single
module name so that external programs can link to Phantom as a library
without needing to import every individual setup module.  The current
public interface re-exports ``set_unifdis`` (uniform lattice placement),
``set_density_profile`` from ``stretchmap`` (stretch-mapped density
profiles), and the helper ``get_ny_nz_closepacked`` (layer count for close-
packed lattices).

When Phantom is compiled as a library (``libphantom``), this module
provides the entry point for third-party codes that wish to use Phantom's
particle-placement routines without running the full SPH time integrator.
The module contains no physics of its own; it is purely a re-export facade
that ensures a stable, documented API surface.

Physical & Mathematical Description
------------------------------------

The setup library encapsulates three complementary operations.  The
``set_unifdis`` routine fills a volume with particles at uniform spacing
:math:`\Delta x`, giving a mass per particle of

.. math::

   m = \rho\,\Delta x^3

for a simple cubic lattice (or an equivalent expression for the HCP/FCC
variants).  The ``set_density_profile`` routine then remaps those particles
to a target density profile :math:`\rho(\mathbf{r})` using the stretch-
mapping technique, which preserves the total particle count while adjusting
inter-particle spacings so that the smoothed SPH density matches the
target.  The ``get_ny_nz_closepacked`` helper computes the number of
particle layers in the :math:`y` and :math:`z` directions needed to fill
a box of given physical dimensions with a specified inter-particle spacing,
which is required before ``set_unifdis`` is called.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/libsetup.f90
