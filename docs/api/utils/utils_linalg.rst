.. phantom-doc: hand-written

utils_linalg
============

Overview
--------

``utils_linalg`` (module ``linalg``) provides general linear algebra utilities including matrix inversion by Gauss-Jordan elimination (``inverse``) and an iterative BiCGSTAB (Biconjugate Gradient Stabilised) solver for large sparse linear systems (``solve_bicgstab``). The BiCGSTAB implementation follows van der Horst (1992, SIAM J. Sci. Stat. Comput. 13, 1384).

The ``inverse`` function computes the inverse of a square matrix using Gauss-Jordan elimination with partial pivoting, suitable for small dense matrices. The ``solve_bicgstab`` routine solves :math:`A\mathbf{x} = \mathbf{b}` iteratively without storing the matrix explicitly, requiring only a matrix-vector product function passed via the ``get_Ax_interface`` abstract interface.

These routines are used in Phantom's GR and radiation modules for solving implicit systems arising from the operator splitting scheme.

Physical & Mathematical Description
------------------------------------

The BiCGSTAB algorithm solves :math:`A\mathbf{x} = \mathbf{b}` with convergence rate independent of the matrix condition number when a suitable preconditioner is applied. The iteration generates a sequence of residuals :math:`\mathbf{r}_k = \mathbf{b} - A\mathbf{x}_k` with :math:`\|\mathbf{r}_k\| \to 0`, using two search directions per iteration (Bi-CG step + stabilisation step) and requiring two matrix-vector products per iteration.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_linalg.f90
