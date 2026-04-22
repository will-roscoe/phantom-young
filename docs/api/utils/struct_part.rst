.. phantom-doc: hand-written

struct_part
===========

Overview
--------

``struct_part`` (module ``structurefn_part``) computes velocity structure functions directly from SPH particle positions and velocities, using random particle pair sampling for efficiency in large simulations. The ``get_structure_fn`` routine computes the :math:`p`-th order longitudinal and transverse structure functions for up to ``norder = 10`` orders and ``nbins`` logarithmically spaced lag bins.

The routine generates random particle pairs using the ``ran2`` random number generator and evaluates the velocity difference at each pair separation, binning the results into the lag array. The pair sampling is controlled by the number of calls and the timing module monitors performance for very large simulations.

Optional mass weighting (``massweighted``) is supported, in which case structure functions are weighted by the particle mass, providing mass-weighted rather than volume-weighted statistics.

Physical & Mathematical Description
------------------------------------

The :math:`p`-th order longitudinal structure function is :math:`S_p^L(\ell) = \langle |\delta v_L(\ell)|^p \rangle`, where :math:`\delta v_L = (\mathbf{v}_i - \mathbf{v}_j) \cdot \hat{\mathbf{r}}_{ij}` and the average is over all particle pairs with separation :math:`\ell = |\mathbf{r}_{ij}|` within the lag bin :math:`[\ell_k, \ell_k + \Delta\ell]`. Similarly :math:`S_p^T(\ell) = \langle |\delta v_T(\ell)|^p \rangle` with :math:`\delta v_T = (\mathbf{v}_i - \mathbf{v}_j) \times \hat{\mathbf{r}}_{ij}` (the transverse component magnitude).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/struct_part.f90
