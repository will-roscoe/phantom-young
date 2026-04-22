.. phantom-doc: hand-written

utils_sphNG
===========

Overview
--------

The ``sphNGutils`` module provides compatibility routines for reading and
writing dump files in the older sphNG format (the predecessor code to
Phantom). It defines sphNG-specific particle type labels and conversion
functions between Phantom's ``iphase`` encoding and the sphNG encoding, as
well as storage for per-particle mass (``mass_sphng``) and spin
(``spin_sphng``) arrays that exist in sphNG dumps but have no direct
equivalent in Phantom.

The two elemental conversion functions ``iphase_sphNG`` and
``iphase_phantom`` translate particle type labels between the two formats,
handling accreted particles (``isphNG_accreted = 18``) and temporary sink
particles (``isphNG_sink_temp = 19``) that exist only in sphNG. The
``got_mass`` and ``got_spin`` flags indicate whether per-particle mass and
spin data were found in the sphNG dump being converted.

Physical & Mathematical Description
------------------------------------

This is a pure I/O compatibility module. The main physics difference between
sphNG and Phantom is that sphNG allowed variable particle masses (stored in
``mass_sphng``), whereas Phantom uses a single mass per particle type. The
conversion routines collapse the variable mass into Phantom's ``massoftype``
array by averaging, which is an approximation that is flagged with a warning
if the mass variation exceeds 1 per cent.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_sphNG.f90
