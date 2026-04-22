.. phantom-doc: hand-written

inject_sne
==========

Overview
--------

The ``inject_sne`` module (module name ``inject``, ``inject_type = 'supernovae'``)
injects supernova thermal energy deposits at 30 pre-specified positions to
reproduce the multi-SN test of Balsara and Kim (2004). Each supernova is
triggered at a fixed time determined by the simulation setup and deposits
energy only (no kinetic energy) into the nearest SPH particles. The hardcoded
positions (``xyz_sn``) are drawn from the original test problem coordinates and
are spread quasi-randomly throughout a unit cube.

The module has no runtime parameters. It is designed as a controlled benchmark
rather than a production ISM feedback prescription: the 30 supernova positions
are compiled into the module as a constant array. This test is used to validate
the ability of SPH to handle multiple overlapping supernova remnants and the
associated large dynamic range in thermal energy.

Physical & Mathematical Description
------------------------------------

Each supernova deposits a fixed thermal energy :math:`E_\text{SN} = 10^{51}` erg
(the canonical supernova energy) into the :math:`N_\text{neigh}` nearest SPH
particles within a smoothing length of the event site. The specific internal
energy increment for particle :math:`i` is

.. math::

   \Delta u_i = \frac{W(r_i, h) E_\text{SN}}{\sum_j m_j W(r_j, h)},

where :math:`W` is the SPH kernel and :math:`h` is the smoothing length at the
SN site. Because only thermal energy is injected, the test is conservative: no
momentum is deposited, and the code tests purely the thermodynamic response to
localised heating. The expected result from Balsara and Kim (2004) is a network
of interacting hot-gas bubbles reaching pressure equilibrium on the sound
crossing time.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
