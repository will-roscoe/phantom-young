.. phantom-doc: hand-written

test_gnewton
============

Overview
--------

The ``test_gnewton`` module (Fortran module ``testgnewton``) tests the generalised
Newtonian gravitational potential from ``extern_gnewton``, which provides a
pseudo-Newtonian approximation to the Schwarzschild metric (the Paczyński-Wiita potential)
for use in simulations where full general relativity is not required. The test places a
test particle on an eccentric orbit around a central mass and integrates the trajectory
using the leapfrog stepper, monitoring the total orbital energy and angular momentum over
many periods.

The integration verifies that the generalised Newtonian orbital energy computed by
``get_gnewton_energy`` is conserved to within a tolerance commensurate with the
discretisation error of the chosen timestep. The test also checks the pericentre advance
rate predicted by the Paczyński-Wiita potential and compares it to the analytic expression
for the precession frequency, confirming that the potential produces the correct
relativistic pericentre shift at the level of the post-Newtonian approximation.

Physical & Mathematical Description
------------------------------------

The Paczyński-Wiita potential is :math:`\Phi = -GM/(r - r_{\rm g})` where
:math:`r_{\rm g} = 2GM/c^2` is the Schwarzschild radius. The conserved orbital energy
is :math:`E = \tfrac{1}{2}v^2 + \Phi` and the specific angular momentum is
:math:`L = |\mathbf{r}\times\mathbf{v}|`. The test checks :math:`|E - E_0|/|E_0|` and
:math:`|L - L_0|/|L_0|` at the end of each orbit to prescribed fractional tolerances that
depend on the timestep criterion parameter ``C_force``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_gnewton.f90
