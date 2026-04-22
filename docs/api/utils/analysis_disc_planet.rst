.. phantom-doc: hand-written

analysis_disc_planet
====================

Overview
--------

``analysis_disc_planet`` analyses a disc interacting with a planet, represented as two sink particles (star and planet). Written by Rebecca Nealon, it computes disc properties in a frame centred on the primary star, accounting for the gravitational influence of both sink particles and the disc self-gravity contribution.

The routine tracks the disc tilt, twist, and angular momentum profiles as in ``analysis_disc``, but additionally records the binary orbital parameters and planet position relative to the disc at each dump. It uses ``get_binary_params`` from ``discanalysisutils`` to extract the orbital elements of the sink-particle pair.

Results are written to separate output files for the disc profiles and the binary/planet parameters, enabling study of disc warping, gap formation, and disc-planet alignment in misaligned planetary systems.

Physical & Mathematical Description
------------------------------------

For a disc-planet system with planet mass :math:`M_p \ll M_*`, the tidal torque per unit area is :math:`T_\mathrm{tidal}(R) \approx -\frac{3}{4} q^2 \frac{G M_*}{R} \Sigma(R) (R/a)^{-3}`, where :math:`q = M_p / M_*` and :math:`a` is the planet semi-major axis. Disc warping is driven by the misalignment between the planetary orbital plane and the disc midplane.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_disc_planet.f90`` for the complete source.
