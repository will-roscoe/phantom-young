.. phantom-doc: hand-written

set_dust
========

Overview
--------

The ``set_dust`` module initialises the dust component of one-fluid
(dust-as-mixture) and multi-fluid (dust-as-separate-species) simulations
in Phantom.  For one-fluid dust the ``set_dustfrac`` routine assigns the
initial dust-to-gas ratio :math:`\varepsilon = \rho_d / \rho` to every
SPH particle; for multi-species dust the ``set_dustbinfrac`` routine
distributes the total dust fraction across a grain-size spectrum such that
the fractions sum to the specified total :math:`\varepsilon_\mathrm{tot}`.

The module is called after the particle positions and gas densities have
been set, so it operates only on the dust-fraction arrays without
modifying positions or velocities.  It is compatible with both the
terminal-velocity approximation and the full two-fluid SPH formulation
described in :cite:`price12`.

Physical & Mathematical Description
------------------------------------

In the one-fluid (or ``dustfrac``) approach the mixture density is
:math:`\rho = \rho_g + \rho_d` and the dust fraction is
:math:`\varepsilon = \rho_d / \rho`.  The gas density is then
:math:`\rho_g = (1 - \varepsilon)\rho`.  The stopping time for a grain
of size :math:`s` in the Epstein drag regime is

.. math::

   t_s = \frac{\rho_\mathrm{grain}\,s}{\rho_g\,c_s},

where :math:`\rho_\mathrm{grain}` is the intrinsic grain density and
:math:`c_s` is the gas sound speed.  For multi-species dust with
:math:`N_\mathrm{dust}` grain-size bins the fraction in bin :math:`k` is

.. math::

   \varepsilon_k = \varepsilon_\mathrm{tot} \cdot w_k,\qquad
   \sum_k w_k = 1,

where the weights :math:`w_k` can follow a power-law grain-size
distribution :math:`dn/ds \propto s^{-q}`.  The ``set_dustbinfrac``
routine evaluates these weights and assigns them to each particle's
dust-fraction array.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_dust.f90
