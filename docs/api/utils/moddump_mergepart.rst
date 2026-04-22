.. phantom-doc: hand-written

moddump_mergepart
=================

Overview
--------

``moddump_mergepart`` merges particles to reduce simulation resolution, implementing the inverse of particle splitting. Written by Rebecca Nealon, it uses ``merge_all_particles`` from the ``splitpart`` module (which calls ``fancy_merge_into_a_particle`` from ``splitmergeutils``) to merge every ``nchild`` particles into a single parent, preserving total mass, momentum, and energy.

The default ``nchild = 2`` merges pairs of particles, halving the resolution. The ``--nchild=N`` command-line flag can be used to merge :math:`N` particles at a time. The merged parent particle is placed at the mass-weighted centre of the children and inherits the mass-weighted velocity.

This moddump is useful for reducing computational cost after an initial high-resolution calculation has identified the region of interest, or for creating low-resolution restarts of high-resolution simulations for quick parameter scans.

Physical & Mathematical Description
------------------------------------

Merging :math:`N_\mathrm{child}` particles into one parent conserves mass (:math:`m_p = \sum_k m_k`), momentum (:math:`m_p \mathbf{v}_p = \sum_k m_k \mathbf{v}_k`), and energy (:math:`m_p u_p = \sum_k m_k u_k`), following Vacondio et al. (2013). The parent position is the mass-weighted centroid :math:`\mathbf{r}_p = \sum_k m_k \mathbf{r}_k / m_p` and the smoothing length is :math:`h_p = N_\mathrm{child}^{1/3} h_\mathrm{child}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_mergepart.f90`` for the complete source.
