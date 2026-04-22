.. phantom-doc: hand-written

extern_binary — Newtonian Point-Mass Binary Gravitational Potential
====================================================================

Overview
--------

The ``extern_binary`` module computes the gravitational force and potential from a
central binary system modelled as two Newtonian point masses in a circular orbit.
It is used when ``iexternalforce = iext_binary`` or ``iext_corot_binary``.  The
implementation was originally written by Graham Wynn and later adapted for Phantom.

The two stellar masses :math:`M_1` and :math:`M_2` orbit their common centre of mass
with unit semi-major axis and angular frequency :math:`\omega = 1` in code units.  The
orbital positions are updated once per timestep in ``update_binary`` — which calls
``sin`` and ``cos`` only once for computational efficiency — and stored as module-level
variables.  The routine ``binary_force`` then evaluates the Plummer-softened
gravitational acceleration at an arbitrary particle position.

An optional mass-ramp feature (``ramp = .true.``) gradually switches on the secondary
mass :math:`M_2` over the first ``tramp_orbits`` orbital periods to avoid an
impulsive start.  An optional surface-force mode (``surface_force = .true.``) replaces
the softened potential near the secondary with a repulsive surface force, useful for
modelling planetary interiors.

The module tracks accreted mass via ``accretedmass1`` and ``accretedmass2``, which are
accumulated whenever a particle falls within the accretion radii ``accradius1`` or
``accradius2``.  These quantities are checkpointed to the dump-file header via
``write_headeropts_externbinary`` / ``read_headeropts_externbinary``.

Physical & Mathematical Description
-------------------------------------

The binary positions at time :math:`t` are

.. math::

   \mathbf{x}_1 = -\frac{M_2}{M_1+M_2}
                   \begin{pmatrix}\cos t \\ \sin t \\ 0\end{pmatrix},
   \qquad
   \mathbf{x}_2 = +\frac{M_1}{M_1+M_2}
                   \begin{pmatrix}\cos t \\ \sin t \\ 0\end{pmatrix},

where the total mass :math:`M = M_1 + M_2` and the code unit period is
:math:`2\pi`.  The gravitational acceleration and potential at a gas particle
position :math:`\mathbf{r}` are

.. math::

   \mathbf{f} = -\frac{M_1(\mathbf{r}-\mathbf{x}_1)}{(|\mathbf{r}-\mathbf{x}_1|^2
                 + \epsilon_1^2)^{3/2}}
                -\frac{M_2(\mathbf{r}-\mathbf{x}_2)}{(|\mathbf{r}-\mathbf{x}_2|^2
                 + \epsilon_2^2)^{3/2}},

.. math::

   \Phi = -\frac{M_1}{\sqrt{|\mathbf{r}-\mathbf{x}_1|^2+\epsilon_1^2}}
           -\frac{M_2}{\sqrt{|\mathbf{r}-\mathbf{x}_2|^2+\epsilon_2^2}},

where :math:`\epsilon_{1,2}` = ``eps_soft1``, ``eps_soft2`` are the Plummer
softening lengths.

**Mass ramp**

When ``ramp = .true.`` the effective secondary mass used in force evaluations is

.. math::

   M_2^\mathrm{eff}(t) = M_2\,\sin^2\!\left(\frac{\pi t}{2 N_\mathrm{ramp} P}\right),
   \quad t < N_\mathrm{ramp} P,

where :math:`P = 2\pi` is the orbital period and :math:`N_\mathrm{ramp}` =
``tramp_orbits``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_binary.f90
