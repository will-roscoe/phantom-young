.. phantom-doc: hand-written

cons2primsolver
===============

Overview
--------

The ``cons2primsolver`` module implements the low-level numerical solver for
the general-relativistic conserved-to-primitive variable inversion used in
Phantom's GR-SPH scheme, as described in section 7 of Liptai & Price (2019).
Given the conserved variables :math:`(D, S_i, \tau)` and the spacetime metric
at a particle's location, it finds the corresponding primitive variables
:math:`(\rho, v^i, \varepsilon)` by Newton-Raphson iteration.

The two public routines are ``conservative2primitive`` (the inverse solve)
and ``primitive2conservative`` (the forward, algebraic transformation). The
module is written for an adiabatic or ideal-plus-radiation equation of state;
other EOS choices require extending the private helper ``get_u``. A note in
the source explicitly flags this limitation. The solver is used by the
higher-level ``cons2prim`` module which handles all particle loops.

Physical & Mathematical Description
------------------------------------

The root-finding problem reduces to solving for the quantity
:math:`Z \equiv \rho h W^2` given the metric determinant :math:`\sqrt{-g}`,
the conserved density :math:`D`, and the magnitude of the conserved momentum
:math:`|S|`. The Lorentz factor is then :math:`W = \sqrt{1 + S^2/Z^2}` and
the primitive density :math:`\rho = D/W`. Newton-Raphson iteration
converges in a few steps for typical relativistic velocities. The
``primitive2conservative`` direction maps :math:`(\rho, v^i, \varepsilon)
\to (D, S_i, \tau)` through the relations

.. math::

   D = \rho W \sqrt{\gamma}, \quad
   S_i = \rho h W^2 v_i \sqrt{\gamma}, \quad
   \tau = \left(\rho h W^2 - P\right)\sqrt{\gamma} - D,

where :math:`\gamma = \det(g_{ij})` is the spatial metric determinant and
:math:`h = 1 + \varepsilon + P/\rho` is the specific enthalpy.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cons2primsolver.f90
