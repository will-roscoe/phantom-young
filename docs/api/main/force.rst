.. phantom-doc: hand-written

force
=====

Overview
--------

The ``forces`` module is the second major computational kernel of Phantom,
responsible for computing the accelerations and time derivatives of the thermal
and magnetic state for all SPH particles. It is called by the derivative
evaluation routine in ``deriv.f90`` after ``densityiterate`` has provided
up-to-date densities, smoothing lengths, and grad-h corrections. The module
integrates hydrodynamic pressure gradients, artificial viscosity
:cite:`price12`, artificial thermal conductivity :cite:`pricefederrath10`, MHD
Lorentz forces and resistivity :cite:`pricemonaghan04a`, dust-gas drag (Laibe
& Price 2012a,b), and radiation-pressure coupling into a single neighbour loop
for efficiency.

The implementation follows the symmetric SPH formulation in which both
:math:`W_{ij}(h_i)` and :math:`W_{ij}(h_j)` contribute to each pairwise
force, and the grad-h corrections :math:`\Omega_i` and :math:`\Omega_j`
appear explicitly in the pressure and Lorentz force terms. This symmetry
guarantees exact conservation of linear and angular momentum to machine
precision. The MHD divergence-cleaning terms follow the hyperbolic cleaning
scheme of :cite:`triccoprice12`, which advects divergence errors out of the
domain at a fast signal speed without introducing a global elliptic solve.

Physical & Mathematical Description
------------------------------------

The SPH momentum equation for particle :math:`i` is :cite:`price12`

.. math::

   \frac{\mathrm{d}\mathbf{v}_i}{\mathrm{d}t} =
   -\sum_j m_j \left[
     \frac{P_i}{\Omega_i \rho_i^2}\,\nabla_i W_{ij}(h_i)
     + \frac{P_j}{\Omega_j \rho_j^2}\,\nabla_i W_{ij}(h_j)
     + \Pi_{ij}\,\nabla_i \bar{W}_{ij}
   \right] + \mathbf{f}^\mathrm{ext},

where :math:`P_i` is the pressure, :math:`\Omega_i` is the grad-h correction,
:math:`\Pi_{ij}` is the Monaghan (1997) artificial viscosity tensor
:cite:`price12`, and :math:`\bar{W}_{ij} = \tfrac{1}{2}[W_{ij}(h_i) +
W_{ij}(h_j)]` is the symmetrised kernel. For MHD, the Lorentz force
:math:`\mathbf{f}_L = (\nabla\times\mathbf{B})\times\mathbf{B}/\mu_0` is split
into an isotropic magnetic pressure gradient and an anisotropic magnetic tension,
so the :math:`P/\rho^2` pressure term in the above equation is replaced by the
total isotropic stress :math:`(P + B^2/2)/\rho^2`, and a magnetic tension term
is added :cite:`pricemonaghan04a`:

.. math::

   \frac{\mathrm{d}\mathbf{v}_i}{\mathrm{d}t}\bigg|_\mathrm{Lorentz}
   = \sum_j m_j \left[
     \frac{\mathbf{B}_i \mathbf{B}_i}{\Omega_i \rho_i^2}
     + \frac{\mathbf{B}_j \mathbf{B}_j}{\Omega_j \rho_j^2}
   \right] \cdot \nabla_i \bar{W}_{ij}
   - \sum_j m_j \left[
     \frac{B_i^2/2}{\Omega_i \rho_i^2}
     + \frac{B_j^2/2}{\Omega_j \rho_j^2}
   \right] \nabla_i \bar{W}_{ij},

where the first sum is the (anisotropic) tension and the second is the
(isotropic) magnetic pressure. Resistivity and divergence-cleaning contributions
are included per :cite:`triccoprice12`.

The thermal energy equation includes artificial conductivity of the form
:cite:`pricefederrath10`

.. math::

   \left.\frac{\mathrm{d}u_i}{\mathrm{d}t}\right|_\mathrm{cond}
   = \alpha_u \sum_j m_j\,
     \frac{v^\mathrm{s}_{ij}}{\bar{\rho}_{ij}}
     (u_i - u_j)\,|\nabla_i \bar{W}_{ij}|,

where :math:`v^\mathrm{s}_{ij}` is the signal speed between particles
:math:`i` and :math:`j`, :math:`\bar{\rho}_{ij} = \tfrac{1}{2}(\rho_i +
\rho_j)`, and :math:`\alpha_u` is the conductivity switch coefficient. This
term removes unphysical discontinuities in the thermal energy field that can
arise when pressure is continuous but internal energy is not, as in contact
discontinuities :cite:`pricefederrath10`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`dens` — provides density and h for all particles before force loop.
   :doc:`eos` — equation of state pressure called inside force loop.
   :doc:`cooling` — energy loss terms accumulated in force loop.
   :doc:`dust` — dust drag forces accumulated alongside gas forces.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/force.F90
