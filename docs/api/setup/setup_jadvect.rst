.. phantom-doc: hand-written

setup_jadvect
=============

Overview
--------

``setup_jadvect`` initialises the MHD current loop advection test of Gardiner & Stone (2005) and Rosswog & Price (2007). A circular current loop of radius ``rloop`` with a vector potential amplitude ``Azero`` is embedded in a uniform background flow of speed ``vzero`` and pressure ``przero`` in a 2D periodic slab geometry. The particles are placed on a uniform 2D lattice using the ``set_slab`` routine.

The current loop is a smooth non-trivial magnetic field configuration whose analytic evolution under pure advection is simply translation at the background flow speed. Numerical dissipation of the magnetic field — particularly its divergence errors — can be measured by comparing the final field configuration with the translated initial state after the loop has completed one full traversal of the periodic box.

This test is sensitive to the accuracy of the divergence-cleaning algorithm and the constrained-transport (or divergence-control) scheme, making it a key benchmark for MHD codes including Phantom with its hyperbolic divergence cleaning.

Physical & Mathematical Description
------------------------------------

The vector potential is :math:`A_z = A_0 \max(r_\mathrm{loop} - r, 0)` where :math:`r` is the cylindrical radius from the loop centre, giving :math:`B_r = -\partial A_z/\partial z = 0` and :math:`B_\phi = \partial A_z/\partial r` inside the loop. The divergence-free condition :math:`\nabla \cdot \mathbf{B} = 0` must be maintained numerically; Phantom uses hyperbolic cleaning with :math:`\partial \psi/\partial t + c_h^2 \nabla \cdot \mathbf{B} = -\psi/t_d` to damp divergence errors. See :cite:`triccoprice12` for the divergence-cleaning scheme used in Phantom.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_jadvect.f90`` for the complete source.
