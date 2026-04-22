.. phantom-doc: hand-written

test_neigh
==========

Overview
--------

The ``test_neigh`` module (Fortran module ``testneigh``) tests the neighbour-finding
machinery in Phantom, which locates all particles within the SPH kernel support radius
:math:`r < 2h` of each target particle using the k-d tree structure built by
``build_tree``. The test sets up uniform particle distributions with a range of particle
separations, calls ``get_neighbour_list`` for every particle, and checks that the
returned neighbour count is consistent with the expected analytic value for a periodic
uniform distribution.

The expected number of neighbours for a particle at separation ``psep`` with smoothing
length ``h`` is :math:`N_{\rm neigh} \approx (4\pi/3)(2h)^3 \rho/m`, which equals
approximately 58 for the default cubic spline kernel with ``hfact = 1.2``. The test
verifies the mean, minimum, and maximum neighbour counts using a buffered check over all
particles, with tolerances appropriate for the finite-number fluctuations in a random
distribution. Timing information is reported to detect performance regressions.

Physical & Mathematical Description
------------------------------------

The theoretical number of neighbours is derived from the kernel support radius
:math:`r_{\rm cut} = \zeta h` (where :math:`\zeta = 2` for compact kernels) and the
local number density :math:`n = \rho/m`, giving
:math:`N_{\rm neigh} = (4\pi/3)\zeta^3 h^3 n`. For a uniform periodic distribution
with ``hfact = 1.2`` this yields :math:`N_{\rm neigh} \approx 57.9`. The test accepts
values in the range :math:`[N_{\rm neigh} - 5, N_{\rm neigh} + 5]` to allow for integer
rounding and boundary effects.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_neigh.f90
