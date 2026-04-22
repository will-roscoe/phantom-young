.. phantom-doc: hand-written

stretchmap
==========

Overview
--------

The ``stretchmap`` module implements the stretch-mapping technique for
generating SPH particle distributions that follow an arbitrary target
density profile.  Given :math:`N` particles already placed on a uniform
lattice (by ``set_unifdis`` or ``set_sphere``), the routine computes the
cumulative mass fraction of both the uniform distribution and the target
profile and then moves each particle radially so that its enclosed-mass
fraction is preserved.  The result is a particle arrangement whose
smoothed density matches the target :math:`\rho(\mathbf{r})` with
sub-percent accuracy and without any Monte-Carlo noise.

The technique works in Cartesian, cylindrical, spherical, and toroidal
coordinate systems; the coordinate choice is passed as a flag so that the
same algorithm handles disc, sphere, and torus setups.  The module was
originally described by Herant (1994, MmSAI 65, 1013) and extended by
Price (2004, PhD thesis) to arbitrary coordinate systems.  The
``set_density_profile`` routine is the main public entry point; a
lower-level ``get_mass_r`` helper is also exported for computing
cumulative mass profiles.

Physical & Mathematical Description
------------------------------------

For a spherically symmetric target profile the mapping condition is

.. math::

   M_\mathrm{target}(<r) = M_\mathrm{uniform}(<\bar{r}),

where :math:`\bar{r}` is the particle radius before remapping and
:math:`r` is the radius after.  Because the uniform distribution has
:math:`M(<\bar{r}) = M_\mathrm{tot}\,(\bar{r}/R)^3`, the target radius
satisfies

.. math::

   \int_0^r \rho_\mathrm{target}(r')\,4\pi r'^2\,dr'
   = M_\mathrm{tot}\left(\frac{\bar{r}}{R}\right)^3.

The left-hand side is monotonically increasing, so the root is bracketed
and solved with a Newton–Raphson iteration.  Particle angular coordinates
:math:`(\theta,\phi)` are unchanged, preserving the glass-like
regularity of the original lattice.  In cylindrical coordinates the same
logic applies with :math:`r \to R` (cylindrical radius), making the
technique equally applicable to disc surface density profiles
:math:`\Sigma(R)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/stretchmap.f90
