.. phantom-doc: hand-written

extern_densprofile — Gravitational Force from a Tabulated Density Profile
==========================================================================

Overview
--------

The ``extern_densprofile`` module computes the gravitational acceleration from a
spherically symmetric body whose density profile is stored as a tabulated function of
radius.  It is primarily used to provide the background gravitational potential for
stars in equilibrium — in particular neutron stars — during relaxation runs or when
one wishes to treat the self-gravity of a resolved stellar interior as an external
force rather than as explicit particle–particle SPH gravity.

At initialisation (``load_extern_densityprofile``) the module reads a plain-text
file (default name ``relax1.profile``) containing :math:`(r, \rho)` pairs.  From
these it computes the enclosed mass :math:`M_\mathrm{enc}(r)` by direct spherical
integration and builds a table of the radial gravity coefficient
:math:`f(r) = -G M_\mathrm{enc}(r)/r^3` at up to 5000 radial points.  At runtime,
``densityprofile_force`` interpolates this table to return the acceleration at an
arbitrary particle position; outside the tabulated surface the force falls off as
:math:`r^{-2}` extrapolated from the surface value.

Physical & Mathematical Description
-------------------------------------

For a spherically symmetric density distribution the enclosed mass at radius
:math:`r` is

.. math::

   M_\mathrm{enc}(r) = 4\pi\int_0^r \rho(r')\,{r'}^2\,dr',

approximated in discrete form as

.. math::

   M_\mathrm{enc}(r_i)
   = M_\mathrm{enc}(r_{i-1})
     + \tfrac{4}{3}\pi\bigl(r_i^3 - r_{i-1}^3\bigr)\,\rho(r_i).

The gravitational acceleration at position :math:`\mathbf{r} = (x,y,z)` is

.. math::

   \mathbf{f} = f(r)\,\mathbf{r},
   \quad
   f(r) = -\frac{G\,M_\mathrm{enc}(r)}{r^3},

which is radially inward for all :math:`r > 0`.  Outside the stellar surface
(:math:`r > r_\mathrm{surf}`) the force is extrapolated as

.. math::

   f(r) = f_\mathrm{surf}\,\left(\frac{r_\mathrm{surf}^2}{r^2}\right)^{3/2},

recovering exact :math:`r^{-2}` behaviour.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_densprofile.f90
