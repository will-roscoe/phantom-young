.. phantom-doc: hand-written

analysis_disc
=============

Overview
--------

``analysis_disc`` is the primary post-processing analysis routine for protoplanetary and circumstellar disc simulations in Phantom. It delegates to ``disc_analysis`` from the ``discanalysisutils`` module, which computes azimuthally averaged radial profiles of surface density :math:`\Sigma(R)`, scale height :math:`H(R)`, disc tilt :math:`\beta(R)`, twist :math:`\gamma(R)`, and eccentricity :math:`e(R)` across ``nr = 300`` radial bins.

For each dump a set of output files is created (named using the dump prefix and number), recording the radial profiles of all disc properties. The routine reads disc geometry parameters (``R_in``, ``R_out``, ``H/R``, power-law indices) from a parameter file. Both single-star and binary-star systems with sink particles are handled.

The tilt and twist profiles characterise warped discs, enabling study of Bardeen-Petterson alignment, Kozai-Lidov oscillations, and disc breaking in highly misaligned systems.

Physical & Mathematical Description
------------------------------------

The surface density in annulus :math:`[R, R + \Delta R]` is :math:`\Sigma(R) = \sum_i m_i / (2\pi R \Delta R)`, where the sum is over particles in the bin. The disc scale height is estimated from the root-mean-square height :math:`H(R) = \sqrt{\langle z^2 \rangle}`. The tilt :math:`\beta` and twist :math:`\gamma` are extracted from the angular momentum unit vector :math:`\hat{\mathbf{L}}(R) = \mathbf{L}(R) / |\mathbf{L}(R)|` in each radial annulus.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_disc.f90`` for the complete source.
