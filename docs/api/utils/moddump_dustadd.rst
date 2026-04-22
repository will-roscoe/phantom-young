.. phantom-doc: hand-written

moddump_dustadd
===============

Overview
--------

``moddump_dustadd`` adds dust particles to an existing gas-only Phantom dump, creating a two-fluid dust-gas simulation. Written by Stephane Michoulier, it prompts the user for the number of dust species, grain sizes, grain material densities, and the dust-to-gas ratio, then generates a new set of dust particles mirroring the gas particle distribution.

The routine uses ``set_dust`` to create the dust particle array, positioning each dust particle at the same location as the corresponding gas particle (or at a sub-sampled position if fewer dust particles are desired). The dust particles are assigned the ``idust`` particle type and their masses are computed from the dust-to-gas ratio and the gas particle masses.

This moddump enables dust species to be added to a well-relaxed gas disc without restarting the simulation from scratch, which is particularly useful when testing dust evolution models or when the gas disc has already reached a steady state.

Physical & Mathematical Description
------------------------------------

For a dust-to-gas ratio :math:`\epsilon = \Sigma_d / \Sigma_g`, each dust particle of species :math:`k` has mass :math:`m_{d,k} = \epsilon_k m_g`, where :math:`m_g` is the gas particle mass. The Stokes number of grain species :math:`k` with grain radius :math:`s_k` and material density :math:`\rho_{\mathrm{grain},k}` in a disc with surface density :math:`\Sigma_g` is :math:`\mathrm{St}_k = \pi s_k \rho_{\mathrm{grain},k} / (2 \Sigma_g)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_dustadd.f90`` for the complete source.
