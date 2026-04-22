.. phantom-doc: hand-written

set_softened_core
=================

Overview
--------

The ``set_softened_core`` module replaces the innermost region of a
tabulated stellar density profile with a flat (softened) core, removing
the numerical singularity that arises in stellar evolution profiles at
:math:`r = 0`.  The routine identifies the radius :math:`r_\mathrm{core}`
below which the profile is replaced, computes the mass contained in that
region, and redistributes it uniformly so that the integrated mass is
conserved.

This softening step is applied before the stellar profile is mapped onto
SPH particles (via ``stretchmap`` or ``set_sphere``), because a
:math:`\rho \to \infty` central density would require an impractically
large number of particles to resolve.  The module is intended to be used
in conjunction with the companion modules ``set_cubic_core`` and
``set_fixedentropycore``, which provide smoother alternatives to the flat
core.

Physical & Mathematical Description
------------------------------------

The softened profile is defined as

.. math::

   \rho_\mathrm{soft}(r) =
   \begin{cases}
   \rho_\mathrm{core} & r \leq r_\mathrm{core},\\
   \rho_\mathrm{orig}(r) & r > r_\mathrm{core},
   \end{cases}

where the constant core density :math:`\rho_\mathrm{core}` is chosen so
that the total mass is unchanged:

.. math::

   \frac{4}{3}\pi r_\mathrm{core}^3\,\rho_\mathrm{core}
   = \int_0^{r_\mathrm{core}} \rho_\mathrm{orig}(r)\,4\pi r^2\,dr
   \equiv M_\mathrm{core}.

The matching at :math:`r_\mathrm{core}` introduces a density jump of
magnitude :math:`\rho_\mathrm{orig}(r_\mathrm{core}) - \rho_\mathrm{core}`.
If a smooth match is required, the cubic-core or fixed-entropy-core
modules should be used instead.  The softened profile is written to an
output file so that subsequent modules (e.g.\ ``set_star``) can read the
modified profile directly.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_softened_core.f90
