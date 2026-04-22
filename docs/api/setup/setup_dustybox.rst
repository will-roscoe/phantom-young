.. phantom-doc: hand-written

setup_dustybox
==============

Overview
--------

``setup_dustybox`` sets up the dusty-box test of Laibe & Price (2011). A uniform mixture of gas and one dust species is placed in a periodic box; a constant external body force accelerates the gas. The difference in aerodynamic coupling between gas and dust drives a velocity drift between the two fluids that can be compared against the analytic solution, making this the standard test for SPH dust-gas drag implementations.

Both one-fluid (dust fraction) and two-fluid (separate gas and dust particles) representations are supported, selected by the dust module at compile time. The particle lattice type (cubic or close-packed) is chosen by ``ilattice``, and the number of particles in x is ``npartx``. The initial sound speed is set by ``polykset`` and the background density by ``rhozero``.

The box test is intentionally simple — uniform density, no gravity, no boundaries — isolating the drag term from all other physics. Exponential decay of the velocity difference with time constant :math:`t_s` provides a stringent test of the drag integration.

Physical & Mathematical Description
------------------------------------

For a constant body force :math:`f` applied to the gas only, the analytic drift velocity between gas and dust is :math:`\Delta v = f t_s (1 - e^{-t/t_s})`, where :math:`t_s = \rho_\mathrm{grain} s / (\rho c_s)` is the Epstein stopping time. In the terminal-velocity limit :math:`t \gg t_s` the drift saturates at :math:`\Delta v_\infty = f t_s`. For the two-fluid case both gas and dust accelerate together at rate :math:`f \rho_g / (\rho_g + \rho_d)` in the centre-of-mass frame.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_dustybox.f90`` for the complete source.
