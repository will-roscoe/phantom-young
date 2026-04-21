.. phantom-doc: hand-written

energies
========

Overview
--------
The ``energies`` module computes global diagnostic quantities over all
particles at each output step. These quantities — kinetic energy, thermal
energy, magnetic energy, potential energy, radiation energy, linear momentum,
angular momentum, centre of mass, and rms Mach number — are written to the
``.ev`` (evolution) file and used for monitoring conservation properties
throughout a simulation.

The primary entry point is the ``compute_energies`` subroutine, which
performs a single parallel pass over all particles and sink particles.
Contributions from gas, dust, boundary, star, dark matter, and bulge particles
are accumulated separately where relevant, allowing per-type diagnostics.
For MHD runs the module additionally computes the volume-averaged and
maximum values of :math:`h\,|\nabla\cdot\mathbf{B}|/|\mathbf{B}|`, providing
a quantitative measure of divergence-cleaning quality.

The module maintains a two-dimensional array ``ev_data(4,0:inumev)`` where the
four rows store the sum, maximum, minimum, and mean of each quantity across all
particles. Thread-local copies of this array are reduced via an OpenMP critical
section for thread safety. MPI reduction is then applied to combine
contributions from distributed-memory processes.

Energy values are defined in code units, which are set externally and do not
appear explicitly in this module. The total energy

.. math::

   E_{\rm tot} = E_{\rm kin} + E_{\rm therm} + E_{\rm mag}
               + E_{\rm pot} + E_{\rm rad}

is a primary conservation diagnostic. Deviations from constancy over a
simulation indicate either numerical dissipation or, when open boundaries are
used, physical energy exchange with the environment.

Physical & Mathematical Description
-------------------------------------
**Kinetic energy.** For non-relativistic SPH, the kinetic energy of particle
:math:`a` is

.. math::
   :label: ekin

   \epsilon_{{\rm kin},a} = \tfrac{1}{2} m_a |\mathbf{v}_a|^2,

and the global kinetic energy is :math:`E_{\rm kin} = \sum_a \epsilon_{{\rm
kin},a}`. For general-relativistic particles the expression uses the canonical
momentum and the Lorentz factor.

**Thermal energy.** For particles with an explicit energy variable the thermal
energy is

.. math::
   :label: etherm

   \epsilon_{{\rm therm},a} = m_a\,u_a\,(1 - \epsilon_{{\rm dust},a}),

where :math:`u_a` is the specific internal energy and :math:`\epsilon_{{\rm
dust},a}` is the local dust fraction. For isothermal or polytropic equations
of state without an energy variable, the thermal energy is computed from
:math:`P/(\gamma-1)`.

**Magnetic energy.** The magnetic energy density is :math:`B^2/(8\pi)` in
Gaussian units; in Phantom's units (with :math:`\mu_0 = 4\pi`) the
particle-level contribution is

.. math::
   :label: emag

   \epsilon_{{\rm mag},a} = \tfrac{1}{2} m_a \frac{|\mathbf{B}_a|^2}{\rho_a},

where :math:`\mathbf{B}_a = \rho_a \mathbf{B}_{\rm evol,a}` and
:math:`\mathbf{B}_{\rm evol,a}` is the evolved quantity stored per particle.

**Linear momentum.** The total linear momentum is

.. math::

   \mathbf{p} = \sum_a m_a \mathbf{v}_a,\qquad
   p_{\rm tot} = |\mathbf{p}|.

**Angular momentum.** The angular momentum about the origin is

.. math::

   \mathbf{L} = \sum_a m_a\,\mathbf{r}_a \times \mathbf{v}_a,

including spin contributions from sink particles. The magnitude
:math:`L_{\rm tot} = |\mathbf{L}|` is the principal conservation diagnostic.

**Centre of mass.** The mass-weighted centre of mass position and velocity are

.. math::

   \mathbf{r}_{\rm com} = \frac{\sum_a m_a \mathbf{r}_a}{\sum_a m_a},\qquad
   \mathbf{v}_{\rm com} = \frac{\sum_a m_a \mathbf{v}_a}{\sum_a m_a}.

**Rotational energy.** When ``calc_erot`` is enabled, the rotational energy
about each Cartesian axis through the centre of mass is computed per particle
as the squared angular momentum component divided by the squared moment arm,
e.g. for the :math:`z`-axis:

.. math::

   \epsilon_{{\rm rot},z,a} = m_a\,
   \frac{(\mathbf{r}_a' \times \mathbf{v}_a)_z^2}{|\mathbf{r}_a'|_{xy}^2},

where :math:`\mathbf{r}_a' = \mathbf{r}_a - \mathbf{r}_{\rm com}` and the
subscript :math:`xy` denotes the cylindrical radius.

**MHD divergence error.** The dimensionless divergence error is

.. math::

   \varepsilon_{B,a} = \frac{h_a\,|\nabla\!\cdot\!\mathbf{B}_a|}{|\mathbf{B}_a|},

computed from the SPH divergence estimate stored in ``divcurlB``.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/energies.f90
