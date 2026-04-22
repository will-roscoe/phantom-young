.. phantom-doc: hand-written

test_kernel
===========

Overview
--------

The ``test_kernel`` module (Fortran module ``testkernel``) performs a comprehensive
series of unit tests on the SPH kernel routines in Phantom, covering the kernel function
:math:`W(q)`, its gradient :math:`\nabla W`, the gravity softening kernel, and the
normalisation constants. The module prints the kernel name at startup so that test output
is unambiguous when multiple kernel types are linked. Every check uses the ``checkval``
or ``checkvalbuf`` routines with machine-epsilon tolerances, so the tests catch not only
gross errors but also sign flips and off-by-one index errors.

The first group of tests verifies that the pre-computed constants ``wab0``, ``gradh0``,
and ``dphidh0`` stored in the kernel module match the values returned by ``get_kernel``
and ``get_kernel_grav1`` at :math:`q = 0`. The second group verifies the gradient
consistency condition by numerical differentiation: the SPH kernel gradient
:math:`\partial W / \partial r` is compared to a finite-difference derivative of :math:`W`
over 200 uniformly spaced points from :math:`q = 0` to :math:`q = 2h`. The third group
verifies the softening kernel by checking the gravitational potential at the origin and
the smoothness of the potential across the softening radius.

Physical & Mathematical Description
------------------------------------

The SPH kernel must satisfy normalisation :math:`\int W(r, h) d^3r = 1`, compact support
within :math:`|r| \leq 2h`, and a gradient consistent with
:math:`\nabla W = (\mathbf{r}/r) \partial W/\partial r`. The numerical gradient test
checks :math:`|g_{\rm analytic}(q) - g_{\rm numerical}(q)| \leq \varepsilon_{\rm tol}(q)`
where the tolerance ``tolgrad`` accounts for the curvature of :math:`W` at the kernel
edge. The softening potential :math:`\phi_{\rm soft}(q)` is required to be smooth (zero
first and second derivatives) at the kernel boundary :math:`q = 2`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_kernel.f90
