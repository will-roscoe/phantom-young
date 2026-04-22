.. phantom-doc: hand-written

analysis_ptmass
===============

Overview
--------

``analysis_ptmass`` prints the binary orbital parameters for all pairs of sink particles in a Phantom simulation, assuming the central sink (index 1) is the primary and all others orbit it. It calls ``get_binary_params`` from ``discanalysisutils`` to compute the orbital semi-major axis, eccentricity, inclination, and orbital period for each sink pair.

The routine is useful for monitoring the orbital evolution of binary star or planet-disc systems, providing a quick summary of the orbital elements without requiring a full disc analysis. It outputs a table of sink particle masses and orbital elements at each dump.

Since it uses :math:`G = 1` in code units, the orbital period is :math:`P = 2\pi a^{3/2} / \sqrt{M_\mathrm{tot}}` in code time units, which can be converted to physical units via ``utime``.

Physical & Mathematical Description
------------------------------------

The binary orbital elements are obtained from the relative position :math:`\mathbf{r}_{12} = \mathbf{r}_2 - \mathbf{r}_1` and velocity :math:`\mathbf{v}_{12} = \mathbf{v}_2 - \mathbf{v}_1` of each sink pair. The semi-major axis is :math:`a = -G M_\mathrm{tot} / (2 E_{\mathrm{orb}})` where :math:`E_\mathrm{orb} = v_{12}^2/2 - G M_\mathrm{tot}/r_{12}`, and the eccentricity is :math:`e = |\mathbf{e}_{\mathrm{LRL}}|`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_ptmass.f90`` for the complete source.
