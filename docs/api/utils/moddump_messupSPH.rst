.. phantom-doc: hand-written

moddump_messupSPH
=================

Overview
--------

``moddump_messupSPH`` deliberately corrupts the particle distribution in an existing Phantom dump by applying random displacements to particle positions, simulating a "glass-breaking" perturbation. It uses routines from the MCFOST ``mess_up_SPH`` module to introduce controlled disorder into the particle positions while approximately preserving the density field.

The user is prompted for the perturbation amplitude and the perturbation radius (within which to apply the displacement). Sink particles within the perturbed region can optionally be removed. This moddump is used to test the sensitivity of SPH results to particle noise and to generate initial conditions for testing convergence of SPH grid alignment artefacts.

The perturbation preserves the total mass and centre of mass of the system but introduces Monte Carlo noise into the particle positions, which the SPH density estimate will smooth out after a few dynamical times.

Physical & Mathematical Description
------------------------------------

Each particle position is perturbed as :math:`\mathbf{r}_i \leftarrow \mathbf{r}_i + \Delta\mathbf{r}_i`, where :math:`\Delta\mathbf{r}_i` is a random displacement drawn from a uniform distribution within a sphere of radius :math:`\xi h_i`, with :math:`\xi` the perturbation amplitude parameter. The SPH density estimate after perturbation is :math:`\rho_i \approx \rho_i^\mathrm{orig}(1 + \mathcal{O}(\xi^2))` since the SPH kernel smooths out displacements smaller than the smoothing length.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_messupSPH.f90`` for the complete source.
