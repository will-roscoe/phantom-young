.. phantom-doc: hand-written

setup_chinchen
==============

Overview
--------

``setup_chinchen`` initialises the "Chinese coin" orbital dynamics problem from Chin & Chen (2005). This is a purely gravitational N-body test involving two sink particles (no gas) evolving under a binary external potential. The test is designed to verify the accuracy of the integrator in conserving energy and angular momentum for a figure-8 or other special periodic orbit.

The setup places two sink particles at precisely chosen initial positions and velocities that correspond to a known periodic solution of the three-body problem (or two-body problem with external field). The binary is represented through the ``extern_binary`` external force module, and the units are set in solar masses and astronomical units.

Because there is no gas and no dissipation, this test isolates the accuracy of the orbital integrator and the sink-particle dynamics from SPH effects, making it a clean check of the gravitational part of the code.

Physical & Mathematical Description
------------------------------------

For two equal masses :math:`m` in a figure-8 orbit of Chenciner & Montgomery (2000), the period and scale are determined by the initial conditions :math:`(x_0, v_0)` that satisfy :math:`T = 2\pi / \omega`. Energy conservation requires :math:`\Delta E / E_0 \ll 1` over many orbital periods. The external binary potential used is :math:`\Phi = -G m_1 / r_1 - G m_2 / r_2`, with forces computed to machine precision.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_chinchen.f90`` for the complete source.
