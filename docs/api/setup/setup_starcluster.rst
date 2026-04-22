.. phantom-doc: hand-written

setup_starcluster
=================

Overview
--------

``setup_starcluster`` initialises a star cluster in which N stars are represented as sink particles with positions drawn from a Plummer or King profile and velocities consistent with virial equilibrium. The stellar masses, sink radii, and positions are read from an external data file (default ``clusterbin.txt``) following the format of Paumard et al. (2006). Gas particles can optionally be injected at run time to model stellar winds.

Key runtime parameters include the gas mass resolution ``m_gas`` in solar masses, which sets the particle mass for any associated wind material, and the sink radius ``h_sink`` in parsecs. The setup is used for galactic centre simulations (in collaboration with Jorge Cuadra) where a dense nuclear star cluster of Wolf-Rayet and OB stars injects wind gas into the region around Sgr A*, as well as for general open cluster and globular cluster dynamics.

Unlike ``setup_cluster`` (which starts from a gas cloud), ``setup_starcluster`` begins with already-formed stars, making it suitable for studying the dynamical evolution of an existing cluster rather than its formation.

Physical & Mathematical Description
------------------------------------

A Plummer sphere has density profile :math:`\rho(r) = (3M/4\pi a^3)(1 + r^2/a^2)^{-5/2}` and potential :math:`\Phi(r) = -GM/\sqrt{r^2 + a^2}`, where :math:`a` is the Plummer scale radius. The projected half-mass radius is :math:`R_{1/2} \approx 1.305 a`. The velocity dispersion is :math:`\sigma^2 = GM/(6a)` in the isotropic case. The virial ratio :math:`\eta = 2 E_\mathrm{kin} / |E_\mathrm{pot}|` is set to 1 for a virialized cluster and :math:`<1` for a collapsing cluster.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_starcluster.f90`` for the complete source.
