.. phantom-doc: hand-written

test_wind
=========

Overview
--------

The ``test_wind`` module (Fortran module ``testwind``) tests the stellar wind injection
module in Phantom, which models a continuous flow of gas from a sink particle outward into
the simulation domain. The test requires that the code be compiled with the wind injection
module (``inject_type = 'wind'``) and runs only in serial (it is skipped in MPI mode).
Units are set to AU and solar mass; a cubic boundary of half-width 50 AU is established.

The test drives the wind injector for a prescribed number of timesteps and then checks
that the total number of injected particles is consistent with the specified mass injection
rate :math:`\dot{M}`, the injection velocity, and the elapsed time. Two primary scenarios
are tested: a spherical Keplerian-disc wind (``testcyl``) and a 3D wind with radiation
pressure and nucleation enabled (``testkd``), when those compile-time flags are present.
The test verifies that the cumulative injected mass and kinetic energy are within the
prescribed tolerances ``eps_sum = 4e-14``.

Physical & Mathematical Description
------------------------------------

The mass injection rate check requires that
:math:`M_{\rm injected} = \dot{M}\,\Delta t_{\rm inject}\,N_{\rm steps}` to within one
particle mass. The kinetic energy check verifies that
:math:`E_{\rm kin} = \tfrac{1}{2} M_{\rm injected} v_{\rm wind}^2` to within the
tolerance set by the number of injected particles and the wind speed. Both checks use
absolute tolerances consistent with the particle mass and the floating-point precision of
the injection algorithm.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_wind.f90
