.. phantom-doc: hand-written

ptmass_radiation — Radiation from Sink Particles
=================================================

Overview
--------

The ``ptmass_radiation`` module implements radiation pressure and dust temperature
determination arising from point-mass (sink) particles.  In Phantom, sink particles
represent compact stellar objects whose radiation field couples to the surrounding gas
and dust.  This module provides the routines that compute the radiative acceleration
imparted to each SPH particle by all luminous sink particles, and the equilibrium
dust temperature at each particle's location.

Radiative acceleration is driven by the ratio of stellar luminosity to mass, with
three distinct physical mechanisms selectable via the integer flag
``isink_radiation``: a constant momentum-deposition fraction parameterised by
``alpha_rad`` (the :math:`\alpha`-wind approximation, mode 1); full radiation
pressure on dust grains using the local opacity and optical depth (mode 2); or a
combination of both (mode 3).  Mode 0 disables radiation pressure entirely.

Dust temperatures are computed by one of five methods controlled by ``iget_tdust``:
setting :math:`T_{\rm dust} = T_{\rm gas}` (mode 0); a simple power-law radial
profile :math:`T_{\rm dust} \propto r^{-\alpha}` (mode 1); flux dilution without
attenuation (mode 2); flux dilution with exponential attenuation :math:`e^{-\tau}`
along the line of sight (mode 3); or the Lucy (1976) approximation using the
generalised optical depth :math:`\tau_{\rm Lucy}` (mode 4).  Modes 3 and 4 require
ray-tracing through the SPH particle distribution to compute the optical depth
:math:`\tau` or :math:`\tau_{\rm Lucy}`, performed by the ``raytracer`` module.
The number of rays is set by ``iray_resolution`` via the HEALPix discretisation
:math:`N_{\rm rays} = 12 \times 4^{k}` where :math:`k` = ``iray_resolution``.

The radiative acceleration calculation scales the gravitational acceleration by an
Eddington-like factor :math:`\alpha`, and therefore the net acceleration on a gas
particle is a fraction :math:`\alpha` of the gravitational acceleration that the
stellar mass would otherwise exert at that location.  When the optical depth is
non-zero, the exponential attenuation factor :math:`e^{-\tau}` reduces the
effective Eddington factor.

Physical & Mathematical Description
-------------------------------------

**Eddington luminosity and radiative acceleration.**  For a sink particle of
mass :math:`M_*` and luminosity :math:`L_*`, the Eddington factor is

.. math::

   \Gamma = \frac{\kappa\,L_*}{4\pi\,c\,G\,M_*}\,e^{-\tau}

where :math:`\kappa` is the dust opacity evaluated at the SPH particle's location,
:math:`c` is the speed of light, :math:`G` is the gravitational constant, and
:math:`\tau` is the optical depth between the sink particle and the SPH particle.

The radiative acceleration on an SPH particle at displacement
:math:`(dx, dy, dz)` from the sink is

.. math::

   \mathbf{a}_{\rm rad} = \frac{\alpha\,M_* G}{r^3}
   \begin{pmatrix}dx \\ dy \\ dz\end{pmatrix}

where :math:`r = |\mathbf{r}|` and the dimensionless factor :math:`\alpha` is
chosen according to ``isink_radiation``:

.. list-table::
   :header-rows: 1
   :widths: 15 20 65

   * - ``isink_radiation``
     - Mode
     - :math:`\alpha`
   * - 0
     - Off
     - :math:`\alpha = 0`
   * - 1
     - :math:`\alpha`-wind
     - :math:`\alpha = \alpha_{\rm rad}` (constant user parameter)
   * - 2
     - Dust pressure
     - :math:`\alpha = \Gamma` (Eddington factor)
   * - 3
     - Combined
     - :math:`\alpha = \Gamma + \alpha_{\rm rad}`

**Dust temperature methods.**  For a sink particle with effective temperature
:math:`T_*` and radius :math:`R_*` located at distance :math:`r` from an SPH
particle, the dust temperature models are:

*Mode 1 — power-law profile:*

.. math::

   T_{\rm dust}(r) = T_*\!\left(\frac{R_*}{r}\right)^{\alpha_T}

where :math:`\alpha_T` = ``tdust_exp`` (default 0.5).

*Mode 2 — flux dilution (no attenuation):*

.. math::

   T_{\rm dust}(r) = T_*
   \left[\frac{1}{2}\!\left(1 - \sqrt{1 - \left(\frac{R_*}{r}\right)^2}\right)
   \right]^{1/4}

*Mode 3 — flux dilution with attenuation:*

.. math::

   T_{\rm dust}(r) = T_*
   \left[\frac{1}{2}\!\left(1 - \sqrt{1 - \left(\frac{R_*}{r}\right)^2}\right)
   e^{-\tau}\right]^{1/4}

*Mode 4 — Lucy approximation:*

.. math::

   T_{\rm dust}(r) = T_*
   \left[\frac{1}{2}\!\left(1 - \sqrt{1 - \left(\frac{R_*}{r}\right)^2}
   + \frac{3}{2}\,\tau_{\rm Lucy}\right)\right]^{1/4}

where :math:`\tau_{\rm Lucy}` is the Rosseland optical depth integrated along the
ray from the star, as computed by the Lucy (1976) moment formalism.  When
:math:`\tau_{\rm Lucy}` is undefined (NaN), it is set to :math:`2/3` — the
photosphere condition.

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Symbol
     - Definition
   * - :math:`L_*`
     - Stellar luminosity stored in ``xyzmh_ptmass(ilum, j)``
   * - :math:`M_*`
     - Sink particle mass stored in ``xyzmh_ptmass(4, j)``
   * - :math:`T_*`
     - Effective stellar temperature stored in ``xyzmh_ptmass(iTeff, j)``
   * - :math:`R_*`
     - Stellar radius stored in ``xyzmh_ptmass(iReff, j)``
   * - :math:`\kappa`
     - Dust grain opacity (Bowen formula or nucleation; cm\ :sup:`2` g\ :sup:`-1`)
   * - :math:`\tau`
     - Optical depth from sink to SPH particle along line of sight
   * - :math:`\tau_{\rm Lucy}`
     - Generalised Lucy optical depth (moment formalism)
   * - :math:`\Gamma`
     - Eddington factor (ratio of radiation to gravity)
   * - :math:`\alpha_{\rm rad}`
     - Constant momentum-deposition fraction (runtime parameter)
   * - :math:`\alpha_T`
     - Exponent of dust temperature power-law (``tdust_exp``)

References
----------

The dust temperature approximations implemented here follow standard stellar
atmosphere and dust physics:

- Lucy, L. B. 1976, ApJ, 205, 482 — generalised optical depth and the Lucy
  temperature approximation (mode 4)
- Bowen, G. H. 1988, ApJ, 329, 299 — Bowen dust opacity formula used by
  ``calc_kappa_bowen`` when nucleation is inactive

No entries in ``phantom.bib`` are directly cited by this module.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/ptmass_radiation.f90
