.. phantom-doc: hand-written

analysis_disc_eccentric
=======================

Overview
--------

``analysis_disc_eccentric`` analyses disc radial structure using the particle semi-major axis rather than the instantaneous cylindrical radius, making it more accurate for eccentric discs where particles are not on circular orbits. Written by Enrico Ragusa, it bins particles into ``nr = 400`` semi-major axis bins and computes the surface density, eccentricity, and angular momentum profiles.

The routine is particularly suited to studying eccentric disc modes, gap opening by planets, and disc-binary interactions where significant eccentricities develop. It notes that a purely Keplerian velocity assignment induces a spurious eccentricity :math:`e_\mathrm{spur} = \beta (H/R)^2` due to pressure support, where :math:`\beta = 3/2 + p + q` for power-law surface density and temperature profiles.

Output files record the eccentric disc fraction (not directly a surface density since eccentric annuli have non-trivial areas) as a function of semi-major axis, enabling comparison with analytic eccentric disc theory.

Physical & Mathematical Description
------------------------------------

The orbital semi-major axis of particle :math:`i` is :math:`a_i = -G M_* / (2 E_i)`, where the specific orbital energy is :math:`E_i = v_i^2 / 2 - GM_* / r_i`. The orbital eccentricity is :math:`e_i = |\mathbf{e}_i|` where the Laplace-Runge-Lenz vector is :math:`\mathbf{e}_i = \mathbf{v}_i \times \mathbf{L}_i / (G M_*) - \hat{\mathbf{r}}_i`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_disc_eccentric.f90`` for the complete source.
