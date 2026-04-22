.. phantom-doc: hand-written

test_gravity
============

Overview
--------

The ``test_gravity`` module (Fortran module ``testgravity``) tests Phantom's self-gravity
solver by comparing the tree-based gravitational force against the direct O(N²) summation
from the ``directsum`` module. The module supports several named sub-tests selectable via
the string argument: ``directsum`` compares tree and direct-sum forces particle by
particle, ``taylorseries`` checks the multipole expansion coefficients, ``fmm`` exercises
the fast-multipole variant, and ``spheres`` or ``plummer`` tests the force on an
analytically known density profile such as a Plummer sphere.

For the direct-sum comparison the test sets up a small random particle distribution,
calls both the tree gravity solver and ``directsum_grav``, and checks that the force on
every particle agrees to within the expected tree accuracy :math:`\epsilon_{\rm tree}`.
The Plummer sphere test verifies that the enclosed-mass profile and the velocity
dispersion profile match the analytic Plummer model, providing an end-to-end check of the
gravity solver for a smooth, symmetric density distribution. The module is also
APR-compatible: when compiled with ``-DAPR`` it calls ``setup_apr_region_for_test`` to
ensure refinement regions do not corrupt the gravity solve.

Physical & Mathematical Description
------------------------------------

For the direct-sum comparison the force error is defined as
:math:`|\mathbf{f}_{\rm tree} - \mathbf{f}_{\rm direct}| / |\mathbf{f}_{\rm direct}|`
and must be less than the tree opening-angle tolerance, typically a few percent. For the
Plummer sphere the enclosed mass :math:`M(r) = M_{\rm tot} r^3 / (r^2 + a^2)^{3/2}` and
the radial force :math:`f_r = -GM(r)/r^2` are compared to the SPH result to within the
expected :math:`O(h^2)` SPH truncation error.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_gravity.f90
