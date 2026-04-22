.. phantom-doc: hand-written

bondiexact
==========

Overview
--------

The ``bondiexact`` module computes the analytic Bondi accretion (or wind)
solution for non-relativistic spherical flow onto (or away from) a point
mass. It is used primarily as a test and validation tool: Phantom simulations
of spherical accretion or stellar winds can be compared directly against the
exact steady-state profile returned by this module.

The single public subroutine ``get_bondi_solution`` accepts the radius
``r``, the gravitational mass ``mass``, and the adiabatic index ``gamma`` and
returns the density, radial velocity, and internal energy at that radius. The
module handles both the accretion branch (``iswind = .false.``) and the
wind-outflow branch (``iswind = .true.``), and supports two solution types
controlled by ``isol``. The critical (sonic) radius ``rcrit`` and the density
at the critical point ``rhocrit`` are stored as module-level variables.

The Lambert W function — needed to invert the implicit algebraic equation
relating radius to velocity in the Bondi solution — is evaluated using the
analytic approximations from Barry, Parlange & Li (2000) for both the
principal branch (for :math:`r \geq r_c`) and the :math:`k=-1` branch (for
:math:`r < r_c`).

Physical & Mathematical Description
------------------------------------

The non-relativistic Bondi solution is the unique steady, spherically
symmetric transonic flow of a polytropic ideal gas in the gravitational
potential of a point mass :math:`M`. Conservation of mass flux
:math:`\dot{M} = 4\pi r^2 \rho |v_r| = \text{const}` combined with the
Euler equation yields an implicit relation between the radial velocity and
radius. At the sonic (critical) radius :math:`r_c = GM/(2c_{s,c}^2)` the
flow passes smoothly through the sound speed. The velocity profile satisfies

.. math::

   \left(\frac{v_r}{c_{s,c}}\right)^2 - \ln\!\left(\frac{v_r}{c_{s,c}}\right)^2
   = 4\ln\frac{r}{r_c} + 4\frac{r_c}{r} - 3,

which is solved via the Lambert W function. The standard Bondi accretion rate
is :math:`\dot{M} = 4\pi \lambda_c \rho_\infty (GM)^2 / c_{s,\infty}^3`
where :math:`\lambda_c` is a dimensionless factor that depends on
:math:`\gamma`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/bondiexact.f90
