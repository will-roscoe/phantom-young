.. phantom-doc: hand-written

quartic
=======

Overview
--------

``quartic`` provides an analytic solver for quartic polynomial equations of the form :math:`x^4 + a_3 x^3 + a_2 x^2 + a_1 x + a_0 = 0`, using Ferrari's method via a resolvent cubic. The module is referenced in Whitehouse & Bate (2004, MNRAS 353, 1078) and is used in Phantom's radiation module and equation of state solvers.

The ``quarticsolve`` routine finds the real root closest to a given previous solution ``uold``, which enables efficient time-stepping of quantities that evolve continuously (such as the radiation energy density or the internal energy in an implicit solver). The ``quarticf`` function evaluates the quartic polynomial at a given point.

An iterative bracketing and bisection approach is used to ensure robustness, with the Newton-Raphson method applied near the solution for quadratic convergence.

Physical & Mathematical Description
------------------------------------

Ferrari's method reduces the quartic :math:`x^4 + a_3 x^3 + a_2 x^2 + a_1 x + a_0 = 0` to a resolvent cubic in the auxiliary variable :math:`y`: :math:`8y^3 - 4a_2 y^2 + (2a_1 a_3 - 8a_0)y - a_1^2 + 4a_0 a_2 - a_3^2 a_0 = 0`. Given a real root :math:`y_0` of the cubic, the quartic factors into two quadratics that are solved analytically to give up to four real roots.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/quartic.f90
