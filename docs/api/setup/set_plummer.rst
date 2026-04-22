.. phantom-doc: hand-written

set_plummer
===========

Overview
--------

The ``set_plummer`` module generates SPH particle distributions following
the Plummer sphere and Hernquist sphere density profiles, both of which
are widely used models for stellar clusters, galactic bulges, and dark
matter haloes.  The module provides analytic expressions for :math:`\rho(r)`
and the cumulative mass :math:`M(<r)` for each profile, which are passed
to ``stretchmap`` so that an initially uniform particle distribution is
remapped to the target profile.

Both the Plummer and Hernquist profiles are cusp-free and approach zero
density at large radii, making them suitable for isolated-system setups
where reflective or vacuum boundary conditions are applied.  The Plummer
scale radius :math:`a` sets the characteristic size; particles outside a
truncation radius are optionally excluded to keep the particle count finite.

Physical & Mathematical Description
------------------------------------

The **Plummer sphere** density profile is

.. math::

   \rho(r) = \frac{3M}{4\pi a^3}
             \left(1 + \frac{r^2}{a^2}\right)^{-5/2},

giving a cumulative mass

.. math::

   M(<r) = M\,\frac{r^3}{\left(r^2 + a^2\right)^{3/2}}.

The **Hernquist sphere** profile is

.. math::

   \rho(r) = \frac{M}{2\pi a^3}\,\frac{1}{(r/a)(1 + r/a)^3},

with cumulative mass

.. math::

   M(<r) = M\,\frac{r^2}{(r + a)^2}.

The Hernquist profile has a :math:`\rho \propto r^{-1}` central cusp and
a :math:`\rho \propto r^{-4}` outer envelope, making it a better match
to the de Vaucouleurs :math:`R^{1/4}` surface brightness law for
elliptical galaxies than the shallower Plummer model.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_plummer.f90
