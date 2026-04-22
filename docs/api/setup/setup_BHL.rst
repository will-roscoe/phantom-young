.. phantom-doc: hand-written

setup_BHL
=========

Overview
--------

``setup_BHL`` initialises a Bondi-Hoyle-Lyttleton (BHL) accretion simulation. The domain begins empty save for a single sink particle of mass ``BHL_m_star`` representing the accreting object; a uniform, supersonic wind of gas particles is then injected at run time by the BHL injection module. This clean separation between setup (sink only) and injection (wind particles) allows the accretion flow to develop self-consistently from the prescribed far-field conditions.

The setup uses code units where G = 1, and the sink accretion radius ``hacc`` is set to a small fraction of the Bondi-Hoyle radius. The adiabatic index is set to 5/3 by default. The Mach number of the wind and its density and sound speed are controlled through parameters in the injection module, not in the setup file itself.

This configuration is the standard benchmark for testing BHL accretion in SPH codes; the time-averaged accretion rate and flow morphology can be compared with analytic expectations and grid-code results.

Physical & Mathematical Description
------------------------------------

The Bondi-Hoyle-Lyttleton accretion radius is :math:`R_\mathrm{BHL} = 2GM / (v_\infty^2 + c_{s,\infty}^2)`, where :math:`M` is the sink mass, :math:`v_\infty` is the wind speed, and :math:`c_{s,\infty}` is the ambient sound speed. The classical BHL accretion rate is :math:`\dot{M}_\mathrm{BHL} = 4\pi \lambda_c G^2 M^2 \rho_\infty / (v_\infty^2 + c_{s,\infty}^2)^{3/2}`, where :math:`\lambda_c` is a dimensionless numerical factor of order unity. The Mach number :math:`\mathcal{M} = v_\infty / c_{s,\infty}` characterises whether the flow is sub- or supersonic far from the accreting body.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_BHL.f90`` for the complete source.
