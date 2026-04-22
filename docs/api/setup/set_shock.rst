.. phantom-doc: hand-written

set_shock
=========

Overview
--------

The ``set_shock`` module constructs the initial conditions for one- and
three-dimensional shock-tube (Riemann-problem) tests.  It places SPH
particles in uniform lattices on both sides of a discontinuity at
:math:`x = 0`, assigning independent density, pressure, and velocity
values to each region.  The relative particle spacing on the two sides is
adjusted to achieve the requested density contrast without introducing any
particle-sorting artefacts at the contact surface.

The module calls ``set_unifdis`` to generate each sub-domain and then
merges the two particle arrays.  It handles arbitrary density ratios and
is therefore suitable for strong shocks as well as near-equal-density
problems.  The Brio–Wu MHD shock (Brio & Wu 1988) and the Sod shock tube
are standard test cases that can be configured directly through the
runtime parameter file.

Physical & Mathematical Description
------------------------------------

The Riemann-problem initial conditions are

.. math::

   \bigl(\rho,\, P,\, v_x\bigr) =
   \begin{cases}
   (\rho_L,\, P_L,\, v_L) & x < 0,\\
   (\rho_R,\, P_R,\, v_R) & x > 0,
   \end{cases}

where :math:`L` and :math:`R` denote left and right states.  The exact
solution (for a calorically perfect gas with :math:`\gamma = 5/3` or
:math:`7/5`) consists of a rarefaction wave, a contact discontinuity, and
a shock wave.  The particle spacing is set so that each particle has the
same mass :math:`m = \rho_L V_L / N_L = \rho_R V_R / N_R`, where
:math:`N_{L,R}` and :math:`V_{L,R}` are the particle counts and volumes
for the two regions.  The equal-mass condition ensures that the SPH
density estimate is accurate on both sides of the discontinuity from the
very first time step.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_shock.f90
