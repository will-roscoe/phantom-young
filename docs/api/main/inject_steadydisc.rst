.. phantom-doc: hand-written

inject_steadydisc
=================

Overview
--------

The ``inject_steadydisc`` module (module name ``inject``,
``inject_type = 'steadydisc'``) implements open radial boundary conditions for
an accretion disc by re-injecting particles that leave the inner or outer
boundary zones back into those zones according to the original disc profile.
When a particle drifts outside the active disc region it is flagged; on the
next injection call it is replaced by a fresh particle drawn from the disc
surface density and velocity profile via the ``setdisc`` routine. This ensures
the disc maintains a steady-state structure without artificial edge effects.

The module requires ``idamp = 3`` (wave-damping boundary conditions) to be
enabled so that the re-injected material is damped smoothly into the flow.
The single runtime parameter ``refill_boundaries`` (default true) can be
set to false to turn off re-injection and allow particles to simply drain
through the boundary.

Physical & Mathematical Description
------------------------------------

The boundary zones are defined by four radii: the inner wave-damping zone
:math:`[r_\text{1,in}, r_\text{2,in}]` and the outer wave-damping zone
:math:`[r_\text{1,out}, r_\text{2,out}]`, taken from the ``damping`` module.
When a particle at radius :math:`r` satisfies :math:`r < r_\text{1,in}` or
:math:`r > r_\text{2,out}` it is added to the respective boundary list. At
each injection call, particles on the boundary lists are reassigned positions
and velocities consistent with the disc equilibrium profile

.. math::

   \Sigma(r) = \Sigma_\text{ref} \left(\frac{r}{R_\text{ref}}\right)^{-p},
   \quad v_\phi(r) = \sqrt{\frac{G M_\star}{r}} \left(1 - (p+q)(H/r)^2\right)^{1/2},

where :math:`p` and :math:`q` are the surface density and sound speed
power-law indices read from the disc parameter file. The velocity correction
accounts for sub-Keplerian rotation due to radial pressure support.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
