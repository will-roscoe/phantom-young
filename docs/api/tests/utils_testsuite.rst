.. phantom-doc: hand-written

utils_testsuite
===============

Overview
--------

The ``utils_testsuite`` module (Fortran module name ``testutils``) provides the shared
utility routines used by every test module in the Phantom test suite. Its primary exports
are the generic ``checkval`` interface, which compares a computed scalar or array value
against an expected value and records a pass or fail, and the ``checkvalf`` interface,
which performs the same check using a relative rather than absolute tolerance. A
``checkvalbuf`` family of routines supports buffered checking where many values are
accumulated before a final summary call to ``checkvalbuf_end`` prints a single result
line.

The module also exports ``update_test_scores``, which increments the global ``ntests``
and ``npass`` counters based on the ``nfailed`` array returned by each check, and calls
``barrier_mpi`` to synchronise all MPI ranks before advancing. This design ensures that
the running totals are consistent across distributed runs even when individual ranks may
encounter different numbers of checks.

All routines in this module are purely diagnostic; they perform no physics calculations.
Error messages are formatted to include the variable name, the computed value, the
expected value, and the absolute or relative discrepancy, making test output
self-documenting without requiring external log parsers.

Physical & Mathematical Description
------------------------------------

The ``checkval`` routines compare a computed value :math:`x` to an expected value
:math:`x_0` using the absolute criterion :math:`|x - x_0| \leq \varepsilon`, where
:math:`\varepsilon` is supplied by the caller. The ``checkvalf`` routines use a relative
tolerance :math:`|x - x_0|/|x_0| \leq \varepsilon_{\rm rel}`. A small floor value of
:math:`10^{-6}` prevents division by zero when :math:`x_0` is very small.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/utils_testsuite.f90
