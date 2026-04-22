.. phantom-doc: hand-written

moddump\_splitpart
==================

Overview
--------

``moddump_splitpart`` increases the resolution of an existing Phantom dump by splitting every SPH particle into a configurable number of child particles. It was written by Daniel Price. Each parent particle is replaced by ``nchild`` children (default 13) arranged on a sub-lattice or in a random pattern, controlled by ``lattice_type``.

The child masses satisfy :math:`m_\mathrm{child} = m_\mathrm{parent} / n_\mathrm{child}` and their positions are offset from the parent by a fraction of the smoothing length so that the new particles reproduce the parent density field to leading order. The routine calls ``split_all_particles`` from the ``splitpart`` module and subsequently removes any dead or accreted particles from the arrays.

This moddump is commonly used to re-start a converged low-resolution simulation at higher resolution, for example to improve the treatment of shocks or to resolve a Jeans mass that was only marginally captured in the original run.

Physical & Mathematical Description
------------------------------------

Conservation of mass requires :math:`m_i^\prime = m_i / n_\mathrm{child}`. The child smoothing lengths are initialised from :math:`h_i^\prime = h_i \, n_\mathrm{child}^{-1/3}`, preserving the neighbour count for a fixed kernel. The arrangement of children within a sphere of radius :math:`\sim h_i` uses a close-packed lattice with ``ires`` layers, giving ``get_parts_per_sphere(ires)`` particles per sphere.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_splitpart.f90`` for the complete source.
