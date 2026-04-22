.. phantom-doc: hand-written

analysis_collidingcloudevolution
================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_collidingcloudevolution`` computes statistics relevant to converging flow and colliding cloud simulations. It tracks the total mass of gas above several density thresholds and also computes basic statistics of the star formation activity, providing a quantitative measure of dense gas formation as the clouds collide.

The routine computes mass fractions above user-defined threshold densities ``dthresh_cgs`` in CGS units, converting to code units internally. It also records the number of sink particles formed and their total mass, enabling a star formation efficiency to be computed as a function of time.

Output is appended to a time-series file at each dump, giving a compact record of the evolving dense gas fraction and stellar mass across the cloud collision simulation.

Physical & Mathematical Description
------------------------------------

The mass above a density threshold :math:`\rho_0` is :math:`M(>\rho_0) = \sum_{i: \rho_i > \rho_0} m_i`. For a power-law density PDF the high-density tail mass grows as :math:`M \propto \rho_0^{-(p+1)/2}` where :math:`p` is the PDF slope, providing a diagnostic of turbulent compression in the collision region.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_collidingcloudevolution.f90`` for the complete source.
