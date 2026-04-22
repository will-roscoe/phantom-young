.. phantom-doc: hand-written

setup_torus
===========

Overview
--------

``setup_torus`` configures the Papaloizou-Pringle torus (Papaloizou & Pringle 1984), an isentropic, pressure-supported torus in centrifugal balance around a central mass ``Mstar``. The torus mass ``Mtorus`` and radius ``Rtorus`` set the scale, with particles distributed in rings and layers integrated over the torus cross-section. The density and pressure profiles are set by the equilibrium solution; a density cutoff ``densmin`` prevents numerical problems in the tenuous outer regions.

The torus is widely used to study the magnetorotational instability (MRI) and the Papaloizou-Pringle instability (PPI), both of which arise in thick accretion tori around compact objects. A plasma beta parameter ``beta`` controls the ratio of thermal to magnetic pressure if a magnetic field is seeded. The integration grid is specified by ``nlayers``, ``nrings``, ``r_in``, ``r_out``, and ``zmax``.

The setup has been used in Nealon et al. (2018) to study GR-driven precession in inclined thick discs.

Physical & Mathematical Description
------------------------------------

The Papaloizou-Pringle torus has a density profile :math:`\rho \propto [\lambda/r - 1/(2r^2) - \Phi_c]^n` where :math:`\lambda` is a constant related to the specific angular momentum, :math:`r` is the cylindrical radius, :math:`\Phi_c` is the central gravitational potential, and :math:`n` is the polytropic index. The pressure is :math:`P = K \rho^{1+1/n}`. The Zurek & Benz (1986) generalisation extends this to include self-gravity. The torus is unstable to the PPI when :math:`R_\mathrm{out}/R_\mathrm{in} \gtrsim 3` and the MRI when :math:`\beta_p < (4/3) \pi / (q \ln(R_\mathrm{out}/R_\mathrm{in}))` for differential rotation :math:`\Omega \propto r^{-q}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_torus.f90`` for the complete source.
