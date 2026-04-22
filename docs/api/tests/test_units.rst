.. phantom-doc: hand-written

test_units
==========

Overview
--------

The ``test_units`` module (Fortran module ``testunits``) tests the unit-conversion
framework in Phantom, which allows simulations to be run in CGS, SI, solar, or geometric
units and provides conversion factors to and from all of these. The module runs four
sub-tests: ``test_unit_extraction`` checks the string parser that reads unit labels from
runtime parameter files; ``test_unit_conversions`` verifies that CGS ↔ code-unit
conversions are self-consistent; ``test_unit_types`` checks every named unit type (mass,
length, time, velocity, energy, etc.); and ``test_geometric_units`` verifies the
:math:`G=1, c=1` mode used for GR simulations.

The unit extraction test parses strings of the form ``"1.0 msun"`` and
``"3.0e+10 cm"`` and verifies that the multiplier and unit label are correctly extracted
using a tolerance of :math:`10^{-12}`. The conversion tests call ``set_units`` with
various combinations of mass, distance, and :math:`G` values and check that the derived
unit of time satisfies :math:`t = d^{3/2}/(Gm)^{1/2}`, the unit of velocity satisfies
:math:`v = d/t`, and the unit of energy satisfies :math:`E = m\,v^2`.

Physical & Mathematical Description
------------------------------------

The fundamental relation checked is :math:`G = 1` in code units, i.e.
:math:`G_{\rm CGS} \times m_{\rm code} / (d_{\rm code}^3 / t_{\rm code}^2) = 1` where
:math:`m_{\rm code}`, :math:`d_{\rm code}`, and :math:`t_{\rm code}` are the mass, length,
and time scales in CGS. Each conversion is checked to a relative tolerance of
:math:`10^{-12}` (double precision). For geometric units the speed of light in code units
must equal exactly 1 to the same precision.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_units.f90
