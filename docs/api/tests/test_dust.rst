.. phantom-doc: hand-written

test_dust
=========

Overview
--------

The ``test_dust`` module (Fortran module ``testdust``) provides unit tests for the
dust-gas drag physics in Phantom, exercising both the two-fluid and one-fluid (dusty-gas)
drag implementations. The module requires the code to be compiled with ``-DDUST``; if the
flag is absent the test is skipped gracefully. The primary sub-test evaluates the drag
stopping time :math:`t_s` returned by ``get_ts`` for a range of grain sizes and gas
densities spanning the Epstein and Stokes drag regimes, comparing against the analytic
Epstein formula.

A second sub-test, ``test_dustybox``, is exported for reuse by the ``test_growth`` module.
It sets up a 3D periodic box of gas and dust particles, applies a relative drift velocity,
and integrates the system for several stopping times using the global leapfrog integrator.
The test then verifies that the relative velocity decays exponentially as
:math:`|\delta \mathbf{v}| \propto e^{-t/t_s}` and that the centre-of-mass velocity is
conserved to machine precision. When dust growth is enabled (``-DDUSTGROWTH``), additional
checks confirm that grain size evolution does not break the drag calculation.

Physical & Mathematical Description
------------------------------------

In the Epstein regime the stopping time is :math:`t_s = \rho_{\rm grain} s / (\rho_{\rm
gas} c_s)` where :math:`s` is grain radius and :math:`c_s` is the sound speed. The test
evaluates ``get_ts`` over a grid of :math:`\rho_{\rm gas}` and grain size values and
checks that the returned :math:`t_s` matches the formula to within a relative tolerance of
:math:`10^{-6}`. The dusty-box integration checks relative velocity decay to within 1%
of the analytic exponential solution at multiples of the stopping time.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_dust.f90
