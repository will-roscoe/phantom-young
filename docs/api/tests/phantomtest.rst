.. phantom-doc: hand-written

phantomtest
===========

Overview
--------

The ``phantomtest`` program is the entry point for the Phantom unit-test executable built
by ``make test``. It initialises MPI, allocates particle memory up to a fixed ceiling of
one million particles, and then calls ``testsuite`` from the ``test`` module, passing
any command-line arguments directly as test-selection strings. If no arguments are given,
it calls the suite with the string ``'all'`` to run every registered test in sequence.

On completion the program finalises MPI and exits with a non-zero return code if any
individual test failed, making it suitable for use in continuous-integration pipelines
where a non-zero exit indicates a regression. The program enables the ``curlv`` and
``track_lum`` compile-time flags unconditionally so that all derivative branches are
exercised regardless of the production build configuration.

This wrapper is intentionally minimal: all substantive test logic lives in the
``testsuite`` module and the individual ``test_*`` sub-modules, keeping the entry point
free of physics code and easy to substitute with alternative harnesses.

Physical & Mathematical Description
------------------------------------

``phantomtest`` performs no physics computations itself. Its role is to set up the
execution environment — MPI ranks, I/O unit numbers, and memory — and to propagate
``ntests``, ``npass``, and ``nfail`` counters across the full test run. The program
exits with ``stop 1`` if ``nfail > 0``, providing a machine-readable failure signal.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/phantomtest.f90
