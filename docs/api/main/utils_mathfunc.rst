.. phantom-doc: hand-written

utils_mathfunc
==============

Overview
--------

The ``mathfunc`` module provides a collection of mathematical special
functions used in various parts of Phantom. The functions include: modified
Bessel functions of the first and second kind of orders 0 and 1
(``bessi0_s``, ``bessi1_s``, ``bessk0_s``, ``bessk1_s``, and the combined
routine ``IK01A``), the Gegenbauer (ultraspherical) polynomials
``gegenbauer_poly``, the associated Legendre polynomials
``legendre_associated``, and a polynomial evaluation routine ``poly`` based
on Horner's method.

The Bessel function implementations use polynomial approximations valid over
appropriate ranges of the argument. The Gegenbauer and Legendre polynomial
routines use the standard three-term recurrence relations. These functions
are used in the disc structure, self-gravity, and radiation modules for
computing kernel integrals, gravitational multipole expansions, and radiation
transfer angular integrals.

Physical & Mathematical Description
------------------------------------

The modified Bessel functions :math:`I_0, I_1, K_0, K_1` arise in the
radial part of the Green's function for the 2D Laplace equation in cylindrical
coordinates and in the analytic disc surface-density profile for a thin
Keplerian disc. The Gegenbauer polynomial :math:`C_n^\alpha(x)` satisfies
the recurrence :math:`C_{n+1}^\alpha(x) = [2x(n+\alpha)C_n^\alpha(x) -
(n+2\alpha-1)C_{n-1}^\alpha(x)] / (n+1)`, and the associated Legendre
polynomial :math:`P_l^m(x)` obeys a similar three-term recurrence.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_mathfunc.f90
