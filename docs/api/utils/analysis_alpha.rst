.. phantom-doc: hand-written

analysis_alpha
====================================================================================================================================================================================================

Overview
--------

``analysis_alpha`` computes the effective Shakura-Sunyaev viscosity parameter :math:`\alpha` as a function of disc radius in a post-processing step. It was originally written by Giuseppe Lodato and adapted for use with Phantom. The routine bins particles radially between ``rmin`` and ``rmax`` into ``nr = 350`` annuli and fits for :math:`\alpha` using the radial velocity and surface density profiles.

The analysis measures the radial velocity :math:`v_r` in each radial bin and uses the disc surface density :math:`\Sigma(R)` and sound speed profile to infer the kinematic viscosity :math:`\nu = \alpha c_s H`, where :math:`c_s` is the isothermal sound speed and :math:`H` is the disc scale height.

For each dump the output is written to a file named ``alphaXXX`` where ``XXX`` is the dump number, allowing temporal tracking of the viscosity profile as the disc evolves.

Physical & Mathematical Description
------------------------------------

The Shakura-Sunyaev alpha parameter is related to the kinematic viscosity by :math:`\nu = \alpha c_s H`, where :math:`H = c_s / \Omega` is the pressure scale height and :math:`\Omega = \sqrt{GM_*/R^3}` is the Keplerian angular frequency. The routine recovers :math:`\alpha` by fitting the effective radial transport velocity :math:`v_r = -3\nu/(2R)` implied by the continuity equation for a steady disc.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_alpha.f90`` for the complete source.
