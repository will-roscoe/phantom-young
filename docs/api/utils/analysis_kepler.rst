.. phantom-doc: hand-written

analysis_kepler
===============

Overview
--------

``analysis_kepler`` analyses surviving remnants after partial tidal disruption events (TDEs), based on the methods of Sharma, Price & Heger (2024, MNRAS 532, 89). It reads orbital elements from a dump file and computes the distribution of orbital energies, angular momenta, and eccentricities for the surviving stellar fragment and the debris stream.

The routine identifies bound particles (those with negative total orbital energy with respect to the black hole) and computes their Keplerian orbital elements using the black hole as the gravitating centre. The distribution of these elements characterises the stellar remnant and can be used to predict future fallback rates.

Analysis results include eccentricity and semi-major axis distributions for bound particles, the total mass and size of the surviving remnant, and the pericenter distance distribution of the debris.

Physical & Mathematical Description
------------------------------------

The orbital energy per unit mass of particle :math:`i` about a point mass :math:`M_\mathrm{BH}` is :math:`E_i = v_i^2/2 - G M_\mathrm{BH} / r_i`. Bound particles satisfy :math:`E_i < 0` with semi-major axis :math:`a_i = -G M_\mathrm{BH} / (2 E_i)`. The specific angular momentum is :math:`\ell_i = |\mathbf{r}_i \times \mathbf{v}_i|` giving eccentricity :math:`e_i = \sqrt{1 + 2 E_i \ell_i^2 / (G M_\mathrm{BH})^2}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_kepler.f90`` for the complete source.
