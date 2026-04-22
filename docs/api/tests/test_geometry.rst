.. phantom-doc: hand-written

test_geometry
=============

Overview
--------

The ``test_geometry`` module (Fortran module ``testgeometry``) tests the coordinate
transform routines in ``geometry.f90``, which provide conversions between Cartesian,
cylindrical, spherical, and other curvilinear coordinate systems used in Phantom setups
and analysis. The primary test verifies that applying a forward transform followed by the
inverse transform returns the original position vector to within floating-point precision
for every coordinate system registered in ``labelcoordsys`` (up to ``maxcoordsys``
systems).

The test uses two sets of reference vectors: one at a generic non-special position
:math:`(5, 6, 7)` and one at the origin :math:`(0, 0, 0)` where spherical coordinates
are degenerate. For each coordinate system the test also checks that the corresponding
3-vector (velocity or magnetic-field) transform is equally reversible via
``vector_transform``. A final sub-test verifies that ``get_coord_limits`` returns a
valid bounding box for each geometry.

Physical & Mathematical Description
------------------------------------

The round-trip accuracy test checks
:math:`|\mathbf{x}_{\rm out} - \mathbf{x}_{\rm in}| / |\mathbf{x}_{\rm in}| \leq \varepsilon`
for the position vector and similarly for the velocity vector, where
:math:`\varepsilon` is machine epsilon in single or double precision. Any result outside
this bound indicates a coding error in the transform formulae rather than a numerical
approximation error.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_geometry.f90
