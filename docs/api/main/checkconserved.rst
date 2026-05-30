.. phantom-doc: hand-written

checkconserved
==============

Overview
--------

The ``checkconserved`` module performs runtime monitoring of conservation
laws during a Phantom simulation. At initialisation, ``init_conservation_checks``
examines the active physics options to determine which quantities should be
conserved exactly: total energy (only for adiabatic EOS with no cooling and
all heating terms enabled), linear momentum (unless boundary particles or
external forces are present), angular momentum (unless periodic boundaries
or non-radial external forces are active), and dust mass (when the one-fluid
dust scheme is used).

At each full dump the main subroutine ``check_conservation_errors`` compares
the current values of total energy, linear momentum, angular momentum, and
dust mass against their initial values stored in ``etot_in``, ``totmom_in``,
``angtot_in``, and ``mdust_in``. When adaptive particle refinement (APR) is
active, total gas mass ``mtot`` is additionally monitored against ``mtot_in``. If the relative change exceeds a tolerance
of 10%, a warning or fatal error is issued via the ``error`` and ``fatal``
IO routines.

The module also checks MHD stability by monitoring the dimensionless
divergence cleaning metric :math:`h|\nabla \cdot \mathbf{B}|/|\mathbf{B}|`.
If this quantity exceeds 100 in the maximum or 0.1 in the mean, a warning
is issued recommending an increase in the cleaning factor. The module
exports a public flag ``get_conserv`` that is set to 1.0 after the first
set of reference values has been recorded.

Physical & Mathematical Description
------------------------------------

Conservation errors are measured as relative deviations from the initial
values:

.. math::

   \epsilon_Q = \frac{|Q(t) - Q_0|}{|Q_0|} \quad \text{for } |Q_0| > 10^{-3},

and as absolute differences otherwise. Energy conservation applies only when
the equation of state is purely adiabatic with :math:`\gamma > 1`, no
external energy sinks (cooling), and complete treatment of all dissipative
heating terms (PdV, shock, and resistive heating). The magnetic divergence
constraint is monitored via :math:`h|\nabla \cdot B|/|B|`, which should
remain well below unity for a stable MHD simulation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`evolve_massloading` — sets ``iload_factor``; conservation checks are suppressed when this is ``>= 0`` (``-DMASS_LOADING`` builds only).

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/checkconserved.f90
