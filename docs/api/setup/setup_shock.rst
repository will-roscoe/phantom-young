.. phantom-doc: hand-written

setup_shock
===========

Overview
--------

``setup_shock`` is Phantom's most general shock tube setup. It configures arbitrary 1D Riemann problems in a 3D slab geometry, with independent control over the left and right states (density, pressure/sound speed, velocity) via a comprehensive parameter file. The left region occupies ``-xleft < x < xshock`` and the right region ``xshock < x < xright``. Both gas-only and dusty shock tubes (one-fluid or two-fluid dust) are supported, as are MHD shocks with the Biermann battery and non-ideal MHD terms.

The full range of equation-of-state options is accessible (``ieos``), including isothermal, adiabatic, barotropic, and radiation-coupled equations. Non-ideal MHD resistivities — Ohmic (``use_ohm``), Hall (``use_hall``), and ambipolar diffusion (``use_ambi``) — can each be independently enabled. Constant drag between dust and gas (``K_code``) and constant ion density (``rho_i_cnst``) are available for partially ionised plasma tests.

This single setup file replaces dozens of specialised shock tube setups found in other SPH codes, making it the primary tool for validating Phantom's shock-capturing, dissipation, and non-ideal physics in 1D.

Physical & Mathematical Description
------------------------------------

The Rankine-Hugoniot jump conditions for a strong adiabatic shock give :math:`\rho_2/\rho_1 = (\gamma+1)/(\gamma-1)`, :math:`P_2/P_1 = 2\gamma M^2/(\gamma+1) - (\gamma-1)/(\gamma+1)`, and :math:`v_2 = v_s (1 - \rho_1/\rho_2)`, where :math:`M = v_s/c_{s,1}` is the shock Mach number. The shock is captured with Phantom's artificial viscosity :math:`\alpha_\mathrm{AV}`, and the parameter ``smooth_fac`` controls the initial smoothing of the contact discontinuity. For MHD shocks, the Rankine-Hugoniot conditions are augmented by continuity of :math:`B_n` and the jump in :math:`\mathbf{B}_t`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_shock.f90`` for the complete source.
