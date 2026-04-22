.. phantom-doc: hand-written

viscosity — Physical Shear and Bulk Viscosity
==============================================

Overview
--------

The ``viscosity`` module provides physical (Navier–Stokes) viscosity treatment for
accretion-disc and shearing-flow simulations in Phantom.  It is distinct from the
artificial viscosity that is applied by default in all SPH runs; the routines here
implement explicitly evolved *real* shear and bulk viscosity body forces.

Three operating modes are supported through the integer flag ``irealvisc``.  The
default (``irealvisc = 0``) disables physical viscosity so no computational cost is
incurred in simulations that do not require it.  Constant-kinematic-viscosity mode
(``irealvisc = 1``) sets :math:`\nu = \texttt{shearparam}` uniformly across the
domain.  The Shakura–Sunyaev mode (``irealvisc = 2``) computes
:math:`\nu = \alpha_\mathrm{SS}\,c_s\,H` assuming a Keplerian disc and is the
standard choice for protoplanetary-disc and binary-accretion simulations.  A
supplementary mode (``irealvisc = 3``) extends the Shakura–Sunyaev prescription to
circumbinary discs by computing the local scale height relative to the nearer of two
point masses.

The central public function is ``shearfunc``, which returns the local kinematic shear
viscosity :math:`\nu(x,y,z,c_s)` given a particle position and sound speed.  It is
called once per active particle in the force-evaluation loop and also drives
``dt_viscosity``, which enforces a viscous Courant condition.  The module further
provides ``viscinfo`` for run-time diagnostic output and
``write_options_viscosity`` / ``read_options_viscosity`` for input-file I/O.

Physical & Mathematical Description
-------------------------------------

For an incompressible Newtonian fluid the shear-viscosity contribution to the
momentum equation is

.. math::

   \left(\frac{d\mathbf{v}}{dt}\right)_\mathrm{visc}
   = \nu\,\nabla^2\mathbf{v} + \frac{\nu}{3}\,\nabla(\nabla\cdot\mathbf{v}),

where :math:`\nu` is the kinematic shear viscosity.  An additional bulk-viscosity
term proportional to :math:`\zeta\,\nabla(\nabla\cdot\mathbf{v})` can be activated
via the parameter ``bulkvisc`` (:math:`\zeta`).

**Constant-viscosity mode** (``irealvisc = 1``)

.. math::

   \nu = \texttt{shearparam} = \text{const}.

**Shakura–Sunyaev disc viscosity** (``irealvisc = 2``)

The standard alpha-disc prescription relates the kinematic viscosity to the disc
scale height :math:`H = c_s/\Omega` and the dimensionless Shakura–Sunyaev parameter
:math:`\alpha_\mathrm{SS}`:

.. math::

   \nu = \alpha_\mathrm{SS}\,c_s\,H = \alpha_\mathrm{SS}\,\frac{c_s^2}{\Omega}.

For a Keplerian disc :math:`\Omega = r^{-3/2}` (in code units with :math:`GM = 1`),
which gives

.. math::

   \nu(r,c_s) = \alpha_\mathrm{SS}\,c_s^2\,r^{3/2}.

**Shakura–Sunyaev for circumbinary discs** (``irealvisc = 3``)

The disc scale height is computed relative to the closer of the two binary
companions:

.. math::

   H = \sqrt{K}\,r_\mathrm{min}^{3/2 - q},

where :math:`K` = ``polyk``, :math:`q` = ``qfacdisc``, and
:math:`r_\mathrm{min} = \min(r_1, r_2)` is the distance to the nearest point mass.
The viscosity is then :math:`\nu = \alpha_\mathrm{SS}\,c_s\,H`.

**Viscous Courant condition**

The explicit viscous timestep constraint is

.. math::

   \Delta t_\mathrm{visc} = 0.4\,C_\mathrm{force}\,\frac{h^2}{\nu},

ensuring that diffusion of momentum is resolved on the smoothing-length scale
:math:`h`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/viscosity.f90
