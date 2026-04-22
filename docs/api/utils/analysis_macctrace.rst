.. phantom-doc: hand-written

analysis_macctrace
==================

Overview
--------

``analysis_macctrace`` traces which particles have been accreted by sink particles and records their identifiers in a persistent list. At each post-processing dump it checks all live particles against the previously stored accreted list and identifies newly accreted particles, enabling the accretion history to be reconstructed from a series of dumps.

The routine maintains an integer array ``already_accreted`` that grows as particles are accreted. For each dump it opens an output file in append mode and writes the particle index and dump time for each newly accreted particle found, providing a complete catalogue of accretion events.

This diagnostic is useful for understanding the accretion geometry in protoplanetary disc simulations, stellar wind accretion, or common envelope evolution where the identity of accreted material provides information about its origin in the disc or envelope.

Physical & Mathematical Description
------------------------------------

A particle :math:`i` is identified as newly accreted if its smoothing length satisfies :math:`h_i < 0` (indicating accretion in the Phantom particle array) and its identifier does not appear in the ``already_accreted`` list from previous dumps. The detection is purely based on particle state flags in the ``xyzh`` array.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_macctrace.f90`` for the complete source.
