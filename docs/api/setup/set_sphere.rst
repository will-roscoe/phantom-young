.. phantom-doc: hand-written

set_sphere
==========

Overview
--------

The ``set_sphere`` module places SPH particles inside a sphere with a
user-specified density profile :math:`\rho(r)`.  Particles are first
distributed uniformly inside a unit sphere using the ``set_unifdis``
routine, then remapped to the target profile by the stretch-mapping
technique implemented in ``stretchmap``.  The result is a particle
distribution whose density field, when smoothed with the SPH kernel,
closely matches the analytic :math:`\rho(r)` without any Monte-Carlo
shot noise.

The module provides two public routines: ``set_sphere`` for full three-
dimensional spherical distributions and ``set_ellipse`` for oblate or
prolate ellipsoidal distributions where each axis can be independently
scaled.  Both accept a callback function so that arbitrary analytic or
tabulated density profiles can be passed in at run time.

Physical & Mathematical Description
------------------------------------

Stretch mapping works by enforcing conservation of the cumulative mass
fraction.  Let :math:`\bar{r}` be the uniform-distribution radius of a
particle and :math:`r` its remapped radius.  The mapping condition is

.. math::

   \frac{M(<r)}{M_\mathrm{tot}} = \frac{M(<\bar{r})}{M_\mathrm{tot}}
   \;\Longleftrightarrow\;
   \int_0^r \rho(r') \, 4\pi r'^2 \, dr' =
   \int_0^{\bar r} \rho_\mathrm{unif} \, 4\pi r'^2 \, dr'.

For a uniform sphere :math:`\rho_\mathrm{unif} = \text{const}`, so the
right-hand side equals :math:`(\bar{r}/R)^3 M_\mathrm{tot}`.  The mapping
:math:`\bar{r} \to r` is found by numerically inverting the cumulative-
mass integral of :math:`\rho(r)`.  Angular coordinates are preserved, so
the angular distribution of the original uniform lattice is inherited by
the final configuration, keeping the particle arrangement as uniform as
possible.  Each particle mass is set to
:math:`m = M_\mathrm{tot} / N_\mathrm{part}` to ensure exact total mass
conservation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_sphere.f90
