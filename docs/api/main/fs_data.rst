.. phantom-doc: hand-written

fs_data
=======

Overview
--------

The ``fs_data`` module contains atomic data (Einstein A-coefficients and
energy level separations) required for computing the fine-structure cooling
rates of neutral oxygen (O I), neutral carbon (C I), and singly ionised
carbon (C II) in the interstellar medium cooling network. These data are
used by the ISM cooling module to compute line cooling contributions from
fine-structure transitions at low temperatures (:math:`T \lesssim 10^4` K).

The data were originally collected by Simon Glover at AMNH and AIP
(2004–2006) and adapted for Phantom by Daniel Price. Each species is
represented by transition probabilities (``oxa10``, ``oxa20``, ``oxa21``,
etc.) and upper-level energies (``oxe10``, ``oxe21``, ``oxe20``, etc.) for
up to three energy levels, with values stored as double-precision named
parameters in SI/CGS-mixed units with Boltzmann's constant ``kb`` folded in.

Physical & Mathematical Description
------------------------------------

The fine-structure cooling rate per unit volume for a two-level system with
upper level :math:`u` and lower level :math:`l` is

.. math::

   \Lambda = n_u A_{ul} h\nu_{ul},

where :math:`A_{ul}` is the Einstein A-coefficient, :math:`h\nu_{ul}` is
the photon energy, and :math:`n_u` is the number density of atoms in the
upper state. The level populations are computed from the collisional
excitation rates and the detailed balance condition. For a three-level
system the expressions extend to a 3x3 linear system for the level
populations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/fs_data.f90
