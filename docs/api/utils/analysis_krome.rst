.. phantom-doc: hand-written

analysis_krome
==============

Overview
--------

``analysis_krome`` is a post-processing routine that computes optical depths through an AGB stellar wind using the KROME chemistry network coupled with ray-tracing. Maintained by Mats Esseldeurs, it integrates chemical abundances along sight lines from the central star through the wind, using the molecular opacity library from KROME.

The routine builds a kd-tree of particles via ``build_tree``, then calls ``get_all_tau`` from the ``raytracer`` module to compute the optical depth :math:`\tau` for each particle from the stellar surface outward. It handles the time evolution of abundances by comparing current particle identifiers with those from the previous dump.

Output files record the optical depth and abundance profiles as a function of position in the wind, enabling synthetic spectral energy distributions and line profiles to be computed in post-processing.

Physical & Mathematical Description
------------------------------------

The optical depth from the star to particle :math:`i` along direction :math:`\hat{\mathbf{n}}` is :math:`\tau_i = \int_0^{r_i} \kappa(\mathbf{r}) \rho(\mathbf{r}) \, ds`, where :math:`\kappa` is the opacity computed from the KROME chemical abundances and the extinction is dominated by molecular and dust opacity. The Bowen dust opacity model with :math:`A_{UV}/A_V = 4.65` and albedo :math:`\alpha = 0.5` is used.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_krome.f90`` for the complete source.
