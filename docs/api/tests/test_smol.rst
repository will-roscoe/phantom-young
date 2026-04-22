.. phantom-doc: hand-written

test_smol
=========

Overview
--------

The ``test_smol`` module (Fortran module ``testsmol``) tests the Smoluchowski
dust-coagulation solver in Phantom, which evolves the grain size distribution by solving
the integro-differential Smoluchowski coagulation equation on a discrete size grid. The
test requires both ``DUST=yes`` and ``SMOL=yes`` at compile time; if either flag is
missing the test is skipped. Units are set to solar mass and AU.

The primary sub-test ``test_dustgrowth_smol`` initialises a monodisperse grain size
distribution and calls ``grain_growth_smol`` to advance the coagulation by one timestep.
It then checks that the total dust mass is conserved (coagulation redistributes mass but
does not create or destroy it), and that the mean grain size has grown by the expected
amount for the chosen kernel. The test uses both micron and millimetre grain sizes and
verifies the size evolution for the constant-kernel case, for which the analytic solution
:math:`n(s,t) = n_0 \exp(-t/t_{\rm coag})` is known.

Physical & Mathematical Description
------------------------------------

For the constant kernel :math:`K = K_0` the coagulation timescale is
:math:`t_{\rm coag} = 2/(K_0 n_{\rm tot,0})` where :math:`n_{\rm tot,0}` is the initial
total number density of grains. The test checks that the total number density evolves as
:math:`n_{\rm tot}(t) = n_{\rm tot,0}/(1 + t/t_{\rm coag})` to within a relative
tolerance of :math:`10^{-6}`. Mass conservation is checked to within machine precision
(:math:`\sim 10^{-14}`).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_smol.F90
