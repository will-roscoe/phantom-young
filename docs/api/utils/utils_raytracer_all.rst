.. phantom-doc: hand-written

utils_raytracer_all
===================

Overview
--------

``utils_raytracer_all`` (module ``raytracer_all``) implements three ray-tracing schemes for computing optical depths in AGB stellar wind simulations, following the methods of Esseldeurs et al. (2023, A&A 674, A122). The three schemes are: outward ray-tracing from the star (``get_all_tau_outwards``), inward ray-tracing toward the star (``get_all_tau_inwards``), and an adaptive scheme that switches between the two based on local opacity gradients (``get_all_tau_adaptive``).

All three routines use the HEALPix sphere tessellation (from the ``healpix`` module) to generate ray directions at multiple resolution levels, with the adaptive scheme refining the ray density in optically thick regions. The kd-tree (``neighkdtree``) provides efficient identification of particles along each ray.

This module is used by ``analysis_raytracer`` to compute the optical depth from the central star to each SPH particle, enabling post-processing computation of radiative forces and synthetic observables.

Physical & Mathematical Description
------------------------------------

The optical depth from the star to particle :math:`i` along ray :math:`\hat{\mathbf{n}}` is :math:`\tau_i = \int_0^{r_i} \kappa(\mathbf{r}) \rho(\mathbf{r}) \, ds`, discretised as a sum over SPH particles :math:`j` along the ray: :math:`\tau_i \approx \sum_{j: 0 < (\mathbf{r}_j \cdot \hat{\mathbf{n}}) < r_i} \kappa_j m_j W(d_{j\perp}, h_j) / h_j`, where :math:`d_{j\perp}` is the perpendicular distance from particle :math:`j` to the ray. The adaptive scheme uses HEALPix at minimum order ``minOrder`` and refines to order ``minOrder + refineLevel``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_raytracer_all.f90
