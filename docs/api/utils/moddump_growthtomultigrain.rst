.. phantom-doc: hand-written

moddump_growthtomultigrain
==========================

Overview
--------

``moddump_growthtomultigrain`` converts a single-fluid dust growth dump (where the grain size distribution is represented by the first moment of the distribution) into a multi-grain large-grain dump compatible with MCFOST radiative transfer post-processing. Written by Arnaud Vericel, it uses the ``bin_to_multi`` routine from the ``growth`` module to map the continuous grain size distribution onto a discrete set of grain size bins.

The user is prompted for the number of grain size bins and the minimum and maximum grain sizes. The ``nmax`` parameter from ``io_control`` sets the maximum number of particles in the output. Accreted particles are removed before the conversion.

The resulting multi-grain dump can be read by MCFOST to compute dust opacities and temperature profiles for each grain size bin separately, providing more accurate radiative transfer results than a single-species approximation.

Physical & Mathematical Description
------------------------------------

The dust size distribution from the growth model is characterised by the first two moments :math:`s_0 = \langle s \rangle` (mean grain size) and :math:`s_1` (second moment). The ``bin_to_multi`` routine maps this distribution onto :math:`N_\mathrm{bins}` discrete grain sizes :math:`s_k`, computing the mass fraction in each bin from the local grain size distribution. The total dust mass is conserved: :math:`\sum_k m_{d,k} = m_d` for each SPH particle.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_growthtomultigrain.f90`` for the complete source.
