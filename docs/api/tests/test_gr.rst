.. phantom-doc: hand-written

test_gr
=======

Overview
--------

The ``test_gr`` module (Fortran module ``testgr``) contains unit tests for the General
Relativistic hydrodynamics framework in Phantom, including tests of the metric routines,
geodesic integration, constraint satisfaction, and orbital precession. Units are set to
:math:`10^6 M_\odot`, :math:`G=1`, :math:`c=1` before any test runs. The module
orchestrates three main sub-tests: ``test_combinations_all``, which checks all supported
metric and primitive-variable-solver combinations; ``test_precession``, which verifies
orbital pericentre advance in the Kerr and Schwarzschild metrics; and ``test_inccirc``,
which checks inclined circular orbit properties.

The ``test_combinations_all`` sub-test loops over all combinations of metric
(:math:`\eta_{\mu\nu}`, Schwarzschild, Kerr) and primitive-variable recovery solver
(Newton-Raphson, bisection) and checks that the cons2prim solver recovers the primitive
variables :math:`\rho`, :math:`P`, :math:`v^i` from the conserved variables to within
the solver tolerance. The precession test verifies that the pericentre advances at the
rate predicted by the first post-Newtonian expansion of the Kerr geodesic, checking
angular momentum conservation over many orbits.

Physical & Mathematical Description
------------------------------------

The four-velocity normalisation :math:`u^\mu u_\mu = -1` (with signature :math:`{-,+,+,+}`)
is checked for every metric-solver combination to within machine precision. The precession
angle per orbit is compared to the analytic formula
:math:`\Delta\phi = 6\pi G M / (c^2 a (1-e^2))` for the Schwarzschild case, with a
tolerance that depends on the number of integration steps per orbit. Angular momentum
conservation is checked to better than :math:`10^{-5}` relative error over ten orbits.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_gr.f90
