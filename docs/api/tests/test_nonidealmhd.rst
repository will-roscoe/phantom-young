.. phantom-doc: hand-written

test_nonidealmhd
================

Overview
--------

The ``test_nonidealmhd`` module (Fortran module ``testnimhd``) tests the three
non-ideal MHD resistivity mechanisms in Phantom: Ohmic resistivity, the Hall effect, and
ambipolar diffusion. These are computed by the NICIL library; the tests do not verify
NICIL's internal calculations but instead check that the Phantom interface to NICIL
returns physically plausible resistivity coefficients and that the resistive MHD
equations conserve the appropriate quantities when integrated numerically.

The module selects sub-tests via the string argument: ``wavedamp`` tests damping of
an Alfvén wave by Ohmic and ambipolar diffusion against the analytic decay rate, ``nimhdshock``
compares the numerical C-shock structure against the semi-analytic solution, and ``nimhdeta``
checks that the resistivity coefficients returned by NICIL are monotonically well-behaved
as functions of density and temperature. The full suite is run when the string argument is
``'all'``. All sub-tests require the ``mhd_nonideal`` flag; if it is absent the test is
skipped.

Physical & Mathematical Description
------------------------------------

For the wave-damping test, an Alfvén wave with wavenumber :math:`k` and Ohmic resistivity
:math:`\eta_{\rm O}` should decay as :math:`B(t) = B_0 \exp(-\eta_{\rm O} k^2 t)`. The
test checks the wave amplitude after integration for several decay times against this
analytic expression, with a relative tolerance of approximately :math:`10^{-3}`. For the
resistivity coefficients the test verifies that :math:`\eta_{\rm O} \geq 0`,
:math:`\eta_{\rm A} \geq 0`, and that the Hall coefficient :math:`\eta_{\rm H}` has the
expected sign and magnitude for a given ionisation fraction.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_nonidealmhd.f90
