.. phantom-doc: hand-written

damping
=======

Overview
--------
The ``damping`` module provides artificial velocity damping for use in
relaxation, equilibration, and wave-boundary-condition problems in Phantom.
When active, a drag-like term is added to the external force on each particle,
driving its velocity toward a prescribed target (usually zero or the local
Keplerian velocity). Three distinct damping modes are available, selected by
the integer flag ``idamp``.

**Mode 0 (off):** no damping is applied. This is the default.

**Mode 1 (constant):** a uniform damping rate ``damp`` is applied to all
particles at every timestep. The target velocity is zero. This is the simplest
approach and is used when relaxing a particle distribution to hydrostatic
equilibrium without a preferred rotation axis. It is analogous to the damping
described in Gingold & Monaghan (1977, MNRAS 181, 375) and their successors.

**Mode 2 (stellar damping):** a time-dependent damping schedule designed for
stellar equilibration problems, following Reichardt et al. (2019, MNRAS 484,
631). The damping rate is held at a maximum for the first two dynamical
timescales :math:`\tau_{\rm dyn}` of the star, then exponentially reduced
over three more dynamical timescales, reaching zero after five dynamical
timescales. This schedule is now largely superseded by the relax-o-matic
routines; see González-Bolívar et al. (2022, MNRAS 517, 3181).

**Mode 3 (disc damping):** spatially localised damping zones at the inner and
outer boundaries of an accretion disc, within the radial ranges
:math:`[r_{1,{\rm in}}, r_{2,{\rm in}}]` and
:math:`[r_{1,{\rm out}}, r_{2,{\rm out}}]`. The target velocity within the
damping zones is the local Keplerian orbital velocity. This mode is used to
absorb tidal and pressure waves near the disc edges and prevent unphysical
reflection.

Physical & Mathematical Description
-------------------------------------
In all active modes the damping is implemented as a modification to the
external acceleration:

.. math::
   :label: damp_force

   \mathbf{f}_a^{\rm damp} = -f_{\rm damp}\,\gamma(\mathbf{r}_a)
                              \,(\mathbf{v}_a - \mathbf{v}_0(\mathbf{r}_a)),

where :math:`f_{\rm damp}` is the damping rate (units of inverse time),
:math:`\mathbf{v}_0` is the target velocity, and :math:`\gamma` is a
dimensionless spatial profile factor.

For mode 1, :math:`f_{\rm damp} = \texttt{damp}`, :math:`\mathbf{v}_0 = 0`,
and :math:`\gamma = 1` everywhere.

For mode 2, the time-dependent damping rate is

.. math::

   f_{\rm damp}(t) = \begin{cases}
     \tau_1^{-1} & t \leq 2\,\tau_{\rm dyn}, \\[4pt]
     \left[\tau_1\!\left(\dfrac{\tau_2}{\tau_1}\right)^{\!\!(t - 2\tau_{\rm dyn})/(3\tau_{\rm dyn})}\right]^{-1}
        & 2\,\tau_{\rm dyn} < t \leq 5\,\tau_{\rm dyn}, \\[4pt]
     0 & t > 5\,\tau_{\rm dyn},
   \end{cases}

where :math:`\tau_{\rm dyn} = \texttt{tdyn\_s}/\texttt{utime}` is the stellar
dynamical timescale in code units, :math:`\tau_1 = 0.1\,\tau_{\rm dyn}`, and
:math:`\tau_2 = \tau_{\rm dyn}`.

For mode 3, the spatial profile at cylindrical radius :math:`R = (x^2+y^2)^{1/2}`
is a smooth polynomial taper:

.. math::
   :label: disc_damp_fac

   \gamma(R) = \begin{cases}
     1 - \sin^2\!\!\left[\dfrac{\pi}{2}
         \dfrac{R - r_{1,{\rm in}}}{r_{2,{\rm in}} - r_{1,{\rm in}}}\right]
       & R < r_{2,{\rm in}}, \\[6pt]
     \sin^2\!\!\left[\dfrac{\pi}{2}
         \dfrac{R - r_{1,{\rm out}}}{r_{2,{\rm out}} - r_{1,{\rm out}}}\right]
         \sqrt{\left(\dfrac{r_{1,{\rm in}}}{r_{2,{\rm out}}}\right)^3}
       & R > r_{1,{\rm out}}, \\[6pt]
     0 & \text{otherwise,}
   \end{cases}

with the Keplerian target velocity (using :math:`G = M = 1`)

.. math::

   \mathbf{v}_0(x,y) = \frac{\sqrt{1/R^3}}{R}(-y,\,x,\,0).

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/damping.f90
