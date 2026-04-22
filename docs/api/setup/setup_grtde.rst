.. phantom-doc: hand-written

setup_grtde
===========

Overview
--------

``setup_grtde`` configures a general-relativistic tidal disruption event (TDE) simulation in which a star (or pair of stars) on a parabolic or elliptical orbit is disrupted by the tidal forces of a Kerr black hole. The black hole mass ``mhole``, the stellar penetration factor ``beta``, the orbital eccentricity ``ecc_bh``, and the initial separation in tidal radii ``sep_initial`` are all runtime parameters. The stellar model is built with ``setstar`` and can be a polytrope or a MESA profile.

General-relativistic initial conditions (positions and velocities) can be computed by setting ``use_gr_ic = .true.``, which accounts for the bending of the trajectory in the Kerr metric. The orbital inclination relative to the black hole spin axis is set by ``theta_bh``. For multi-star setups, individual positions and velocities can be specified manually via the ``provide_params`` flag.

This setup underpins GR TDE studies in Phantom, including the formation of the debris stream, the self-intersection shock, and the subsequent disc formation around the black hole.

Physical & Mathematical Description
------------------------------------

The tidal radius :math:`r_t = R_* (M_\bullet / M_*)^{1/3}` marks the onset of disruption; the penetration factor :math:`\beta = r_t / r_p` with periapsis :math:`r_p`. In full GR the orbital trajectory deviates from the Newtonian parabola; the pericenter advance per orbit is :math:`\Delta\phi = 3\pi r_g / r_p` where :math:`r_g = GM_\bullet/c^2`. The most bound debris has specific energy :math:`\epsilon_\mathrm{min} \approx -G M_\bullet R_* / r_t^2`, giving a fallback time :math:`t_\mathrm{min} = \pi G M_\bullet / (2 |\epsilon_\mathrm{min}|)^{3/2}` for the peak accretion rate.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_grtde.f90`` for the complete source.
