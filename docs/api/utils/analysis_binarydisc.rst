.. phantom-doc: hand-written

analysis_binarydisc
=========================================================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_binarydisc`` is a post-processing analysis routine for discs in binary star systems. Written by Chris Nixon (CJN) and adapted for Phantom, it classifies particles into three categories: those bound within the primary Roche lobe (circumprimary disc), those bound within the secondary Roche lobe (circumsecondary disc), and those outside the binary semi-major axis (circumbinary disc).

For each disc component the routine computes azimuthally averaged radial profiles of surface density, tilt, twist, and other disc properties, writing them to separate output files: ``binary.dat``, ``circumprimary_*.dat``, ``circumsecondary_*.dat``, and ``circumbinary_*.dat``. The Roche lobe radii are estimated using ``Rochelobe_estimate`` from the ``setbinary`` module.

The analysis requires two sink particles (the binary components) and reads disc parameters from a parameter file. It is well suited to studying disc truncation, mass transfer, and disc warping in binary systems.

Physical & Mathematical Description
------------------------------------

Particles are assigned to discs based on their location relative to the Roche potential: a particle at position :math:`\mathbf{r}` belongs to the circumprimary disc if :math:`|\mathbf{r} - \mathbf{r}_1| < R_{L,1}`, where :math:`R_{L,1}` is the Eggleton (1983) Roche lobe radius :math:`R_L \approx 0.49 q^{2/3} / [0.6 q^{2/3} + \ln(1 + q^{1/3})]` with :math:`q = M_2/M_1`. Circumbinary particles satisfy :math:`|\mathbf{r}| > a`, the orbital semi-major axis.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_binarydisc.f90`` for the complete source.
