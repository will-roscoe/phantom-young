.. phantom-doc: hand-written

set_cubic_core
==============

Overview
--------

The ``set_cubic_core`` module replaces the inner region of a 1D stellar
density profile with a smooth cubic-spline interpolant, eliminating the
central singularity while preserving :math:`C^1` continuity of the
density and its radial derivative at the matching radius
:math:`r_\mathrm{core}`.  This produces a physically smoother initial
condition than the flat-core approach of ``set_softened_core`` and avoids
the pressure discontinuity that the flat core introduces.

The module is used as a pre-processing step before the stellar profile is
mapped onto SPH particles.  It reads the 1D tabulation of
:math:`(\rho, P, T)` as a function of enclosed mass, fits a cubic spline
through the transition region, and writes the modified profile to a new
file.  The routine ensures that total mass is conserved across the core
boundary.

Physical & Mathematical Description
------------------------------------

At the matching radius :math:`r_\mathrm{core}` the cubic core satisfies
four conditions:

.. math::

   \rho(r_\mathrm{core}) = \rho_\mathrm{orig}(r_\mathrm{core}),\quad
   \rho'(r_\mathrm{core}) = \rho'_\mathrm{orig}(r_\mathrm{core}),\quad
   \rho(0) = \rho_0,\quad
   \rho'(0) = 0,

where the last two conditions enforce a smooth centre.  The cubic
polynomial

.. math::

   \rho_\mathrm{core}(r) = \rho_0 + c_2 r^2 + c_3 r^3

(the linear term is absent by symmetry) uniquely satisfies these four
constraints, with :math:`\rho_0` determined by mass conservation:

.. math::

   \int_0^{r_\mathrm{core}} \rho_\mathrm{core}(r)\,4\pi r^2\,dr
   = M_\mathrm{core}.

The pressure in the cubic core region is then computed from the
equation of state consistent with the surrounding envelope, ensuring
hydrostatic equilibrium in the modified profile.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_cubic_core.f90
