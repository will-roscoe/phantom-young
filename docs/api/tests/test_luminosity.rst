.. phantom-doc: hand-written

test_luminosity
===============

Overview
--------

The ``test_luminosity`` module (Fortran module ``testlum``) tests the per-particle
luminosity tracking and synthetic lightcurve machinery in Phantom. The test requires
both ``track_lum = .true.`` (set unconditionally by ``phantomtest``) and
``ind_timesteps`` to be active; if either condition is not met the test is skipped with
an informational message. It also skips when ``periodic`` is ``.true.`` because the disc
setup used in the test requires non-periodic boundaries.

The test sets up a protoplanetary disc with ``set_disc``, computes one set of SPH
derivatives, and records the total luminosity ``totlum`` along with the total energy
``etot``. After advancing the simulation by a single timestep, it checks that the
luminosity has changed by the expected amount given the energy injected or dissipated
during the step. The relative tolerance ``tol = 2e-5`` reflects both the SPH truncation
error and the time-integration error.

Physical & Mathematical Description
------------------------------------

The synthetic luminosity is defined as the total rate of viscous energy dissipation
summed over all active particles:
:math:`L_{\rm tot} = \sum_i m_i \dot{u}_i^{\rm visc}`,
where :math:`\dot{u}_i^{\rm visc}` is the viscous heating rate computed from the
artificial viscosity switch. The test checks that :math:`|L_{\rm tot,1} - L_{\rm tot,0}|
/ |L_{\rm tot,0}|` is below the tolerance after one leapfrog step, and that energy is
not spontaneously created or destroyed beyond round-off.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_luminosity.f90
