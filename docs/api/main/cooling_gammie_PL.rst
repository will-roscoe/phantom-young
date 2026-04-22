.. phantom-doc: hand-written

cooling_gammie_PL
=================

Overview
--------

The ``cooling_gammie_PL`` module extends the Gammie (2001) beta-cooling
prescription by allowing the dimensionless cooling parameter :math:`\beta` to
vary with radius according to a power law. This generalisation is physically
motivated by the radial dependence of disc irradiation, viscous dissipation,
and the stellar radiation field, all of which cause the local cooling efficiency
to change with distance from the central object.

The subroutine ``cooling_Gammie_PL_explicit`` computes the explicit cooling
contribution :math:`\dot{u}` for each SPH particle. It assumes a purely
Keplerian disc (the central mass is implicitly set to unity in code units,
i.e., :math:`M_\star = 1`) and derives :math:`\Omega` from the three-dimensional
separation from the origin. The module is activated by setting ``icooling = 7``
in the Phantom input file.

Three runtime parameters control the prescription:

- ``beta_cool`` (:math:`\beta_0`): the value of the cooling factor at the
  reference radius :math:`r_\beta`. Default: 3.
- ``r_beta``: the reference (characteristic) radius in code units at which
  :math:`\beta = \beta_0`. Default: 50.
- ``eta``: the power-law exponent of the radial :math:`\beta` profile.
  Default: 1.5.

This module is developed and maintained by Cristiano Longarini.

Physical & Mathematical Description
-------------------------------------

The local cooling timescale is parameterised as

.. math::

   t_\mathrm{cool}(r) = \frac{\beta(r)}{\Omega(r)},

where the Keplerian angular velocity (with :math:`G M_\star = 1` in code units)
is

.. math::

   \Omega(r) = r^{-3/2},

and the radially varying beta factor is

.. math::

   \beta(r) = \beta_0 \left(\frac{r}{r_\beta}\right)^\eta.

Combining these expressions gives the inverse cooling timescale

.. math::

   t_\mathrm{cool}^{-1} = \frac{\Omega(r)}{\beta(r)}
   = \frac{r^{-3/2}}{\beta_0\,(r/r_\beta)^\eta}
   = \frac{r^{-3/2}}{\beta_0}\left(\frac{r^2}{r_\beta^2}\right)^{-\eta/2},

where the last form uses the squared radius :math:`r^2 = x^2+y^2+z^2` as
implemented in the code. The explicit energy update is then

.. math::

   \left.\frac{\mathrm{d}u}{\mathrm{d}t}\right|_\mathrm{cool}
   = -\frac{u}{t_\mathrm{cool}(r)}
   = -u\,\frac{\Omega(r)}{\beta_0\,(r^2/r_\beta^2)^{-\eta/2}}.

For :math:`\eta = 0` the standard Gammie (2001) prescription (``cooling_gammie``)
is recovered. For :math:`\eta > 0` the disc cools more slowly at larger radii
(larger :math:`\beta`), consistent with the reduced effectiveness of cooling
in the outer, more optically thin disc.

Derivations
-----------

In the code, the squared radius :math:`r^2 = x_i^2 + y_i^2 + z_i^2` is
computed from particle coordinates, giving :math:`\Omega_i = (r^2)^{-3/4}`.
The local beta factor is expressed as

.. math::

   \beta_\mathrm{local} = \beta_0 \left(\frac{r^2}{r_\beta^2}\right)^{\eta/2},

so that the inverse cooling time becomes
:math:`t_\mathrm{cool}^{-1} = \Omega_i / \beta_\mathrm{local}`, matching the
implementation ``tcool1 = Omegai / (beta_cool * (r2/r_beta**2)**(-eta/2))``.

References
----------

Gammie, C. F. 2001, ApJ, 553, 174 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_gammie_PL.f90
