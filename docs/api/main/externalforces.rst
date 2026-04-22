.. phantom-doc: hand-written

externalforces — Master Dispatcher for External Body Forces
============================================================

Overview
--------

The ``externalforces`` module is the central dispatcher for all external (body)
forces and potentials in Phantom.  Every force that is not computed from
particle–particle SPH interactions is routed through the single entry point
``externalforce``.  A companion entry point ``externalforce_vdependent`` handles
velocity-dependent forces that require implicit treatment in the leapfrog integrator,
and ``update_vdependent_extforce`` performs the required matrix inversion at the
corrector step.

The active force type is selected at runtime by the integer parameter
``iexternalforce``.  Seventeen distinct external forces are enumerated by named
integer constants ``iext_star`` through ``iext_geopot``.  The dispatcher uses a
Fortran ``select case`` to delegate to the appropriate sub-module:
:doc:`extern_binary`, :doc:`extern_corotate`, :doc:`extern_prdrag`,
:doc:`extern_gnewton`, :doc:`extern_spiral`, :doc:`extern_densprofile`,
:doc:`extern_Bfield`, :doc:`extern_staticsine`, :doc:`extern_gwinspiral`,
:doc:`extern_geopot`, and :doc:`extern_lensethirring`.

The module also owns the softened central-mass potential (``iext_star``), providing
Plummer-softened point-mass gravity with softening length ``eps_soft``, and the
particle-accretion machinery: ``accrete_particles`` tests whether a particle has
crossed an accretion boundary, ``was_accreted`` identifies previously accreted
particles by their negative smoothing length, and accumulated accreted masses
``accretedmass1`` / ``accretedmass2`` are tracked across restarts.

The ``update_externalforce`` routine is called once per global timestep to update
time-dependent forces such as the orbital phase of a binary system or the
gravitational-wave radiation-reaction force.

Physical & Mathematical Description
-------------------------------------

For the central point-mass potential (``iext_star``, ``iext_lensethirring``,
``iext_geopot``) the acceleration and potential are

.. math::

   \mathbf{f}_\mathrm{ext} = -\frac{M_1\,\mathbf{r}}{(r^2 + \epsilon^2)^{3/2}},
   \qquad
   \Phi = -\frac{M_1}{\sqrt{r^2 + \epsilon^2}},

where :math:`\epsilon = \texttt{eps\_soft}` is the Plummer softening length and
:math:`M_1 = \texttt{mass1}`.  Without softening this reduces to the standard
Newtonian inverse-square law.

**Timestep from external force**

When the optional argument ``dtf`` is requested, the timestep is estimated as

.. math::

   \Delta t_\mathrm{ext}
   = \min\!\left(\sqrt{\frac{h}{|\mathbf{f}|}},\;
                 \sqrt{\frac{|\Phi|}{|\mathbf{f}|^2}}\right),

providing both an acceleration-based and a potential-based safety criterion.

**Velocity-dependent forces**

Forces that depend on particle velocity — including the Coriolis force
(:doc:`extern_corotate`), Lense–Thirring precession (:doc:`extern_lensethirring`),
Poynting–Robertson drag (:doc:`extern_prdrag`), and the generalised-Newtonian force
(:doc:`extern_gnewton`) — are treated implicitly.  At the leapfrog corrector step
the system

.. math::

   \mathbf{v}^1 = \mathbf{v}^{1/2}
                  + \tfrac{1}{2}\Delta t\,
                    \bigl[\mathbf{f}_\mathrm{SPH}
                          + \mathbf{f}_\mathrm{ext}(\mathbf{x}^1, \mathbf{v}^1)\bigr]

is solved for :math:`\mathbf{v}^1` via a :math:`3\times 3` matrix inversion
implemented in each sub-module.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/externalforces.f90
