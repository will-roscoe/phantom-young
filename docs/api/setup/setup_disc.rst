.. phantom-doc: hand-written

setup_disc
==========

Overview
--------

``setup_disc`` is the primary disc setup module in Phantom. It configures accretion discs around one or two central objects, which may be represented as sink particles or external potentials. Supported configurations include a disc around a single star, circumbinary and circumstellar discs in bound binaries, and circumstellar discs in fly-by (unbound binary) encounters. Gas-only, dust-gas (one-fluid and two-fluid) and embedded-planet configurations are all available.

The surface density profile :math:`\Sigma(R)`, sound speed profile :math:`c_s(R)`, and disc mass are set via the ``set_disc`` module using power-law indices ``p_index`` and ``q_index``. Dust grain sizes and grain densities are specified for multi-species dust calculations, and the dust-to-gas ratio is controlled per species. Planets are added as additional sink particles with prescribed masses and orbital elements.

The disc module is highly parameterised with more than 60 runtime options covering inner and outer edges, aspect ratios, inclinations, viscosity parameters, atmospheric extensions, and turbulence. It is the standard starting point for protoplanetary disc simulations in Phantom.

Physical & Mathematical Description
------------------------------------

The disc surface density follows :math:`\Sigma(R) = \Sigma_0 (R/R_0)^{-p}`, and the locally isothermal sound speed profile is :math:`c_s(R) = c_{s,0} (R/R_0)^{-q}`, giving an aspect ratio :math:`H/R \propto R^{(1/2 - q)}`. The Keplerian angular velocity is :math:`\Omega_K = \sqrt{GM/R^3}`, and the pressure-corrected sub-Keplerian rotation is :math:`v_\phi = v_K \sqrt{1 - (p + q + 3/2)(H/R)^2}`. Dust settling is governed by the Epstein drag stopping time :math:`t_s = \rho_\mathrm{grain} s / (\rho c_s)` where :math:`s` is the grain size. See :cite:`lodatoprice10` for the disc setup methodology.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_disc.f90`` for the complete source.
