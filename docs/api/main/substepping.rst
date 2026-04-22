.. phantom-doc: hand-written

substepping — RESPA Sub-Stepping Algorithm
==========================================

Overview
--------

The ``substepping`` module implements the Reference System Propagator Algorithm
(RESPA) for multiple-time-scale integration in Phantom.  The fundamental idea,
due to Tuckerman, Berne & Martyna (1992) following Verlet (1967), is to separate
the total force into a *slow* component — long-range gravity, external potentials,
and sink-particle interactions — and a *fast* component — SPH pressure and
viscosity forces — which are sub-stepped at a shorter time-interval
:math:`\Delta t_{\rm ext}` within each global SPH step :math:`\Delta t_{\rm SPH}`.
This avoids the inefficiency of advancing the entire system at the rate dictated by
the most restrictive force.

Four entry points are provided.  ``substep_sph`` handles the trivial case of pure
hydrodynamics without external forces, performing a simple drift of particle
positions.  ``substep_sph_gr`` handles the equivalent case in general relativity,
iterating the conservative-to-primitive solver until the position update converges.
``substep_gr`` and ``substep`` are the full RESPA loops for GR and Newtonian physics
respectively, each executing a sequence of kick–drift–force–kick inner steps over
sink and gas particles.  The Newtonian ``substep`` supports both a second-order
leapfrog scheme (``use_fourthorder = .false.``) and a higher-order
Forest–Suzuki–Integrated (FSI) scheme (``use_fourthorder = .true.``) using the
Omelyan extrapolation method; the FSI coefficients ``ck`` and ``dk`` are provided
by the ``ptmass`` module.

Accretion is tested at the end of each sub-step, and if particles are accreted a
force recomputation is triggered to maintain conservation of angular momentum.
Sub-group integration for tight sink binaries (``use_regnbody``) is invoked within
the drift step via ``subgroup_evolve``.

Physical & Mathematical Description
-------------------------------------

**RESPA decomposition.**  The Hamiltonian is split as
:math:`H = H_{\rm fast} + H_{\rm slow}`, where :math:`H_{\rm fast}` contains SPH
pressure and viscosity and :math:`H_{\rm slow}` contains sink-particle and external
forces.  Over one global step :math:`\Delta t_{\rm SPH}`, the slow forces are
sub-stepped :math:`n_s` times at :math:`\Delta t_{\rm ext} = \Delta t_{\rm SPH} /
n_s`, with :math:`n_s` determined adaptively each step.

**Second-order leapfrog (Verlet) sub-step.**  One sub-step of duration
:math:`\Delta t` advances the system as

.. math::

   \mathbf{p}^{n+1/2} &= \mathbf{p}^n + \tfrac{1}{2}\Delta t\,\mathbf{F}^n \\
   \mathbf{x}^{n+1}   &= \mathbf{x}^n + \Delta t\,\mathbf{p}^{n+1/2}/m \\
   \mathbf{F}^{n+1}   &= \mathbf{F}(\mathbf{x}^{n+1}) \\
   \mathbf{p}^{n+1}   &= \mathbf{p}^{n+1/2} + \tfrac{1}{2}\Delta t\,\mathbf{F}^{n+1}

implemented in Phantom as two calls to ``kick`` with coefficients
:math:`d_k^{(1)} = d_k^{(2)} = 1/2` and one call to ``drift`` with
:math:`c_k^{(1)} = 1`.

**Fourth-order FSI sub-step.**  The Forest–Suzuki integration with Omelyan
extrapolation uses a three-kick / two-drift factorisation with coefficients

.. math::

   d_k = \left(\tfrac{1}{6},\; \tfrac{2}{3},\; \tfrac{1}{6}\right), \qquad
   c_k = \left(\tfrac{1}{2},\; \tfrac{1}{2}\right)

For the force at the second drift point, the Omelyan extrapolation uses the
previous-step sink force ``fsink_old`` to predict a corrected sink position,
reducing the number of full force evaluations without sacrificing fourth-order
accuracy.

**Time-step selection.**  The sub-step interval is limited by the external-force
time-step estimator returned from ``get_force`` and by the global SPH step; the
adaptive loop runs until :math:`t + \Delta t_{\rm ext} \geq t + \Delta t_{\rm SPH}`,
at which point the final sub-step is shortened to exactly fill the global step.

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Symbol
     - Definition
   * - :math:`\Delta t_{\rm SPH}`
     - Global hydrodynamics time-step (``dtsph``)
   * - :math:`\Delta t_{\rm ext}`
     - External-force / sink sub-step (``dtextforce``)
   * - :math:`n_s`
     - Number of sub-steps per global step (``nsubsteps``)
   * - :math:`d_k`
     - Kick coefficients array (``dk`` from ``ptmass`` module)
   * - :math:`c_k`
     - Drift coefficients array (``ck`` from ``ptmass`` module)
   * - :math:`\mathbf{F}`
     - Slow force (sink–sink, sink–gas gravity, external potentials)

References
----------

The RESPA algorithm implemented here follows:

- Verlet, L. 1967, Phys. Rev., 159, 98 — original Verlet integrator
- Tuckerman, M., Berne, B. J., & Martyna, G. J. 1992, J. Chem. Phys., 97, 1990 —
  RESPA multiple-time-scale integration
- Rantala, A. et al. 2020; 2023 — higher-order FSI scheme and Omelyan extrapolation
  as used for sink subgroup integration
- Chin, S. A. 2007, Phys. Rev. E, 75, 036701 — symplectic integrator coefficients

No entries from ``phantom.bib`` are directly cited by this module.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/substepping.F90
