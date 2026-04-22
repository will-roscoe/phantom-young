.. phantom-doc: hand-written

test_rwdump
===========

Overview
--------

The ``test_rwdump`` module (Fortran module ``testrwdump``) performs round-trip read/write
tests on Phantom's binary dump files. It writes both full dumps and small (reduced-array)
dumps, reads them back, and verifies that every array is recovered bit-for-bit identically.
The test covers all particle arrays (positions, velocities, smoothing lengths, internal
energies, dust fractions, magnetic fields, alpha viscosity parameters, gravitational
potentials) and all sink-particle arrays, using up to 67 individual ``checkval`` calls
per dump.

The test runs twice (``itest = 1, 2``): first with the default memory allocation and then
after a dynamic memory reallocation to verify that reallocation does not corrupt the dump
reader. It also checks the ``read_array_from_file`` utility that allows a single named
array to be extracted from a dump without reading the entire file, verifying that the
extracted values match the in-memory originals. A boundary-condition block
(``xmin``–``zmax``) is also written and verified. The test uses both double-precision
(``toldp = 0``) and single-precision (``tol``) tolerances depending on the array type.

Physical & Mathematical Description
------------------------------------

The correctness criterion for full dumps is exact: every floating-point value read back
must match the value written to the same bit pattern, since no lossy compression is
applied. For small dumps only the explicitly written arrays (positions, velocities, and a
subset of the hydro quantities) are checked. Integer arrays (``iphase``, ``iorig``) use
a zero absolute tolerance; real arrays use a tolerance consistent with their storage
precision (zero for double-precision blocks, :math:`10^{-7}` for single-precision blocks).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_rwdump.f90
