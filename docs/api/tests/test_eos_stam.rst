.. phantom-doc: hand-written

test_eos_stam
=============

Overview
--------

The ``test_eos_stam`` module tests the Stamatellos et al. (2007) opacity-dependent
equation of state, which uses a pre-computed table of Rosseland-mean opacities and
specific internal energies as a function of density and temperature. The module reads
the opacity table from disk (via ``read_optab``) and then verifies that the bilinear
interpolation routines ``getopac_opdep`` and ``getintenerg_opdep`` return self-consistent
values across the full :math:`(\rho, T)` grid.

The test is conditional on the ``PHANTOM_DIR`` environment variable being set so that the
opacity file can be located. If the environment variable is absent the test is silently
skipped. This design allows the test suite to run in environments (such as CI workers)
where the data files are not installed, without recording a spurious failure.

The interpolation is validated over a :math:`100 \times 100` grid of logarithmically
spaced densities and temperatures spanning the table range. At each grid point the
recovered temperature is compared to the input temperature, and the recovered opacity is
checked for monotonicity and physical plausibility.

Physical & Mathematical Description
------------------------------------

The Stamatellos EOS stores specific internal energy :math:`u(\rho, T)` and opacity
:math:`\kappa(\rho, T)` on a two-dimensional tabulated grid. The test checks that the
inverse mapping :math:`T(\rho, u)` obtained by ``getintenerg_opdep`` reproduces the
input temperature to within a relative tolerance that reflects the coarseness of the
grid spacing, typically :math:`\sim 10^{-3}` for the default table resolution.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_eos_stam.f90
