.. phantom-doc: hand-written

nicil_supplement
================

Overview
--------

The ``nicil_sup`` module provides the wrapper routines that integrate the
NICIL (Non-Ideal Coupled Ion-neutral Library) non-ideal MHD library into
Phantom. NICIL, developed by James Wurster (Wurster 2016, 2021), computes
the Ohmic, Hall, and ambipolar diffusion coefficients (:math:`\eta_O`,
:math:`\eta_H`, :math:`\eta_A`) as functions of local density, temperature,
magnetic field strength, and grain properties. This module handles
initialisation, coefficient computation, and the reading/writing of the
many NICIL runtime parameters to the ``.in`` file.

The runtime parameters exposed include the cosmic-ray ionisation rate
``zeta``, grain properties (radius ``a0_grain``, bulk density ``rho_bulk``,
dust-to-gas ratio ``fdg``, and size distribution limits), and override
constants for the non-ideal coefficients (``C_OR``, ``C_HE``, ``C_AD``,
``eta_constant``) that allow bypassing the full NICIL calculation with
simple constant coefficients for testing. The module also manages the
ambipolar diffusion power law exponent ``alpha_AD`` and the ion-neutral
coupling coefficient ``gamma_AD``.

Physical & Mathematical Description
------------------------------------

The non-ideal MHD induction equation in NICIL's formulation is

.. math::

   \frac{\partial \mathbf{B}}{\partial t} = \nabla \times
   \left[(\mathbf{v} \times \mathbf{B})
   - \eta_O \mathbf{J}
   - \eta_H (\hat{\mathbf{B}} \times \mathbf{J})
   + \eta_A (\mathbf{J} \times \hat{\mathbf{B}}) \times \hat{\mathbf{B}}
   \right],

where :math:`\mathbf{J} = \nabla \times \mathbf{B}` is the current density.
The three non-ideal coefficients :math:`\eta_O` (Ohmic), :math:`\eta_H`
(Hall), and :math:`\eta_A` (ambipolar) are computed by NICIL from the
local ionisation state, which depends on density, temperature, and the grain
population.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/nicil_supplement.f90
