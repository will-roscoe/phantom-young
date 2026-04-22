.. phantom-doc: hand-written

radiation_implicit — Implicit Flux-Limited Diffusion Radiative Transfer
========================================================================

Overview
--------

The ``radiation_implicit`` module implements a backward-Euler implicit integration
scheme for radiation energy transport in the flux-limited diffusion (FLD)
approximation.  At each hydrodynamic timestep, the coupled system of radiation
energy density and gas internal energy equations is solved iteratively for all SPH
particles, with the time derivative of the specific radiation energy density
:math:`\xi` advanced implicitly to avoid the stringent explicit timestep constraint
imposed by the radiation diffusion timescale in optically thick regions.

The implementation follows the algorithm of Whitehouse, Bate & Monaghan (2005),
which integrates over the Gauss-Seidel iteration to reach the coupled
gas-radiation equilibrium at the end of each step.  The flux limiter of Levermore
& Pomraning is applied to ensure that the radiation flux cannot exceed the
free-streaming limit, and the full Eddington tensor is tracked to account for
anisotropic radiation pressure.  The module additionally supports the extended
diffuse ISM physics of Bate & Keto (2015), including gas–dust thermal coupling,
cosmic ray heating, molecular line cooling, H\ :sub:`2` formation heating, and
photoelectric heating, though several of these channels are currently disabled by
compile-time flags.

The main entry point is ``do_radiation_implicit``, which drives an outer substep
loop and calls ``do_radiation_onestep`` for each substep.  Each call to
``do_radiation_onestep`` builds a compacted neighbour list, fills geometric and
thermodynamic coefficient arrays, and then iterates the coupled solver until the
relative errors in both :math:`\xi` and the gas specific internal energy :math:`u`
fall below the tolerance ``tol_rad``, or until the maximum iteration count
``itsmax_rad`` is reached.  Successive over-relaxation is applied adaptively, with
the relaxation parameter halved when a limit cycle is detected.

The module is parallelised with OpenMP throughout.  Neighbour-list construction uses
the k-d tree infrastructure in ``neighkdtree``, while the compacted storage format
used by ``implicit`` minimises cache misses during the per-particle flux and
diffusion sweeps.

Physical & Mathematical Description
-------------------------------------

**Flux-limited diffusion approximation.**  In the FLD approximation the radiation
flux is expressed as a diffusion of the radiation energy density
:math:`E = \rho\xi`:

.. math::

   \mathbf{F} = -\frac{c\,\lambda}{\kappa\rho}\,\nabla E

where :math:`c` is the speed of light, :math:`\kappa` is the opacity
(cm\ :sup:`2` g\ :sup:`-1`), :math:`\rho` is the gas density, and :math:`\lambda`
is the flux limiter.  The Levermore–Pomraning flux limiter is

.. math::

   \lambda(R) = \frac{2 + R}{6 + 3R + R^2}

where the dimensionless radiation-pressure ratio is

.. math::

   R = \frac{|\nabla E|}{\kappa\rho\,E}.

In the optically thick (diffusion) limit :math:`R \to 0` and
:math:`\lambda \to 1/3`; in the free-streaming limit :math:`R \to \infty` and
:math:`\lambda \to 1/R`.

**Eddington tensor.**  The scalar Eddington factor is

.. math::

   f_{\rm Edd} = \lambda + \lambda^2 R^2,

and the full Eddington tensor used for the radiation-pressure work term is

.. math::

   \mathsf{P}^{\rm rad}_{ij} = \frac{1-f_{\rm Edd}}{2}\,\delta_{ij}
   + \frac{3f_{\rm Edd}-1}{2}\,\hat{n}_i\hat{n}_j

where :math:`\hat{\mathbf{n}} = -\nabla E / |\nabla E|` (equation 10 of
Whitehouse & Bate 2004).

**Coupled evolution equations.**  The radiation energy density and gas internal
energy are coupled via emission and absorption:

.. math::

   \frac{\partial E}{\partial t}
   = \nabla\cdot\!\left(\frac{c\lambda}{\kappa\rho}\nabla E\right)
   - \nabla\mathbf{v}:\mathsf{P}^{\rm rad}
   + c\kappa\rho\!\left(a_{\rm rad}T_{\rm gas}^4 - E\right),

.. math::

   \frac{\partial u}{\partial t}
   = -\frac{1}{\rho}\mathbf{P}_{\rm gas}:\nabla\mathbf{v}
   - c\kappa\!\left(a_{\rm rad}T_{\rm gas}^4 - E\right)

(equations 22 of Whitehouse, Bate & Monaghan 2005), where :math:`a_{\rm rad}` is
the radiation constant and :math:`T_{\rm gas} = u / c_v` is the gas temperature.

**Backward-Euler discretisation.**  Differencing these equations at the new time
level yields a system in which the updated :math:`u` satisfies a reduced quartic:

.. math::

   u^{n+1\,4} + \frac{u_1}{\gamma_{\rm val}}\,u^{n+1} + \frac{u_0}{\gamma_{\rm val}} = 0

where the coefficients :math:`\beta`, :math:`\chi`, :math:`\gamma_{\rm val}` encode
the time step, opacity, diffusion denominator, radiation pressure, and heat
capacity.  This quartic is solved numerically by ``solve_quartic``.  The new
radiation energy density is then obtained algebraically from :math:`u^{n+1}`.

**Convergence criterion.**  The iterative solve is declared converged when

.. math::

   \max_i \frac{|E_i^{(k)} - E_i^{(k-1)}|}{E_i^{(k)}} \leq \epsilon_{\rm rad}
   \quad\text{and}\quad
   \max_i \frac{|u_i^{(k)} - u_i^{(k-1)}|}{u_i^{(k)}} \leq \epsilon_{\rm rad}

where :math:`\epsilon_{\rm rad}` = ``tol_rad`` (default :math:`10^{-6}`) and the
maximum iteration count is ``itsmax_rad`` (default 250).

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Symbol
     - Definition
   * - :math:`\xi`
     - Specific radiation energy density (radiation energy per unit mass, ``iradxi``)
   * - :math:`E = \rho\xi`
     - Radiation energy density (energy per unit volume)
   * - :math:`u`
     - Specific gas internal energy (``vxyzu(4,:)``)
   * - :math:`c_v`
     - Specific heat at constant volume (``icv``)
   * - :math:`\kappa`
     - Rosseland mean opacity (``ikappa``)
   * - :math:`\lambda`
     - Flux limiter (``ilambda``)
   * - :math:`f_{\rm Edd}`
     - Eddington factor (``iedd``)
   * - :math:`a_{\rm rad}`
     - Radiation constant (:math:`7.565\times 10^{-15}` erg cm\ :sup:`-3` K\ :sup:`-4`)
   * - :math:`R`
     - Dimensionless radiation-pressure ratio

References
----------

The implicit FLD scheme follows:

- Whitehouse, S. C., Bate, M. R. & Monaghan, J. J. 2005, MNRAS, 364, 1367 — primary
  reference for the backward-Euler implicit solver and quartic gas-temperature equation
- Whitehouse, S. C. & Bate, M. R. 2004, MNRAS, 353, 1078 — Eddington tensor formalism
  and flux-limiter definitions used in this module
- Bate, M. R. & Keto, E. R. 2015, MNRAS, 449, 2643 — extended diffuse ISM physics
  (gas–dust coupling, cosmic rays, H\ :sub:`2` formation, photoelectric heating)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/radiation_implicit.f90
