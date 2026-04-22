.. phantom-doc: hand-written

readwrite_kepler
================

Overview
--------

The ``readwrite_kepler`` module reads stellar structure profiles produced
by the KEPLER stellar evolution code (Weaver et al. 1978) and converts
them into the format expected by Phantom's ``set_star`` module.  KEPLER
outputs a 1D Lagrangian grid in which each zone contains the cumulative
enclosed mass, zone radius, density, temperature, pressure, and elemental
composition; this module parses those columns and interpolates onto a
uniform mass grid suitable for use with ``stretchmap``.

The module also provides a write routine that exports the post-processed
(and optionally cored) stellar profile back to a KEPLER-compatible text
file, which can then be used for comparison or as input to subsequent
runs.  It handles multiple KEPLER output formats across different code
versions by detecting the number of header lines and the column ordering
automatically.

Physical & Mathematical Description
------------------------------------

KEPLER evolves a star on a spherical Lagrangian grid in which the
independent variable is the enclosed mass :math:`m`.  Each zone :math:`k`
contains the mass :math:`\Delta m_k`, radius :math:`r_k`, density
:math:`\rho_k`, temperature :math:`T_k`, and pressure :math:`P_k`.  After
reading, the profile is interpolated onto a uniform grid in enclosed mass
:math:`m \in [0, M_\star]` with :math:`N_\mathrm{grid}` points using
monotone cubic interpolation to avoid oscillations near composition
boundaries.

The mapping from the 1D KEPLER profile to SPH particles is then performed
by ``stretchmap``, which uses the remapped :math:`\rho(m)` to compute
the radial coordinate :math:`r(m)` via

.. math::

   m = \int_0^{r(m)} 4\pi r'^2\,\rho(r')\,dr'.

The specific internal energy for each SPH particle is computed from
:math:`T_k` and the mean molecular weight using the equation of state
selected in ``set_star``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/readwrite_kepler.f90
