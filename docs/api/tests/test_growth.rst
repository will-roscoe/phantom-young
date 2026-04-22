.. phantom-doc: hand-written

test_growth
===========

Overview
--------

The ``test_growth`` module (Fortran module ``testgrowth``) tests the differential dust
grain growth algorithm of Stepinski & Valageas as implemented in the Phantom ``growth``
module. The test requires both ``-DDUST`` and ``-DDUSTGROWTH`` compile-time flags; if
either is absent the test is skipped. The module exercises all combinations of the
fragmentation flag ``ifrag`` (0, 1, 2) and the snow-line flag ``isnow`` (0, 1, 2),
calling ``init_growth`` for each combination and verifying that the initialisation
completes without error.

The core growth physics is tested via the exported ``test_dustybox`` routine from
``testdust``, which is re-used here to provide a self-consistent drift-and-growth
scenario. In addition, the growth rate is compared to the Smoluchowski coagulation
kernel for a monodisperse size distribution, checking that the rate of change of grain
mass :math:`\dot{s} \propto s \rho_{\rm dust} / \rho_{\rm gas}` matches the analytic
expression from the Stepinski & Valageas model to within the required relative tolerance.

Physical & Mathematical Description
------------------------------------

The grain size evolution equation is
:math:`\dot{s} = s \rho_{\rm dust} v_{\rm rel} / (4 \rho_{\rm grain})`,
where :math:`v_{\rm rel}` is the root-mean-square relative velocity between grain pairs.
The test evaluates the growth rate at a fixed density and relative velocity and checks the
result against the analytic value to within a relative tolerance set by the fragmentation
model. The initialisation checks verify that ``init_growth`` returns ``ierr = 0`` for all
valid combinations of ``ifrag`` and ``isnow``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_growth.f90
