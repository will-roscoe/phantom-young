.. phantom-doc: hand-written

units
=====

Overview
--------

The ``units`` module defines the physical unit system used throughout Phantom. Three
fundamental code units — ``udist`` (length), ``umass`` (mass), and ``utime`` (time) —
are set by ``set_units`` and stored as double-precision module variables. All derived
units (velocity, density, pressure, energy, magnetic field, luminosity, angular
momentum, and opacity) are computed from these three by ``set_units_extra`` and are
available globally once either subroutine has been called.

Simulations may be run in arbitrary units (scale-free mode, the default with
``udist = umass = utime = 1``), physical CGS units, or geometrised units in which
:math:`G = 1` or :math:`c = 1`. The ``set_units`` interface accepts optional keyword
arguments ``dist``, ``mass``, ``time``, ``G``, and ``c``; when ``G=1`` or ``c=1`` is
specified, the third fundamental unit is derived automatically from the constraint
that the gravitational constant or the speed of light equals unity in code units.
Consistency checks are printed as warnings when conflicting over-specifications are
detected.

The module also provides a rich unit-recognition system via ``select_unit`` and
``in_code_units``, which parse strings such as ``'1.5*au'``, ``'10*Myr'``, or
``'solarm'`` and return the corresponding value in CGS or in code units. Helper
functions ``in_solarm``, ``in_solarr``, and ``in_solarl`` convert code-unit quantities
directly to solar mass, solar radius, and solar luminosity. The subroutine
``print_units`` writes a formatted summary of all unit conversions to the log file.

The magnetic field unit convention follows :cite:`pricemonaghan04a`, in which
:math:`\mu_0 = 1` is enforced by choosing an appropriate unit for the charge:

.. math::

   u_q = \sqrt{\frac{u_m \, u_r}{\mu_0^{\mathrm{cgs}}}}

Physical & Mathematical Description
------------------------------------

Given fundamental units :math:`u_r` (length), :math:`u_m` (mass), and :math:`u_t`
(time), all derived units follow by dimensional analysis:

.. math::

   u_v      &= \frac{u_r}{u_t}, \\
   u_\rho   &= \frac{u_m}{u_r^3}, \\
   u_P      &= \frac{u_m}{u_r\,u_t^2}, \\
   u_e      &= u_v^2  \quad (\text{specific energy}), \\
   u_E      &= u_m\,u_v^2 \quad (\text{total energy}), \\
   u_L      &= \frac{u_E}{u_t} \quad (\text{luminosity}), \\
   u_\kappa &= \frac{u_r^2}{u_m} \quad (\text{opacity}), \\
   u_J      &= u_r\,u_m\,u_v \quad (\text{angular momentum}).

The magnetic field unit is derived from the charge unit :math:`u_q` such that
:math:`\mu_0 = 1` in code units (:cite:`pricemonaghan04a`):

.. math::

   u_q      &= \sqrt{\frac{u_m\,u_r}{\mu_0^{\mathrm{cgs}}}}, \\
   u_B      &= \frac{u_m}{u_t\,u_q}
              = \sqrt{\frac{u_m}{\mu_0^{\mathrm{cgs}}\,u_r^3}}\,\frac{u_r}{u_t}.

When :math:`G = 1` is requested and two of the three fundamental units are supplied,
the third is determined from:

.. math::

   u_t = \sqrt{\frac{u_r^3}{G\,u_m}},
   \quad
   u_m = \frac{u_r^3}{G\,u_t^2},
   \quad \text{or} \quad
   u_r = \left(u_t^2\,G\,u_m\right)^{1/3},

where :math:`G` is Newton's constant in CGS. Similarly, when :math:`c = 1`, the
geometric constraint :math:`u_r = u_t\,c` (with :math:`c` the CGS speed of light)
fixes the remaining unit.

The gravitational constant and speed of light in code units are:

.. math::

   G_{\mathrm{code}} = G\,\frac{u_m\,u_t^2}{u_r^3},
   \qquad
   c_{\mathrm{code}} = c\,\frac{u_t}{u_r}.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/units.f90
