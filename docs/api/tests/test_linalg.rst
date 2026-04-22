.. phantom-doc: hand-written

test_linalg
===========

Overview
--------

The ``test_linalg`` module (Fortran module ``testlinalg``) tests the linear algebra
routines in Phantom's ``linalg`` and ``vectorutils`` modules. The primary sub-test
``test_matrix_inversion`` exercises the BiCGSTAB iterative solver ``solve_bicgstab`` and
the direct 3×3 matrix inversion ``matrixinvert3D``. A known 3×3 system with exact rational
solution is solved by both methods, and the results are compared to the exact answer with
a relative tolerance of :math:`10^{-6}`.

The BiCGSTAB test verifies convergence from an initial guess of zero for a diagonally
dominant but non-symmetric coefficient matrix, checking both the solution vector and the
residual :math:`\|\mathbf{A}\mathbf{x} - \mathbf{b}\|`. The direct inversion test uses
the same matrix to compute :math:`\mathbf{A}^{-1}` via LU decomposition (implicit in
``matrixinvert3D``) and then applies it to the right-hand side, checking that
:math:`\mathbf{x} = \mathbf{A}^{-1}\mathbf{b}` matches the BiCGSTAB result.

Physical & Mathematical Description
------------------------------------

The test coefficient matrix is
:math:`A = \begin{pmatrix} 10 & 2 & 3 \\ 4 & -10 & 2 \\ 2 & 1 & -10 \end{pmatrix}`
with right-hand side :math:`\mathbf{b} = (5, 0, 1)^\top`. The exact solution is
:math:`\mathbf{x} = A^{-1}\mathbf{b}`. Both the BiCGSTAB solver and the direct inversion
must reproduce :math:`\mathbf{x}` to within a relative tolerance of :math:`10^{-6}`,
which is appropriate for single-precision arithmetic.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_linalg.f90
