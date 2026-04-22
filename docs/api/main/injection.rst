.. phantom-doc: hand-written

injection
=========

Overview
--------

The ``injection`` module is the top-level wrapper that provides a uniform
interface to whichever particle injection scheme has been compiled into
Phantom. All injection implementations (``inject_wind``, ``inject_BHL``,
``inject_sne``, etc.) define the same Fortran module name ``inject`` and
expose the same public subroutine signatures; only one is compiled into a
given executable at build time. The ``injection`` module wraps these with
``write_options_injection`` and ``read_options_injection``, which prepend
global injection options (such as ``rkill``, the radius beyond which
particles are deactivated) before delegating to the specific module.

The ``rkill`` parameter allows particles injected from one boundary to be
automatically deactivated when they travel beyond a specified radius, which
is useful for wind-tunnel, Bondi-Hoyle-Lyttleton, and wind-injection
setups. When ``rkill < 0`` this feature is disabled. The injection type
string ``inject_type`` is a public character parameter defined in each
implementation module and can be queried to identify which scheme is active.

Physical & Mathematical Description
------------------------------------

This module contains no physics equations; it is purely an interface layer.
The physics of each injection scheme — velocity profiles, density
distributions, angular-momentum injection — is defined in the corresponding
``inject_*`` implementation module. The only physics-adjacent content is the
``rkill`` deactivation condition :math:`r > r_\text{kill}`, applied as a
simple radial distance test on each injected or existing particle.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/injection.f90
