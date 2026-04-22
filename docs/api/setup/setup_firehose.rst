.. phantom-doc: hand-written

setup_firehose
==============

Overview
--------

``setup_firehose`` initialises the general-relativistic firehose problem, which models the debris stream from a tidal disruption event (TDE) as a thin, elongated stream of gas falling toward and threading the central black hole. The name "firehose" refers to the stream bending around the black hole like a jet of fluid from a hose. A single sink particle representing the black hole is placed at the origin; gas particles forming the stream are injected at run time.

This setup is intended for GR (Kerr metric) simulations of TDE debris streams where the stream self-intersects due to relativistic apsidal precession. The self-intersection shocks are a key energy dissipation mechanism in the TDE accretion disc formation process. The setup itself is nearly empty (no particles at initialisation, only the sink), analogous to ``setup_empty`` but with specific TDE-oriented units.

Units are set in solar masses and solar radii for stellar-disruption scale problems.

Physical & Mathematical Description
------------------------------------

The apsidal precession angle per orbit for a parabolic trajectory around a Kerr black hole of mass :math:`M_\bullet` and spin :math:`a` depends on the pericenter distance :math:`r_p` as :math:`\Delta\phi \approx 6\pi G M_\bullet / (r_p c^2)` in the weak-field limit. Self-intersection of the debris stream occurs when :math:`\Delta\phi` is of order unity, at :math:`r_p \sim r_g \equiv GM_\bullet/c^2`. The specific orbital energy of the most tightly bound debris is :math:`e_\mathrm{min} \approx -G M_\bullet R_*/r_t^2` where :math:`R_*` is the stellar radius and :math:`r_t` is the tidal radius.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_firehose.f90`` for the complete source.
