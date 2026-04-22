.. phantom-doc: hand-written

density_profiles
================

Overview
--------

The ``density_profiles`` module collects analytic and semi-analytic
density profiles used to initialise stellar, cloud, and collapse
simulations in Phantom.  Each profile is a Fortran function that returns
:math:`\rho(r)` given a radial coordinate and a small set of parameters;
the functions are passed as procedure arguments to ``set_sphere`` or
``stretchmap`` so that the particle layout can be stretched to match any
supported profile without modifying the placement code.

The available profiles are: uniform density, polytrope (integrated from
the Lane-Emden equation), piecewise polytrope (for neutron-star EOSs),
Evrard collapse (Evrard 1988, MNRAS 235, 911), and the Bonnor–Ebert
sphere.  The module also provides ``rho_func`` and ``mass_func``
procedure interfaces so that user-supplied profiles can be plugged in
without any changes to the core modules.

Physical & Mathematical Description
------------------------------------

The **polytrope** profile is obtained by numerically integrating the
dimensionless Lane–Emden equation

.. math::

   \frac{1}{\xi^2}\frac{d}{d\xi}\!\left(\xi^2\frac{d\theta}{d\xi}\right)
   = -\theta^n, \qquad \theta(0)=1,\quad \theta'(0)=0,

where :math:`\rho = \rho_c\,\theta^n` and the polytropic index is
:math:`n = 1/(\gamma-1)`.  Integration stops at the first zero of
:math:`\theta`, which defines the stellar surface.

The **Evrard collapse** profile is

.. math::

   \rho(r) = \frac{M}{2\pi r R^2}, \qquad r \leq R,

which diverges as :math:`r\to 0` and provides a standard benchmark for
SPH self-gravity codes (Evrard 1988).

The **Bonnor–Ebert sphere** is an isothermal sphere in hydrostatic
equilibrium confined by an external pressure; it is computed by
integrating the dimensionless Lane–Emden equation for :math:`n = \infty`
(isothermal case) and truncating at the critical Bonnor–Ebert radius.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/density_profiles.f90
