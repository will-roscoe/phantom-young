.. phantom-doc: hand-written

setup_orstang
=============

Overview
--------

``setup_orstang`` sets up the Orszag-Tang vortex, the canonical 2D MHD turbulence benchmark (Orszag & Tang 1979; Dahlburg & Picone 1989). A smooth double-periodic velocity field :math:`(v_x, v_y) = (-\sin y, \sin x)` and magnetic field :math:`(B_x, B_y) = (-\sin y, \sin 2x)` are superimposed on a uniform density background. The interaction of the current sheets and vortices produces a hierarchy of MHD shocks, making this the standard test for MHD shock physics and turbulent energy dissipation.

Particles are placed on a 2D uniform slab using the ``set_slab`` module with resolution controlled by ``nx``. The plasma beta parameter ``betazero``, the Mach number ``machzero``, and the field amplitude ``bzero`` are all set at runtime. The domain spans from ``xymin`` to ``-xymin`` in both directions.

This setup is the primary test used in :cite:`pricemonaghan07` to demonstrate the performance of Phantom's MHD implementation on a turbulent problem, and results can be directly compared with published grid-code and SPH results.

Physical & Mathematical Description
------------------------------------

The initial conditions are :math:`\rho = 25/(36\pi)`, :math:`P = 5/(12\pi)`, :math:`v_x = -\sin(2\pi y)`, :math:`v_y = \sin(2\pi x)`, :math:`B_x = -\sin(2\pi y) / \sqrt{4\pi}`, :math:`B_y = \sin(4\pi x) / \sqrt{4\pi}` in normalised units. The plasma beta is :math:`\beta_p = 2P/B^2 = 10/3`. The Mach number determines the strength of the shocks forming at the current sheets. See :cite:`pricemonaghan07` for the SPH MHD results for this test.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_orstang.f90`` for the complete source.
