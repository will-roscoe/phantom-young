.. phantom-doc: hand-written

setup_turb
==========

Overview
--------

``setup_turb`` initialises a simulation of driven supersonic turbulence in a periodic box, closely following Price & Federrath (2010) and Tricco, Price & Federrath (2016). A uniform-density gas fills the periodic cube on a Cartesian (or close-packed) lattice with resolution ``npartx``. An isothermal equation of state with sound speed ``polykset`` is used, and a turbulent velocity field can optionally be driven at run time by a separate driving module. For MHD runs a uniform magnetic field :math:`B_z` = ``Bz_0`` is applied along the z axis.

Dust can be included using Phantom's one-fluid or two-fluid dust schemes, with grain size and density set via the dust module. The dust-to-gas ratio and grain size are configurable, enabling studies of dust dynamics in turbulent ISM environments. The ``rhozero`` parameter sets the mean gas density and hence the particle mass.

This is the standard setup for turbulence studies in Phantom, used to measure the density PDF, power spectrum, sonic and Alfvenic Mach numbers, the star formation rate, and the effects of magnetic fields and dust on turbulent statistics. See also :cite:`pricefederrath10` and :cite:`triccoprice13`.

Physical & Mathematical Description
------------------------------------

For isothermal turbulence the density PDF is lognormal: :math:`p(\ln\rho) = (2\pi \sigma_s^2)^{-1/2} \exp[-(\ln\rho - \bar{\ln\rho})^2 / (2\sigma_s^2)]`, with :math:`\sigma_s^2 = \ln(1 + b^2 M_s^2)` where :math:`M_s = v_\mathrm{rms}/c_s` is the sonic Mach number and :math:`b \approx 0.3`–1 depends on the mixture of solenoidal and compressive forcing (:cite:`pricefederrath10`). The power spectrum of velocity fluctuations follows :math:`E(k) \propto k^{-2}` (Burgers) for shock-dominated turbulence. For MHD turbulence with :math:`M_A < 1`, the Alfvenic Mach number :math:`M_A = v_\mathrm{rms}/v_A` determines the magnetic field morphology; see :cite:`triccoprice13`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_turb.f90`` for the complete source.
