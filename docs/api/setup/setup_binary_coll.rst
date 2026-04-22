.. phantom-doc: hand-written

setup_binary_coll
=================

Overview
--------

``setup_binary_coll`` sets up the collision or close encounter of two stars near a black hole. The black hole is represented by a Kerr metric (using the ``metric`` module) and the two stellar components are built with ``setstar``. The trajectory parameters — penetration factor ``beta``, eccentricity ``ecc``, impact parameter, and initial separation — determine whether the encounter is a parabolic tidal disruption, a hyperbolic flyby, or a bound binary in-spiral.

The initial positions and velocities of the stars can be provided manually or computed automatically from the orbital parameters, with an option ``use_gr_ic`` to apply general-relativistic initial condition corrections appropriate for strong-gravity regimes near the black hole. The code also supports starting the simulation at periapsis or at a specified pre-pericenter distance.

This setup is used to study the dynamics of binary stellar tidal disruption events (TDEs), where the bound-unbound splitting of the two stars by the tidal field of the black hole can produce exotic debris streams differing from single-star TDEs.

Physical & Mathematical Description
------------------------------------

The tidal disruption radius for a star of mass :math:`M_*` and radius :math:`R_*` encountering a black hole of mass :math:`M_\bullet` is :math:`r_t = R_* (M_\bullet / M_*)^{1/3}`. The penetration factor :math:`\beta = r_t / r_p`, where :math:`r_p` is the periapsis distance, quantifies how deeply the star penetrates the tidal field. For :math:`\beta \gtrsim 1` the star is fully disrupted; the two stars in a binary encounter can be split into bound and unbound components by the differential tidal force across the binary separation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_binary_coll.f90`` for the complete source.
