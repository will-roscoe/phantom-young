.. phantom-doc: hand-written

set_streamer
============

Overview
--------

The ``set_streamer`` module sets up the initial conditions for a tidal
disruption event (TDE) simulation.  A star on a parabolic orbit about a
massive black hole is disrupted at pericentre, and the resulting debris
stream is modelled as an SPH particle distribution with the orbital energy
and angular momentum distribution derived from a disrupted stellar model.
The module places SPH particles along the debris stream trajectory so that
the simulation begins after disruption, avoiding the expensive integration
through the orbital approach.

The stream is initialised on a parabolic trajectory with a spread in
orbital energies and angular momenta consistent with the tidal disruption
of a star of mass :math:`M_\star` and radius :math:`R_\star` by a black
hole of mass :math:`M_\mathrm{BH}`.  The spread in specific orbital
energy determines the fallback timescale and hence the characteristic
:math:`\dot{M} \propto t^{-5/3}` signature.

Physical & Mathematical Description
------------------------------------

At the tidal disruption radius the black hole exerts a differential tidal
force across the stellar diameter.  The tidal radius is

.. math::

   r_t = R_\star\left(\frac{M_\mathrm{BH}}{M_\star}\right)^{1/3},

and the penetration parameter :math:`\beta = r_t / r_\mathrm{peri}`
quantifies how deeply the star penetrates inside :math:`r_t`.  Tidal
disruption occurs when :math:`\beta \gtrsim 1`.

The specific orbital energy distribution of the stream is approximately
uniform between :math:`-\Delta\varepsilon` and :math:`+\Delta\varepsilon`,
where

.. math::

   \Delta\varepsilon = \frac{G M_\mathrm{BH} R_\star}{r_t^2}.

Material with :math:`\varepsilon < 0` falls back to the black hole on a
timescale :math:`t_\mathrm{fallback} \propto |\varepsilon|^{-3/2}`,
producing the observed mass return rate
:math:`\dot{M} \propto t^{-5/3}`.  The stream particles are placed along
the orbital trajectories corresponding to each energy slice, with masses
set by the stellar density profile of the disrupted star.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_streamer.f90
