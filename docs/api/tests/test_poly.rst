.. phantom-doc: hand-written

test_poly
=========

Overview
--------

The ``test_poly`` module (Fortran module ``testpoly``) tests the polynomial root-finding
utilities in Phantom, currently focussing on the quartic solver in the ``quartic`` module.
The quartic solver is used in various parts of the code, for example to find roots of the
fourth-order polynomial that arises when converting between conserved and primitive
variables in the radiation-hydrodynamics solver. Correctness of the solver is therefore a
prerequisite for the radiation tests.

The ``test_quartic`` sub-routine exercises ``quarticsolve`` on two cases: the simple
polynomial :math:`x^4 - 16 = 0` whose positive root is :math:`x = 2`, and an arbitrary
quartic with coefficients chosen to have a known real root. For each case the test checks
both the returned root value and the error code ``ierr``, and additionally verifies that
the residual :math:`f(x) = a_0 + a_1 x + a_2 x^2 + a_3 x^3 + x^4` evaluated at the
returned solution is zero to within the tolerance ``tol = 1e-6``.

Physical & Mathematical Description
------------------------------------

The quartic solver returns the smallest positive real root of
:math:`x^4 + a_3 x^3 + a_2 x^2 + a_1 x + a_0 = 0` using a combination of analytical
depressed-quartic formulae and Newton-Raphson polishing. The test verifies that
:math:`|f(x_{\rm sol})| \leq 10^{-6}` for each polynomial tested, which is sufficient to
guarantee the solution is a root to single-precision accuracy.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_poly.f90
