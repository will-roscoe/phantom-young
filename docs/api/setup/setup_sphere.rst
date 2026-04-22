.. phantom-doc: hand-written

setup_sphere
============

Overview
--------

``setup_sphere`` builds a simple collapsing gas sphere for star formation and stellar evolution simulations. A uniform sphere of mass ``M_cloud`` (in solar masses) and radius ``R_cloud`` (in astronomical units) is populated with SPH particles using ``set_sphere``. An isothermal or barotropic equation of state is selected by ``ieos_in``, and the mean molecular weight ``mu`` and initial temperature ``Temperature`` set the thermal state. Open boundary conditions are used (not periodic), making it suitable for isolated cloud collapse.

This setup is simpler than ``setup_cluster`` — there is no turbulent velocity field — and is intended for studying the Jeans instability, the opacity limit for fragmentation, and the formation of a central protostellar object from a thermally supported cloud. Sink particles are created on the fly when the Jeans criterion is violated, representing newly formed protostars.

The setup follows the classic scenario of Boss & Myhill (1992) and similar collapse calculations, with the free-fall time :math:`t_\mathrm{ff}` as the fundamental timescale.

Physical & Mathematical Description
------------------------------------

The free-fall timescale for a uniform sphere is :math:`t_\mathrm{ff} = \sqrt{3\pi / (32 G \rho_0)}` where :math:`\rho_0 = 3M/(4\pi R^3)` is the mean density. The Jeans mass at the initial conditions is :math:`M_J = (\pi k_B T / G \mu m_p)^{3/2} / \rho_0^{1/2}`, and fragmentation occurs if :math:`M_\mathrm{cloud} > M_J`. The critical ratio of rotational to gravitational energy :math:`\beta_r = E_\mathrm{rot}/|E_\mathrm{grav}|` determines whether the collapse forms a single object or a binary.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_sphere.f90`` for the complete source.
