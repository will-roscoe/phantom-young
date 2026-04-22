.. phantom-doc: hand-written

readwrite_mesa
==============

Overview
--------

The ``readwrite_mesa`` module reads stellar profiles produced by the MESA
(Modules for Experiments in Stellar Astrophysics) code (Paxton et al.
2011, ApJS 192, 3) and translates them into the internal format required
by Phantom's ``set_star`` module.  A MESA profile is a text file with a
standardised header specifying the column names; this module locates the
density, temperature, pressure, radius, mass, and composition columns by
name, making it robust to changes in column ordering between MESA versions.

The module handles the conversion from MESA's Lagrangian coordinates (in
which the independent variable is the stellar mass fraction
:math:`q = m/M_\star`) to the Eulerian radial coordinate needed by
``stretchmap``.  It also computes the hydrogen and helium mass fractions
from the MESA composition arrays, which are needed for the ideal-plus-
radiation or recombination EOS options in ``set_star``.

Physical & Mathematical Description
------------------------------------

MESA profiles are tabulated as functions of the mass coordinate
:math:`q \in [0, 1]`.  The stellar radius as a function of enclosed mass
is computed by integrating the continuity equation,

.. math::

   \frac{dr}{dm} = \frac{1}{4\pi r^2 \rho},

outward from the centre.  After reading the MESA columns, the module
integrates this ODE using the trapezoidal rule on the MESA mass grid to
obtain :math:`r(m)`.  The result is a table of
:math:`[\rho(r), T(r), P(r), X(r), Y(r)]` from which ``stretchmap``
constructs the SPH particle positions and from which ``set_star`` assigns
the specific internal energies.

The hydrogen mass fraction :math:`X` and helium mass fraction :math:`Y`
extracted from the MESA composition arrays are stored per-particle when
``use_var_comp = .true.`` is set in the star options, enabling spatially
varying mean molecular weights throughout the stellar interior.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`set_star` — consumes MESA profiles to initialise SPH stellar particles.

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/readwrite_mesa.f90
