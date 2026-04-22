.. phantom-doc: hand-written

setup_mhdblast
==============

Overview
--------

``setup_mhdblast`` sets up the MHD blast wave test (Balsara & Spicer 1999). A high-pressure, high-density sphere is embedded in a low-pressure uniform background permeated by a uniform magnetic field. The sudden pressure imbalance drives a spherical blast wave outward through the magnetised medium, creating a complex pattern of fast and slow shocks and rarefaction fans.

Particles are placed on a uniform Cartesian lattice using ``set_unifdis``, and the magnetic field :math:`B_0` is initialised uniformly throughout the box. The blast region is identified by radius and given an elevated pressure, while the surrounding medium retains the background pressure. Both isothermal and adiabatic (non-isothermal) equations of state are supported.

The MHD blast wave is a widely used benchmark because the interaction of the blast with the magnetic field produces highly anisotropic expansion and tests the code's ability to handle strong shocks in magnetised plasmas while maintaining :math:`\nabla \cdot \mathbf{B} = 0`.

Physical & Mathematical Description
------------------------------------

The initial pressure ratio between the blast and ambient regions is typically :math:`P_\mathrm{blast}/P_\mathrm{amb} \sim 10^3`. The fast magnetosonic speed :math:`v_f = \sqrt{v_A^2 + c_s^2}` where :math:`v_A = B/\sqrt{4\pi\rho}` sets the speed at which the blast front propagates along the magnetic field. Perpendicular to the field the expansion is slower, bounded by the slow magnetosonic speed. The :math:`\nabla \cdot \mathbf{B} = 0` condition is maintained using hyperbolic cleaning; see :cite:`triccoprice12`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_mhdblast.f90`` for the complete source.
