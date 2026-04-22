.. phantom-doc: hand-written

test_eos
========

Overview
--------

The ``test_eos`` module (Fortran module ``testeos``) is the master driver for all
equation-of-state unit tests in Phantom. It calls a general-purpose sub-routine
``test_all`` that iterates over every EOS type supported by the code (adiabatic, locally
isothermal, barotropic, ideal plus radiation, Helmholtz, and the HORMONE recombination
EOS) and verifies that ``equationofstate`` returns thermodynamically consistent values of
pressure, sound speed, and temperature. Specialised sub-routines then exercise the
ideal-plus-radiation EOS and the HORMONE EOS across its three recombination modes.

The module also delegates to ``test_eos_stratified`` (from ``testeos_stratified``) to
check the stratified disc EOS, and to ``run_test_stam`` (from ``test_eos_stam``) to check
the Stamatellos opacity-table EOS when the ``PHANTOM_DIR`` environment variable is set.
Units are initialised to solar-mass and 10¹⁶ cm scale before any EOS calls are made, so
that physical temperatures and pressures lie within the valid range of all tabulated EOS.

Physical & Mathematical Description
------------------------------------

The consistency checks verify that the pressure satisfies
:math:`P = (\gamma - 1)\rho u` for an ideal gas, and that the square of the adiabatic
sound speed satisfies :math:`c_s^2 = \gamma P/\rho`. For the radiation-inclusive EOS the
total pressure :math:`P = P_{\rm gas} + P_{\rm rad}` is compared term by term. Relative
tolerances of approximately :math:`10^{-10}` are used for double-precision paths;
single-precision paths use :math:`10^{-6}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_eos.f90
