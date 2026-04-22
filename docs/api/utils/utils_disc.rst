.. phantom-doc: hand-written

utils_disc
==========

Overview
--------

``utils_disc`` (module ``discanalysisutils``) provides the core disc analysis routines used by all the ``analysis_disc_*.f90`` modules. The ``disc_analysis`` subroutine computes azimuthally averaged radial profiles of disc surface density, scale height, tilt, twist, eccentricity, and angular momentum vector orientation across a user-specified radial grid.

The module also provides ``read_discparams`` (reads disc geometry from a parameter file), ``createbins`` (sets up the radial bin edges), and ``get_binary_params`` (computes orbital elements from two sink particles). These shared utilities ensure that all disc analysis modules use identical binning and coordinate conventions.

``disc_analysis`` correctly handles misaligned (warped) discs by computing the angular momentum vector in each radial annulus separately, enabling tilt and twist profiles to be extracted from non-planar configurations.

Physical & Mathematical Description
------------------------------------

The surface density in annulus :math:`[R_k, R_{k+1}]` is :math:`\Sigma_k = \sum_{i \in k} m_i / (\pi(R_{k+1}^2 - R_k^2))`. The unit angular momentum vector in annulus :math:`k` is :math:`\hat{\mathbf{L}}_k = \mathbf{L}_k / |\mathbf{L}_k|` with :math:`\mathbf{L}_k = \sum_{i \in k} m_i \mathbf{r}_i \times \mathbf{v}_i`. The tilt of annulus :math:`k` with respect to the reference plane is :math:`\beta_k = \arccos(\hat{L}_{k,z})` and the twist is :math:`\gamma_k = \arctan(\hat{L}_{k,y} / \hat{L}_{k,x})`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_disc.f90
