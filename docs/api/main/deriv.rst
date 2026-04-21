.. phantom-doc: hand-written

deriv
=====

Overview
--------
The ``deriv`` module is the top-level wrapper that orchestrates the computation
of all SPH derivative quantities for a single call to the derivative evaluator.
It sits at the heart of the Phantom time-stepping loop, coordinating the sequence
of operations that transform the current particle state into time derivatives
suitable for integration.

On each invocation the module (1) builds or reuses the neighbour-finding k-d tree,
(2) computes particle densities and smoothing-length gradients via iterative
density summation, (3) converts conserved variables to primitive variables, (4)
evaluates all SPH forces (pressure, viscosity, magnetic, radiation, dust), and (5)
determines the new timestep estimate from the Courant and force constraints. The
``icall`` flag allows the caller to skip the expensive tree-build and density
iteration when only a force update is needed (e.g. during leapfrog corrector
iterations).

The module exposes three public entry points: ``derivs`` performs the full
calculation; ``get_derivs_global`` is a convenience wrapper that operates on
the global shared particle arrays without requiring the caller to manage the
argument list explicitly; and ``get_density_global`` allows an isolated density
computation, useful during initialisation or diagnostic passes.

The separation between density and force evaluations reflects the two-pass
structure inherent in variable-smoothing-length SPH: density must be converged
before the pressure and viscous terms can be computed accurately. The
``densityiterate`` subroutine in ``densityforce`` handles the nested density
iteration, after which the full force is evaluated by ``force`` in the
``forces`` module.

Physical & Mathematical Description
-------------------------------------
The derivative evaluation implements the SPH equations of motion in the form
:cite:`price12`

.. math::
   :label: eom_velocity

   \frac{d\mathbf{v}_a}{dt} = -\sum_b m_b \left[
     \frac{P_a}{\Omega_a \rho_a^2} \nabla_a W_{ab}(h_a)
   + \frac{P_b}{\Omega_b \rho_b^2} \nabla_a W_{ab}(h_b)
   + \Pi_{ab} \hat{\mathbf{r}}_{ab}
   \right] + \mathbf{f}_a^{\rm ext},

where :math:`P_a`, :math:`\rho_a`, and :math:`h_a` are the pressure, density,
and smoothing length of particle :math:`a`; :math:`W_{ab}(h)` is the kernel
evaluated at the separation :math:`|\mathbf{r}_a - \mathbf{r}_b|` with
smoothing length :math:`h`; :math:`\Pi_{ab}` is the artificial viscosity tensor;
and :math:`\mathbf{f}_a^{\rm ext}` denotes external forces. The :math:`\Omega`
factors are the variable smoothing-length correction terms

.. math::

   \Omega_a = 1 - \frac{\partial h_a}{\partial \rho_a}
   \sum_b m_b \frac{\partial W_{ab}(h_a)}{\partial h_a},

which arise from the variational derivation and ensure both momentum and
energy conservation.

The thermal energy (or entropy) equation is coupled to the velocity update
and includes contributions from the viscous dissipation term and, when active,
from explicit radiation transport or dust-gas coupling.

The density itself is obtained by the standard SPH summation

.. math::

   \rho_a = \sum_b m_b W_{ab}(h_a),

with the smoothing length :math:`h_a` determined self-consistently from

.. math::

   \frac{4}{3}\pi h_a^3 \rho_a = \eta \bar{m},

where :math:`\eta` is a dimensionless parameter (``hfact``) and :math:`\bar{m}`
is the characteristic particle mass.

References
----------
See :cite:`price12` for a comprehensive review of the SPH and SPMHD algorithms
implemented in Phantom.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/deriv.f90
