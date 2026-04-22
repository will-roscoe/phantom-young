.. phantom-doc: hand-written

inverse4x4
==========

Overview
--------

The ``inverse4x4`` module computes the inverse of a :math:`4 \times 4`
matrix by explicit cofactor (Cramer's rule) expansion. Its sole public
routine ``inv4x4`` takes the input matrix ``A``, returns the inverse matrix
``B`` and the determinant ``det``. If the determinant is smaller than
``tiny(0.)`` in magnitude, the routine sets ``B = 0`` and returns without
attempting the inversion, guarding against division by zero.

This module is used in the GR part of Phantom primarily to invert the
covariant spacetime metric tensor :math:`g_{\mu\nu}` (a :math:`4 \times 4`
symmetric matrix) to obtain the contravariant metric :math:`g^{\mu\nu}`,
which is needed for raising indices in the GR-SPH equations. The explicit
cofactor expansion is used rather than a general LU solver because the
:math:`4 \times 4` case has a fixed, compact analytic form that is faster to
evaluate for the many particles processed in an SPH simulation.

Physical & Mathematical Description
------------------------------------

For a :math:`4 \times 4` matrix :math:`A`, the inverse via Cramer's rule is

.. math::

   B_{ij} = \frac{C_{ji}}{\det A},

where :math:`C_{ji}` is the :math:`(j,i)` cofactor (the signed
:math:`3 \times 3` minor). The determinant is computed first as a sum of
:math:`24` products of four matrix elements; the cofactor matrix is then
computed explicitly from the :math:`24` possible products, and the inverse
is :math:`B = C^T / \det A`. The pure attribute on ``inv4x4`` allows it to
be called from within OpenMP parallel regions and elemental contexts.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/inverse4x4.f90
