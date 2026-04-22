.. phantom-doc: hand-written

cons2prim
=========

Overview
--------

The ``cons2prim`` module manages the transformation between the conserved
(evolved) variables and the primitive (physical) variables throughout the
Phantom SPH code. In the non-GR case this transformation is trivial for most
fields, but is needed for evolved quantities such as :math:`\mathbf{B}/\rho`
(which must be multiplied by the density to recover :math:`\mathbf{B}`) and
:math:`\sqrt{\epsilon_d}` (the square root of the one-fluid dust fraction).
In the GR case the transformation involves a nonlinear root-finding solve.

The module provides four public routines: ``prim2consall`` and
``prim2consi`` transform primitive to conserved variables for all or a
single particle; ``cons2primall`` inverts this transformation for all
particles; and ``cons2prim_everything`` handles the full set including
radiation variables. All routines are parallelised with OpenMP. They call
the low-level GR solver in ``cons2primsolver`` when general relativity is
active.

The module references Liptai & Price (2019) for the GR implementation and
Ballabio et al. (2018) for the one-fluid dust scheme. Both papers describe
the mathematical structure of the conserved-to-primitive mapping in their
respective contexts.

Physical & Mathematical Description
------------------------------------

In the GR case the conserved variables are the baryon number density
:math:`D = \rho_* W`, the covariant momentum density
:math:`S_i = \rho_* h W^2 v_i`, and the total energy density
:math:`\tau = \rho_* h W^2 - P - D`, where :math:`W = (1 - v^2)^{-1/2}`
is the Lorentz factor and :math:`h` the specific enthalpy. Recovering the
primitive variables :math:`(\rho, v^i, \varepsilon)` from :math:`(D, S_i,
\tau)` requires iterative solution of an implicit nonlinear system, performed
by ``cons2primsolver``. The non-GR transformation :math:`\mathbf{B} =
(\mathbf{B}/\rho) \cdot \rho` is algebraic and exact.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cons2prim.f90
