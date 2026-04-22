.. phantom-doc: hand-written

analysis_clumpfindWB23
====================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_clumpfindWB23`` is a clump-finding and characterisation algorithm based on the methodology of Wurster & Bonnell (2023). On the first call the user is prompted for simulation-dependent parameters that are written to a parameter file ``clumpfindWB23.in`` for subsequent runs. The algorithm identifies clumps using local density peaks and assigns particles based on a boundedness criterion similar to Bate (2018) and Wurster, Bate & Price (2019).

Each identified clump has its mass and energy summed from all bound particles. The effective spherical radius is set to :math:`\bar{r} + 2\sigma_r`, where :math:`\bar{r}` and :math:`\sigma_r` are the mean and standard deviation of particle radii within the clump. An ellipsoidal shape is fitted using the moment of inertia method of Rocha, Velho & Carvalho (2002), projecting data onto the three cardinal planes and iterating until the fitted orientation converges.

This routine is particularly suited to star formation simulations and produces detailed clump catalogues including masses, sizes, shapes, and bound energies. Note that cross-dump tracking is not currently implemented.

Physical & Mathematical Description
------------------------------------

A clump is bound if :math:`E_{\mathrm{kin,eff}} + E_{\mathrm{pot}} < 0`, where :math:`E_{\mathrm{kin,eff}} = f_\mathrm{coef} \sum_i m_i v_i^2 / 2` with ``ekin_coef`` as a user-specified weighting factor. The shape ellipsoid semi-axes :math:`(a_1, a_2, a_3)` are derived from the eigenvalues of the inertia tensor :math:`I_{jk} = \sum_i m_i (r_i^2 \delta_{jk} - r_{ij} r_{ik})`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_clumpfindWB23.F90`` for the complete source.
