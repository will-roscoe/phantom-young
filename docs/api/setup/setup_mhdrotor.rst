.. phantom-doc: hand-written

setup_mhdrotor
==============

Overview
--------

``setup_mhdrotor`` initialises the MHD rotor test. A dense, rapidly rotating cylindrical region (the rotor) is embedded in a stationary, lower-density ambient medium permeated by a uniform magnetic field. The centrifugal force of the rotating gas is counteracted by the magnetic tension of the field lines wound up by the rotation, launching a torsional Alfven wave into the surrounding medium.

Particles are placed on a uniform 3D lattice, with the dense rotor region identified by its cylindrical radius and given the appropriate rotational velocity. The ambient medium is at rest with the uniform background field. This test challenges the code's ability to handle sub-Alfvenic and trans-Alfvenic flows, angular momentum transport via magnetic tension, and the formation of density and velocity discontinuities at the rotor boundary.

The rotor test was first proposed as an MHD benchmark by Balsara & Spicer (1999) and has since been used extensively to compare MHD codes. Phantom's treatment of the divergence-free condition is tested through the evolution of the rotor's wound field.

Physical & Mathematical Description
------------------------------------

The Alfven speed in the ambient medium is :math:`v_A = B_0 / \sqrt{4\pi\rho_0}`. For a rotor rotating at angular velocity :math:`\Omega` with radius :math:`R_0`, the maximum rotational velocity is :math:`v_\phi^\mathrm{max} = \Omega R_0`. The torsional Alfven wave propagates outward at the Alfven speed, transporting angular momentum and winding the field from :math:`B_\phi = 0` initially to :math:`B_\phi \sim (v_\phi/v_A) B_0`. The Alfven Mach number :math:`M_A = v_\phi^\mathrm{max}/v_A` controls the degree of field winding.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_mhdrotor.f90`` for the complete source.
