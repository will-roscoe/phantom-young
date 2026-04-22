.. phantom-doc: hand-written

H2regions
=========

Overview
--------

The ``HIIRegion`` module models the expansion of HII regions driven by
photoionisation from massive stars embedded in the SPH particle distribution.
The algorithm is based on the Hopkins et al. (2012) feedback model as adapted
for star-cluster formation simulations by Fujii et al. (2021) and
re-implemented in Phantom by Yann Bernard. Each massive star (sink particle
with mass above a threshold ``Mmin``) acts as a source of ionising UV
photons, creating a Stromgren sphere of ionised gas around it.

The public subroutine ``HII_feedback`` loops over all massive sink sources
and, for each source, determines which SPH particles lie within its Stromgren
radius using the k-d tree neighbour search. Particles within the ionised
volume have their temperature set to :math:`T_\text{ion} = 10^4` K and
receive a radiation pressure kick proportional to the UV flux. The ionisation
rate as a function of stellar mass is taken from a polynomial fit to the
tables of Fujii et al. (2021).

The module supports individual timesteps: the ionisation rates are only
updated every ``HIIuprate = 8`` individual timestep bins to reduce cost. The
maximum HII region radius is capped at ``Rmax`` parsecs to prevent artificial
expansion beyond the simulation domain.

Physical & Mathematical Description
------------------------------------

The Stromgren radius for a source emitting :math:`Q_\text{ion}` ionising
photons per second into a uniform medium of number density :math:`n` is

.. math::

   R_S = \left(\frac{3 Q_\text{ion}}{4\pi \alpha_B n^2}\right)^{1/3},

where :math:`\alpha_B = 2.7 \times 10^{-13}\ \text{cm}^3\ \text{s}^{-1}`
is the case-B recombination coefficient at :math:`T = 10^4` K. The
ionisation rate :math:`Q_\text{ion}` is computed from the sink particle mass
using a sixth-order polynomial fit to tabulated values:

.. math::

   \log Q_\text{ion} = a + b\log M + c(\log M)^2 + d(\log M)^3
   + e(\log M)^4 + f(\log M)^5.

Ionised particles also receive a radiation pressure acceleration
:math:`a_\text{rad} = \kappa_d F / c`, where :math:`F` is the UV flux and
:math:`\kappa_d` is the dust opacity.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/H2regions.f90
