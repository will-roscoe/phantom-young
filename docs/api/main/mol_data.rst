.. phantom-doc: hand-written

mol_data
========

Overview
--------

The ``mol_data`` module stores tabulated molecular cooling rate data for H2
and CO, used in the interstellar medium cooling network within Phantom. The
H2 data are taken from Le Bourlot, Pineau des Forets & Flower (1999) and are
available at the CCP7 database; the CO data are from the large-velocity-gradient
tables of Neufeld & Kaufman (1993) and Neufeld, Lepp & Melnick (1995), with
an extension to low temperatures by Glover & Clark (2012). The tables were
originally assembled by Simon Glover and adapted for Phantom by Daniel Price.

The H2 cooling data span :math:`\log T = 2.0` to :math:`4.0` in steps of
0.05 dex (``nh2data = 41`` entries) and provide three quantities: the LTE
cooling rate ``h2_lte`` (erg/s per molecule), the H–H2 collisional rate
``h2_h_rate``, and the H2–H2 collisional rate ``h2_h2_rate``, all as
functions of log temperature ``h2_temp``. These are interpolated at runtime
by the ISM cooling module.

Physical & Mathematical Description
------------------------------------

The total H2 cooling function is the sum of collisional contributions at low
density and the LTE limit at high density:

.. math::

   \Lambda_\text{H2}(T, n) = \frac{\Lambda_\text{LTE}(T)}
   {1 + \Lambda_\text{LTE}(T) / [n\, (q_{H} n_H + q_{H_2} n_{H_2})]},

where :math:`q_{H}` and :math:`q_{H_2}` are the tabulated H–H2 and H2–H2
collision rates. The CO cooling is handled by a separate 2D table
parameterised by temperature and column density per velocity gradient.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mol_data.f90
