.. phantom-doc: hand-written

growth_smol — Smoluchowski Coagulation Solver Interface
=========================================================

Overview
--------

The ``growth_smol`` module is a thin interface layer that couples the Phantom
SPH code to an external Smoluchowski coagulation library.  Rather than tracking
the evolution of individual dust super-particles, this approach discretises the
grain-size distribution into a set of logarithmically spaced mass bins and
advances the bin populations forward in time by numerically integrating the
Smoluchowski coagulation equation.

The single public routine, ``grain_growth_smol``, receives the per-particle dust
state in Phantom's internal code units — dust fractions, grain sizes, intrinsic
densities, total density, and timestep — converts these quantities to CGS, and
passes them to the external ``grain_growth`` routine from the linked Smoluchowski
library (module ``smol2other``).  After the library call the updated dust
densities are converted back to dust fractions and returned to the caller.

This design isolates all unit-conversion and variable-repackaging from the
physical solver, making it straightforward to substitute alternative coagulation
kernels or solver implementations.  The module is compiled only when the Makefile
links against the Smoluchowski library, as indicated by a dedicated Makefile
rule.  No additional runtime parameters are needed beyond those controlling the
grain size grid, which are managed by the library itself.

Physical & Mathematical Description
-------------------------------------

**Smoluchowski coagulation equation.**  The continuous Smoluchowski equation
governing the time evolution of the grain mass distribution :math:`n(m,t)` (grain
number per unit volume per unit mass) is

.. math::

   \frac{\partial n(m,t)}{\partial t}
   = \frac{1}{2}\int_0^m K(m',m-m')\,n(m',t)\,n(m-m',t)\,\mathrm{d}m'
   - n(m,t)\int_0^\infty K(m,m')\,n(m',t)\,\mathrm{d}m',

where :math:`K(m_i, m_j)` is the coagulation kernel describing the rate at
which grains of mass :math:`m_i` and :math:`m_j` collide and merge.  The first
integral represents the gain of mass-:math:`m` grains from collisions of smaller
grains; the second represents their loss due to collisions with all other grains.

**Discretised bin formulation.**  In practice the mass axis is discretised into
:math:`N_\mathrm{bins}` bins with representative masses
:math:`m_1 < m_2 < \cdots < m_{N_\mathrm{bins}}` (typically spaced
logarithmically so that each octave contains a fixed number of bins).  The
number density in bin :math:`i` evolves as

.. math::

   \frac{\mathrm{d}n_i}{\mathrm{d}t}
   = \frac{1}{2}\sum_{j+k \to i} K_{jk}\,n_j\,n_k
   - n_i \sum_j K_{ij}\,n_j,

where the gain sum is taken over all pairs :math:`(j,k)` whose combined mass
maps into bin :math:`i` under the chosen mass-redistribution scheme.

**Unit conversions performed by this module.**  The routine converts:

- dust fractions :math:`\epsilon_i` and total density :math:`\rho` to dust
  densities :math:`\rho_{d,i} = \epsilon_i \rho \cdot \rho_\mathrm{unit}` in
  :math:`\mathrm{g\,cm}^{-3}`;
- grain radii :math:`s_i` and intrinsic densities :math:`\rho_{\mathrm{grain},i}`
  to grain masses
  :math:`m_i = (4\pi/3)\,s_i^3\,\rho_{\mathrm{grain},i} \cdot m_\mathrm{unit}`
  in :math:`\mathrm{g}`;
- on return, updated dust densities are divided by the total density to recover
  dust fractions.

References
----------

Smoluchowski, M. (1916), Phys. Z. 17, 557 [not yet in phantom.bib]

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/growth_smol.f90
