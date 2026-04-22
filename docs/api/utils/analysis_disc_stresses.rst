.. phantom-doc: hand-written

analysis_disc_stresses
======================

Overview
--------

``analysis_disc_stresses`` provides a detailed analysis of stress tensor components and thermodynamic properties in a protoplanetary disc, adapted by Rebecca Nealon and extended for variable :math:`\gamma` and :math:`\mu` by Adrian Krause-Yesuda. It uses neighbour lists to compute SPH density gradients and stresses, and bins the results into ``nbins`` radial annuli.

The routine computes Reynolds stress :math:`\alpha_\mathrm{Reyn}`, gravitational stress :math:`\alpha_\mathrm{grav}`, magnetic stress :math:`\alpha_\mathrm{mag}`, and artificial viscosity stress :math:`\alpha_\mathrm{art}`, together with radial profiles of temperature, Toomre :math:`Q`, and cooling time :math:`t_\mathrm{cool}`. The midplane optical depth :math:`\tau_\mathrm{mid}` is also computed when the Stamatellos cooling scheme is active.

The bin width ``dr`` and radial extent ``rin`` to ``rout`` are read from a parameter file. The output files (one per stress component) allow a complete breakdown of angular momentum transport mechanisms in the disc.

Physical & Mathematical Description
------------------------------------

The dimensionless Shakura-Sunyaev stress tensor components are normalised as :math:`\alpha_X = T_{r\phi}^X / (\rho c_s^2)`, where :math:`T_{r\phi}^X` is the relevant stress component (Reynolds, Maxwell, gravitational, or artificial). The Toomre stability parameter is :math:`Q = c_s \Omega / (\pi G \Sigma)`, with :math:`Q < 1` indicating gravitational instability.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_disc_stresses.f90`` for the complete source.
