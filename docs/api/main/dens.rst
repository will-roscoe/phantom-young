.. phantom-doc: hand-written

dens
====

Overview
--------

The ``densityforce`` module contains the core density-iteration loop
``densityiterate``, which is the computational heart of the SPH algorithm in
Phantom. Its primary responsibility is to compute the SPH density estimate for
every active particle by iterating the smoothing length :math:`h` until the
density and smoothing length are mutually consistent. This iteration is
necessary because the number of neighbours — and hence the density — depends on
:math:`h`, which in turn depends on the density.

Neighbour finding is delegated to the k-d tree module: ``densityiterate`` calls
the tree walk to obtain a neighbour list for each particle, then accumulates the
density sum, the divergence and curl of the velocity field (stored in
``divcurlv``), the divergence and curl of the magnetic field (stored in
``divcurlB`` for MHD), and the grad-h correction term :math:`\Omega_i`. The
Newton-Raphson loop over :math:`h` converges in typically two to three
iterations per particle per timestep.

The module also provides ``get_density_at_pos``, which computes the SPH density
at an arbitrary position in space without storing the result in the particle
arrays. This is used by setup routines and diagnostic tools that need a density
estimate at a specific location without modifying the simulation state.

Physical & Mathematical Description
------------------------------------

The SPH density estimate for particle :math:`i` is

.. math::

   \rho_i = \sum_j m_j\,W(|\mathbf{r}_i - \mathbf{r}_j|,\,h_i),

where the sum runs over all neighbours :math:`j` within the support radius
:math:`2h_i` (or :math:`3h_i` for the quintic kernel) :cite:`price12`. The
smoothing length is constrained by the fixed-mass condition

.. math::

   h_i = h_\mathrm{fact} \left(\frac{m_i}{\rho_i}\right)^{1/3}

in three dimensions, which can be rewritten as the implicit equation
:math:`f(h_i) = 0` where

.. math::

   f(h_i) = h_i^3 \rho_i - h_\mathrm{fact}^3\,m_i = 0.

This is solved by Newton-Raphson iteration :cite:`price12`:

.. math::

   h_i^{(n+1)} = h_i^{(n)} - \frac{f(h_i^{(n)})}{f'(h_i^{(n)})}.

The derivative :math:`f'` introduces the grad-h correction factor

.. math::

   \Omega_i = 1 - \frac{\partial h_i}{\partial \rho_i}
              \sum_j m_j \frac{\partial W(r_{ij}, h_i)}{\partial h_i},

which modifies both the momentum and energy equations to ensure exact
conservation in the presence of variable smoothing lengths :cite:`price12`. The
k-d tree provides the neighbour list for the summation in
:math:`O(N_\mathrm{neigh}\log N)` time, making the total cost of
``densityiterate`` :math:`O(N\log N)` per timestep.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/dens.F90
