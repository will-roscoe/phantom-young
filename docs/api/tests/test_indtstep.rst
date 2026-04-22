.. phantom-doc: hand-written

test_indtstep
=============

Overview
--------

The ``test_indtstep`` module (Fortran module ``testindtstep``) tests the individual
timestep binning utilities used when Phantom runs with the ``-DIND_TIMESTEPS`` flag. The
primary routine verifies that ``get_newbin`` assigns particles to the correct timestep
bin for a sequence of timestep sizes spanning 30 binary doublings from ``dtmax`` down to
``dtmax / 2^{30}``, plus the boundary cases ``dt = huge`` (should map to bin 0) and
``dt = 0`` (should map to ``maxbins``).

A secondary sub-test exercises ``change_nbinmax``, which dynamically adjusts the maximum
number of active timestep bins. The test checks that ``istepfrac`` is updated consistently
after a bin-count change and that no particle is lost or incorrectly binned when the
number of bins changes mid-run. Both sub-tests require the ``ind_timesteps`` flag to be
``.true.``; if not, the test is skipped with an informational message.

Physical & Mathematical Description
------------------------------------

For a particle with timestep :math:`\Delta t` the assigned bin index is
:math:`i = \lfloor \log_2 (\Delta t_{\rm max} / \Delta t) \rfloor`, clamped to
:math:`[0, N_{\rm bins}]`. The test verifies this formula by comparing the integer bin
index returned by ``get_newbin`` to the analytically expected value using a zero-tolerance
integer check (``tol = 0``) for each of the 32 test cases.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_indtstep.f90
