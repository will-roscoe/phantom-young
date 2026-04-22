.. phantom-doc: hand-written

test_eos_stratified
===================

Overview
--------

The ``test_eos_stratified`` module (Fortran module ``testeos_stratified``) tests the
stratified disc equation of state implemented for protoplanetary disc simulations. This
EOS prescribes a vertically-stratified temperature structure based on the Law et al.
(2021) observational fits: the midplane temperature follows a power-law in radius and the
atmospheric temperature is higher, with a smooth transition described by a cosine profile
in the scaled altitude :math:`z/z_0`.

The test is parameterised with fitting coefficients for five observed discs (HD 163296,
IM Lup, GM Aur, AS 209, MWC 480) stored as module-level constants. For each disc the
routine checks that the midplane temperature at the reference radius matches the input
parameter ``temp_mid0``, that the atmospheric temperature matches ``temp_atm0``, and that
the temperature profile is monotonically increasing from midplane to atmosphere. A
separate sub-test verifies the Dartois et al. (2003) form of the stratification function.

The module also provides the ``map_stratified_temps`` utility routine (exported to avoid
compiler warnings) that can write the full 2D temperature map to a file for visual
inspection during code development.

Physical & Mathematical Description
------------------------------------

The stratified temperature profile is
:math:`T(r, z) = T_{\rm atm}(r) + [T_{\rm mid}(r) - T_{\rm atm}(r)]\cos^2(\pi z / 2 z_s)`,
where :math:`z_s = z_0 (r/r_{\rm ref})^{\beta_z}` is the disc scale height at radius
:math:`r`. The midplane temperature power law is
:math:`T_{\rm mid}(r) = T_{\rm mid,0}(r/r_{\rm ref})^{q_{\rm mid}}` and similarly for
the atmosphere. The test checks each component to within a relative tolerance consistent
with floating-point round-off, approximately :math:`10^{-14}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_eos_stratified.f90
