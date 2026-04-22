.. phantom-doc: hand-written

cooling_gammie
==============

Overview
--------

The ``cooling_gammie`` module implements the beta-cooling prescription
introduced by Gammie (2001) for studying the gravitational instability and
fragmentation of protoplanetary and protostellar discs. In this prescription
the gas cools on a timescale that is a fixed multiple of the local Keplerian
orbital period, making the formulation both physically motivated and
computationally inexpensive.

The single subroutine ``cooling_Gammie_explicit`` computes the explicit
cooling contribution to :math:`\dot{u}` for a given SPH particle. It
determines the Keplerian angular velocity :math:`\Omega` at the particle's
position relative to the primary mass — taken from the nearest sink particle if
one is present, or from the ``externalforces`` parameter ``mass1`` otherwise —
and applies the beta-cooling formula. The module is activated by setting
``icooling = 3`` in the Phantom input file.

Because the cooling timescale is tied to the orbital frequency rather than to
the thermodynamic state of the gas, beta cooling is most applicable to
geometrically thin, Keplerian discs where the disc self-gravity parameter
:math:`Q \sim 1`. It is widely used as a benchmark for disc fragmentation
studies because the critical cooling rate :math:`\beta_\mathrm{crit} \approx 3`
for fragmentation (for :math:`\gamma = 5/3`) is well established by linear
analysis (Gammie 2001) and confirmed numerically.

The sole runtime parameter is ``beta_cool`` (:math:`\beta`, default 3), which
must satisfy :math:`\beta \geq 1`.

Physical & Mathematical Description
-------------------------------------

The Gammie (2001) beta-cooling law couples the cooling timescale directly to
the local Keplerian angular velocity:

.. math::

   t_\mathrm{cool} = \frac{\beta}{\Omega(r)},

where :math:`\Omega(r) = \sqrt{M_\star}\,r^{-3/2}` (in code units with
:math:`G = 1`) is the Keplerian angular velocity at cylindrical radius
:math:`r` and :math:`M_\star` is the central mass.

The resulting cooling rate per unit mass is

.. math::

   \left.\frac{\mathrm{d}u}{\mathrm{d}t}\right|_\mathrm{cool}
   = -\frac{u}{t_\mathrm{cool}}
   = -\frac{u\,\Omega(r)}{\beta}.

This is applied explicitly: at each timestep the increment
:math:`\delta u = -u\,\Omega/\beta\,\delta t` is added to the hydrodynamic
energy update.

The fragmentation boundary derived by Gammie (2001) for a two-dimensional
disc with :math:`\gamma = 2` is

.. math::

   \beta_\mathrm{crit} \approx 3,

below which the disc cannot radiate heat fast enough to prevent runaway
gravitational collapse. The numerical value of :math:`\beta_\mathrm{crit}`
depends on :math:`\gamma`; for :math:`\gamma = 5/3` it is somewhat larger
(Rice et al. 2003).

Derivations
-----------

The Keplerian angular velocity is computed from particle coordinates as

.. math::

   \Omega_i = \left(M_\star\right)^{1/2} r_i^{-3/2},

where :math:`r_i^2 = (x_i - x_\star)^2 + (y_i - y_\star)^2 +
(z_i - z_\star)^2` and :math:`(x_\star, y_\star, z_\star)` is the position of
the sink particle representing the central star. This uses the three-dimensional
(spherical) separation, which is an approximation to the true cylindrical radius
in a disc; the error is negligible for particles near the disc midplane. The
inverse cooling timescale is then :math:`t_\mathrm{cool}^{-1} = \Omega/\beta`,
and the explicit update is :math:`\dot{u} \mathrel{+}= -u/t_\mathrm{cool}`.

References
----------

Gammie, C. F. 2001, ApJ, 553, 174 (not yet in phantom.bib)

Rice, W. K. M., Armitage, P. J., Bate, M. R., & Bonnell, I. A. 2003, MNRAS,
339, 1025 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_gammie.f90
