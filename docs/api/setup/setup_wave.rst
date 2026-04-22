.. phantom-doc: hand-written

setup_wave
==========

Overview
--------

``setup_wave`` initialises a linear sound wave (or dusty sound wave) in a periodic box. Gas particles are placed on a uniform lattice with a sinusoidal density and velocity perturbation of amplitude ``ampl`` and wavenumber :math:`k = 2\pi/L_x`. For dusty runs (one-fluid or two-fluid), a separate dust component is added with a dust-to-gas ratio ``dtg`` and a constant drag coefficient ``K_drag``. The wave propagation speed can be compared against analytic predictions for both pure-gas and dust-laden waves.

The sound speed is set by ``cs``, determining ``polyk``. For the two-fluid case, the dust and gas wave modes decouple: the gas sound wave propagates at :math:`c_s` while the dust is dragged along at a rate set by the stopping time. In the one-fluid (mixture) limit the effective sound speed is reduced by the dust loading. The wave test is run over one crossing time and the residual error in amplitude and phase is measured.

This setup is used to validate the SPH wave propagation accuracy, the dust-gas drag implementation, and the one-fluid/two-fluid equivalence in the long-wavelength limit.

Physical & Mathematical Description
------------------------------------

For a pure gas isothermal sound wave the dispersion relation is :math:`\omega = c_s k`, giving a wave speed :math:`c_s = \sqrt{\gamma P/\rho}`. In a dust-gas mixture with stopping time :math:`t_s` the coupled wave dispersion relation in the terminal velocity approximation is :math:`\omega^2 = c_s^2 k^2 / (1 + \epsilon)`, where :math:`\epsilon = \rho_d/\rho_g` is the dust-to-gas ratio. For the two-fluid case the gas wave damps over the dust stopping length :math:`l_s = c_s t_s` by the drag coupling term :math:`-\epsilon (v_g - v_d)/t_s`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_wave.f90`` for the complete source.
