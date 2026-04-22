.. phantom-doc: hand-written

test_sedov
==========

Overview
--------

The ``test_sedov`` module (Fortran module ``testsedov``) performs an end-to-end
integration test using the Sedov-Taylor blast wave, one of the canonical benchmarks for
compressible hydrodynamics codes. The test requires ``-DPERIODIC`` because the blast wave
is initialised in a periodic box; without that flag the test is skipped. A uniform
particle distribution is set up in a cube, a point blast is injected at the centre, and
the code is evolved using the full production ``evol`` loop until the blast wave reaches
a prescribed radius.

At the final time the code compares the total energy and total momentum against their
initial values. The energy error ``|(E_{\rm tot} - E_{\rm tot,0})/E_{\rm tot,0}|`` must
be below a tolerance that accounts for the artificial viscosity dissipation and the
periodic boundary effects. The momentum error must be below machine precision because the
blast is spherically symmetric and no external forces act. The test also writes a dump
file that can be used for post-processing visualisation.

Physical & Mathematical Description
------------------------------------

The Sedov-Taylor self-similar solution predicts a blast-wave radius
:math:`R(t) = \xi_0 (E/\rho_0)^{1/5} t^{2/5}` where :math:`\xi_0 \approx 1.033` for
:math:`\gamma = 5/3` and :math:`E` is the blast energy. The test checks global energy
conservation rather than the detailed density profile, requiring
:math:`|(E_{\rm tot} - E_{\rm blast})/E_{\rm blast}|` to be below 5% at the final time.
Total momentum conservation is checked to within :math:`10^{-14}` (machine precision for
a symmetric setup).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_sedov.f90
