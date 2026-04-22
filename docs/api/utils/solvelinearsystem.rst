.. phantom-doc: hand-written

solvelinearsystem
=================

Overview
--------

``solvelinearsystem`` implements LU decomposition with partial pivoting and back-substitution to solve a general :math:`n \times n` linear system :math:`A \mathbf{x} = \mathbf{b}`. The module uses reduced storage (storing the LU factors in-place) and supports systems of arbitrary size.

The algorithm follows the standard Gaussian elimination with partial pivoting approach, interchanging rows to select the largest pivot element for numerical stability. The factored form is used to solve for the right-hand side vector by forward and back substitution. This module is used by ``analysis_dustydisc`` for multi-component dust fitting.

An example solution from the module source demonstrates the method for a 5x5 system with a known analytic solution.

Physical & Mathematical Description
------------------------------------

The :math:`A\mathbf{x} = \mathbf{b}` system is solved via LU factorisation: :math:`A = LU` where :math:`L` is lower triangular with unit diagonal and :math:`U` is upper triangular. Forward substitution gives :math:`L\mathbf{y} = \mathbf{b}` and back-substitution gives :math:`U\mathbf{x} = \mathbf{y}`. Partial pivoting interchanges rows so that :math:`|u_{kk}| \geq |u_{ik}|` for all :math:`i > k`, ensuring numerical stability.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/solvelinearsystem.f90
