.. phantom-doc: hand-written

set_star
========

Overview
--------

The ``set_star`` module provides the primary interface for constructing
single and multiple stellar particle distributions in Phantom.  Given a
density profile (analytic or read from a 1D stellar evolution code), it
maps SPH particles onto the target profile, sets the thermal energy
consistent with the equation of state, and optionally relaxes the star
to hydrostatic equilibrium.  The same module handles collections of stars
through the ``set_stars`` routine, which iterates over an array of
``star_t`` configuration objects.

Multiple equations of state are supported at setup time.  For polytropic
or adiabatic stars the pressure is :math:`P = K \rho^\gamma` and the
density profile is obtained by integrating the Lane–Emden equation (see
``density_profiles``).  For MESA or KEPLER stellar evolution profiles the
radial tabulation of :math:`\rho(m)` is read from file and interpolated
onto the SPH particle mass distribution.  Tillotson and piecewise-polytrope
EOS options are also available for compact-object setups.

The module exports a ``star_t`` derived type that encapsulates all per-star
options, including the profile type flag, polytropic :math:`K` value, core
softening parameters, and the path to any external input file.  This design
lets a single simulation set up binary or hierarchical systems by passing
an array of ``star_t`` instances to ``set_stars``.

Physical & Mathematical Description
------------------------------------

For a polytropic star the structure is governed by the Lane–Emden equation,

.. math::

   \frac{1}{\xi^2}\frac{d}{d\xi}\!\left(\xi^2 \frac{d\theta}{d\xi}\right)
   = -\theta^n,

where :math:`\theta = (\rho/\rho_c)^{1/n}`, :math:`\xi` is a dimensionless
radius, and :math:`n = 1/(\gamma - 1)` is the polytropic index.  The
central density :math:`\rho_c` and polytropic constant :math:`K` are chosen
to match the requested stellar mass :math:`M_\star` and radius
:math:`R_\star`.

The specific internal energy for an adiabatic EOS is set from
:math:`u = P / [(\gamma-1)\rho]`.  For MESA profiles the tabulated
temperature and mean molecular weight are used together with the ideal-plus-
radiation EOS to compute :math:`u` at each SPH particle location.  After
particle placement the distribution is mapped via ``stretchmap`` (see the
``stretchmap`` module) to match the target :math:`\rho(r)` exactly, and
the star can then be relaxed iteratively using ``relax_star``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_star.f90
