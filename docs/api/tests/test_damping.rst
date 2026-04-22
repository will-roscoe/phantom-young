.. phantom-doc: hand-written

test_damping
============

Overview
--------

The ``test_damping`` module (Fortran module ``testdamping``) contains unit tests for the
wave-damping boundary layer routines used in disc simulations. Damping zones at the inner
and outer edges of a protoplanetary disc suppress artificial reflections from boundary
particles; this module verifies that the damping factor applied to each particle velocity
follows the prescribed radial profile correctly.

The test activates the disc damping mode (``idamp = 3``), sets the inner and outer
boundary radii to known values, and then evaluates ``get_damp_fac_disc`` at four sentinel
positions — the inner edge of the inner zone, the outer edge of the outer zone, and the
boundaries between damped and undamped regions. At each position the test checks that the
damping timescale is the correct multiple of the local Keplerian orbital period, comparing
to an analytic result with a tight absolute tolerance of :math:`3\times10^{-16}`.

The module is self-contained and requires no particle data: all checks are made on the
scalar damping factor as a function of radius, making it fast and robust across different
build configurations.

Physical & Mathematical Description
------------------------------------

The disc damping boundary condition damps each velocity component toward a target value at
rate :math:`1/t_{\rm damp}`, where :math:`t_{\rm damp} = \xi\,t_{\rm orb}(r)` and
:math:`\xi` is the ``damp`` parameter (here set to 0.01). At the sentinel radii the
damping factor ``fac`` must equal :math:`1/({\rm damp} \cdot \Omega(r))` where
:math:`\Omega(r) = r^{-3/2}` for a Keplerian disc. The tolerance used is
:math:`3\times10^{-16}`, consistent with double-precision round-off.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_damping.f90
