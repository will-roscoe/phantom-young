.. phantom-doc: hand-written

timestep
========

Overview
--------
The ``timestep`` module stores the global timestep control parameters and
provides I/O routines for reading and writing them from the Phantom ``.in``
input file. It does not itself compute the timestep; that computation is
distributed across the force and density loops in the ``forces`` and
``densityforce`` modules, which update the module-level variables
``dtcourant``, ``dtforce``, and ``dtrad`` as side effects of the particle
loop.

The module defines the Courant safety factor ``C_cour``, the force safety
factor ``C_force``, and the velocity-error tolerance ``tolv`` used in the
leapfrog corrector iteration. For MHD runs it additionally stores the
hyperbolic divergence-cleaning parameters ``psidecayfac`` and
``overcleanfac``. For general-relativistic runs the position and momentum
iteration tolerances ``xtol`` and ``ptol`` are included.

The chosen timestep at each step is the minimum over all active constraints:

.. math::

   \Delta t = \min(\Delta t_{\rm Courant},\;\Delta t_{\rm force},\;
                   \Delta t_{\rm rad},\;\Delta t_{\rm max}),

where each component is described below. This ensures that neither
compressibility waves nor acceleration-driven displacements exceed safe
fractions of the smoothing length in a single step.

Physical & Mathematical Description
-------------------------------------
**Courant condition.** The SPH Courant timestep for particle :math:`a` is

.. math::
   :label: dt_courant

   \Delta t_{{\rm Courant},a} = C_{\rm cour}\,\frac{h_a}{v_{{\rm sig},a}},

where :math:`h_a` is the smoothing length and :math:`v_{{\rm sig},a}` is the
maximum signal velocity over all neighbour pairs involving particle :math:`a`.
The signal velocity for a pair :math:`(a,b)` is

.. math::

   v_{{\rm sig},ab} = c_{s,a} + c_{s,b} - \beta\,
                      \min\!\left(0,\,
                      (\mathbf{v}_a-\mathbf{v}_b)\cdot\hat{\mathbf{r}}_{ab}\right),

with :math:`\beta` the non-linear viscosity coefficient (default 2). For MHD
the signal velocity includes the fast magnetosonic speed.

**Force condition.** The acceleration timestep is

.. math::
   :label: dt_force

   \Delta t_{{\rm force},a} = C_{\rm force}\sqrt{\frac{h_a}{|\mathbf{f}_a|}},

which limits the displacement due to the acceleration to a fraction of
:math:`h_a`.

**Global maximum.** The parameter ``dtmax`` imposes an upper bound on the
timestep, ensuring regular output regardless of the physical timescale.

**Radiation condition.** When radiation transport is active, an additional
timestep :math:`\Delta t_{\rm rad}` based on the radiation energy equation is
computed with safety factor ``C_rad`` (default 0.8, following Biriukov & Price
2019).

**Velocity-error tolerance.** The scalar ``tolv`` (default :math:`10^{-2}`)
controls when the leapfrog corrector iteration converges. If the maximum
normalised velocity change across all particles exceeds ``tolv``, the corrector
is repeated; if the required timestep from this error criterion ``dterr`` is
smaller than the current step, the timestep is reduced for the next cycle.

**Divergence-cleaning (MHD).** The parameter ``psidecayfac`` sets the ratio
of parabolic to hyperbolic cleaning coefficients, and ``overcleanfac``
multiplies the hyperbolic cleaning speed, decreasing :math:`\Delta t_{\rm
Courant}` by the same factor.

Derivations
-----------
The Courant condition in SPH differs from the classical grid-based form because
the relevant wave-crossing time is :math:`h/v_{\rm sig}` rather than the cell
width divided by the signal velocity. The factor :math:`C_{\rm cour} = 0.3`
is the default; values above approximately 0.5 begin to degrade the accuracy
of the scheme for strongly compressible flows.

The force condition :math:`\Delta t \propto \sqrt{h/|f|}` arises from
requiring that the acceleration-induced displacement in one step is bounded
by a fixed fraction of the smoothing length:

.. math::

   \frac{1}{2}|\mathbf{f}|\Delta t^2 \lesssim C_{\rm force}\,h,
   \qquad
   \Rightarrow\quad \Delta t \lesssim \sqrt{\frac{2\,C_{\rm force}\,h}{|\mathbf{f}|}}.

The factor of 2 is absorbed into ``C_force``.

References
----------
The Courant–Friedrichs–Lewy (CFL) stability condition is the foundational
reference for the Courant timestep constraint: Courant, Friedrichs & Lewy
(1928), Mathematische Annalen 100, 32–74 (not yet in phantom.bib — citation
key needed). The SPH-specific formulation of the Courant and force conditions
is discussed in :cite:`price12`.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/timestep.f90
