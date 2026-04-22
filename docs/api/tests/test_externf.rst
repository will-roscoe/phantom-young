.. phantom-doc: hand-written

test_externf
============

Overview
--------

The ``test_externf`` module (Fortran module ``testexternf``) provides unit tests for the
external force framework in Phantom, which allows arbitrary analytical potentials to be
added to the SPH equations of motion. The test iterates over every force type registered
in ``externalforces`` (up to ``iexternalforce_max``) and performs two checks for each:
first that the numerical gradient of the potential matches the analytic force to within
tolerance ``tolf = 1.5e-3``, and second that any velocity-dependent force (Lense-Thirring
precession, Poynting-Robertson drag, spiral arm potentials) satisfies the correct
velocity-force relation.

A separate sub-test verifies the accretion boundary: particles placed inside
``accradius1`` are correctly removed from the simulation by ``accrete_particles`` and the
``was_accreted`` flag is set to ``.true.``. A final sub-test places particles in a
Keplerian disc with an external potential and integrates for one orbit, checking that the
angular momentum is conserved to within ``tolfold = 1e-10``.

The module re-uses the same module name ``testexternf`` as ``test_externf_gr.f90``, which
is why the GR variant must be excluded from the Fortran autodoc parser.

Physical & Mathematical Description
------------------------------------

The numerical gradient test computes
:math:`f_{\rm num} = -[V(x+\epsilon) - V(x-\epsilon)] / (2\epsilon)` with
:math:`\epsilon = 10^{-4}` and compares to the analytic force returned by
``externalforce``. The relative tolerance of :math:`1.5\times10^{-3}` reflects the
expected finite-difference truncation error at this step size. Velocity-dependent forces
are verified by comparing to their closed-form expressions, which are exact at the level
of floating-point precision.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_externf.f90
