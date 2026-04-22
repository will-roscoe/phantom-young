.. phantom-doc: hand-written

analysis_angmom
=================================================================================================================================================================================================================================

Overview
--------

``analysis_angmom`` computes the total angular momentum budget of a Phantom simulation at each post-processing dump. It separately calculates the orbital angular momentum of gas particles, sink particles, and the spin angular momentum of sink particles, then sums these to give the total conserved angular momentum :math:`\mathbf{L}_\mathrm{tot}`.

For each dump the code calls ``compute_energies`` to obtain the global angular momentum, then uses a dedicated ``get_angmom`` routine to compute the angular momentum vector for gas and sink particles separately. The inclination and rotation angles of the total angular momentum vector relative to the :math:`z`-axis are also reported.

Results are written to file in physical units (using the conversion factor ``unit_angmom``) and in years (using ``utime``), enabling comparison across simulations with different code unit choices.

Physical & Mathematical Description
------------------------------------

The angular momentum of the gas is :math:`\mathbf{L}_\mathrm{gas} = \sum_i m_i \mathbf{r}_i \times \mathbf{v}_i`, summed over all live SPH particles. Sink spin angular momenta :math:`\mathbf{s}_k` stored in the ``xyzmh_ptmass`` array are added to give :math:`\mathbf{L}_\mathrm{tot} = \mathbf{L}_\mathrm{gas} + \mathbf{L}_\mathrm{sinks} + \sum_k \mathbf{s}_k`. The inclination of the total angular momentum with respect to the :math:`z`-axis is :math:`\iota = \arccos(L_z / |\mathbf{L}|)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_angmom.f90`` for the complete source.
