.. phantom-doc: hand-written

evolve_planet
=============

Overview
--------

The ``evolveplanet`` module provides a sub-stepping integrator for an
embedded planet particle that is evolved separately from the main SPH
particle array. It is designed to couple atmospheric boil-off and accretion
physics — in particular the model of Rogers et al. (2024) — to the Phantom
SPH time integration by computing the planet's mass-loss rate and accretion
rate as a function of the pressure and Bondi radius at the planet's location.

The public subroutine ``evolve_planet`` accepts the pressure at the Bondi
radius ``pbondi`` and the Bondi radius ``rbondi`` and returns the accretion
rate ``mdotacc`` and wind mass-loss rate ``mdotwind`` in code units. In the
current implementation the accretion rate is set to zero and the wind rate is
a fixed fraction of a Jupiter mass per year, representing a placeholder for
the full boil-off model.

Physical & Mathematical Description
------------------------------------

The Bondi radius of a planet of mass :math:`M_p` embedded in a gas disc with
local sound speed :math:`c_s` is :math:`r_B = GM_p / c_s^2`. The boil-off
model computes the atmospheric mass-loss rate from the pressure at this
radius and the planetary luminosity. For the current implementation the wind
mass-loss rate is prescribed as :math:`\dot{M}_\text{wind} = 10^{-2}
M_\text{Jup}/\text{yr}`, which is converted to code units using the
``units`` module.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/evolve_planet.f90
