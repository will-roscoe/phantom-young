.. phantom-doc: hand-written

test_hierarchical
=================

Overview
--------

The ``test_hierarchical`` module (Fortran module ``testsethier``) tests the hierarchical
multiple-system setup routines in Phantom. The module currently focuses on testing the
string parser that interprets a hierarchical system description (e.g. ``"111,112,113"``
for a triple system composed of an inner binary and a third companion) and verifies that
the parser produces the correct internal representation of the orbital hierarchy.

The ``test_heirarchical_string`` sub-routine validates the ``parse_string`` routine
against reference hierarchical labels, checking that the tree structure encoded in the
string maps to the correct nested orbital elements. The module is designed to be extended
with ``test_heirarchical_setup`` (currently commented out), which would call the full
``set_hierarchical`` setup routine and verify that sink particles are placed at the
correct positions and with the correct velocities for a three-body system.

Physical & Mathematical Description
------------------------------------

A hierarchical multiple system is described by a tree of nested Keplerian orbits. At the
lowest level each pair of bodies has a semi-major axis, eccentricity, inclination, and
argument of pericentre that fully specify the relative orbit. The string parser test
checks that the integer labels in the hierarchical string are correctly mapped to orbital
element arrays, with no physical computation involved. The tolerance on the string
comparison is exact (character-by-character equality).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_hierarchical.f90
