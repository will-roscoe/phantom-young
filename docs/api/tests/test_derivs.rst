.. phantom-doc: hand-written

test_derivs
===========

Overview
--------

The ``test_derivs`` module (Fortran module ``testderivs``) performs comprehensive unit
tests of the SPH derivative operators implemented in the ``deriv`` and ``densityforce``
modules. It sets up a uniform periodic particle distribution, calls ``get_derivs_global``
to compute all first-order and second-order SPH derivatives, and then compares the results
to analytic values for simple prescribed velocity and magnetic-field fields.

The tests cover the divergence :math:`\nabla\cdot\mathbf{v}`, the curl
:math:`\nabla\times\mathbf{v}`, the divergence of the magnetic field
:math:`\nabla\cdot\mathbf{B}`, and, when MHD is active, the full stress tensor
components. A separate sub-test checks that the neighbour statistics (mean, minimum, and
maximum neighbour counts) returned by ``get_neighbour_stats`` are consistent with the
expected value for the chosen smoothing length and particle separation. The module also
verifies that derivative operators compile and produce non-NaN results under all
combination of compile-time flags including ``-DDUST``, ``-DMHD``, and ``-DIND_TIMESTEPS``.

Physical & Mathematical Description
------------------------------------

For a uniform velocity field :math:`\mathbf{v} = (v_x, v_y, v_z)` the analytic divergence
is zero and the curl is zero, so any non-zero SPH result indicates an error in the kernel
gradient summation. For a linear shear field the divergence has a known non-zero analytic
value; the SPH result is expected to match this to within the SPH truncation error, which
is :math:`O(h^2)` for a second-order kernel. Tolerances are set to a few percent of the
local density :math:`\rho_0 = 5` in code units to allow for the finite particle number.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_derivs.f90
