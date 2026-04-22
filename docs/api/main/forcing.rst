.. phantom-doc: hand-written

forcing — Stochastic Turbulence Driving via Ornstein–Uhlenbeck Process
=======================================================================

Overview
--------

The ``forcing`` module implements stochastic turbulence driving for Phantom SPH
simulations.  The implementation is due to Christoph Federrath (originally for the
FLASH code) and was adapted for Phantom by Daniel Price.  It drives compressible or
solenoidal turbulence by applying a time-correlated random body force to every SPH
particle at each timestep.  This is the standard approach for generating driven,
statistically steady turbulence in periodic-box simulations of the interstellar
medium, molecular clouds, and laboratory plasma.

The random force field is constructed as a superposition of :math:`N_\mathrm{modes}`
Fourier modes with wavevectors :math:`\mathbf{k}` lying in the band
:math:`[k_\mathrm{min}, k_\mathrm{max}]`.  The time evolution of the complex
amplitudes follows an Ornstein–Uhlenbeck (OU) process with correlation time
:math:`t_\mathrm{decay}` and energy injection rate :math:`\dot{E}`.  At each forcing
step the six real OU phases per mode are updated and projected into solenoidal and
compressive components using the ``st_solweight`` parameter; the resulting real-space
acceleration field is evaluated at every particle position in the main loop
``st_calcAccel``.

Three spectral forms are available: a flat (band) spectrum
(``st_spectform = 0``), a parabolic spectrum peaking at the band centre
(``st_spectform = 1``), and a Kolmogorov :math:`k^{-5/3}` spectrum
(``st_spectform = 2``).  The forcing pattern can be generated on the fly from runtime
parameters or read from a pre-generated binary file ``forcing.dat``.  Forcing state
is checkpointed alongside each Phantom dump file in a companion ``.str`` file so that
runs can be exactly restarted.

Physical & Mathematical Description
-------------------------------------

The stochastic acceleration at position :math:`\mathbf{x}` is a sum over Fourier
modes:

.. math::

   \mathbf{f}(\mathbf{x}, t) = 2\,A\,\tilde{\sigma}
   \sum_{m=1}^{N_\mathrm{modes}} \hat{a}_m(t)
   \left[\tilde{a}_m \cos(\mathbf{k}_m\cdot\mathbf{x})
         - \tilde{b}_m \sin(\mathbf{k}_m\cdot\mathbf{x})\right],

where :math:`A = \texttt{st\_amplfac}`, :math:`\tilde{\sigma}` is the solenoidal
normalisation ``st_solweightnorm``, and :math:`\hat{a}_m`, :math:`\tilde{a}_m`,
:math:`\tilde{b}_m` are the mode amplitudes derived from the OU phases after Helmholtz
projection.

**Ornstein–Uhlenbeck update**

The OU phase vector :math:`\boldsymbol{\phi}` of length :math:`6N_\mathrm{modes}` is
evolved at each forcing step :math:`\Delta t_f`:

.. math::

   \phi_i^{n+1} = f\,\phi_i^n
                  + \sigma\sqrt{1 - f^2}\,z_i,
   \quad
   f = \exp\!\left(-\frac{\Delta t_f}{t_\mathrm{decay}}\right),

where :math:`z_i` is a unit-Gaussian random deviate (Box–Muller) and
:math:`\sigma = \sqrt{\dot{E}/t_\mathrm{decay}}` is the OU variance
(``st_OUvar``).  This recursion is a first-order, exact-in-time discretisation of
the continuous OU stochastic differential equation and yields a stationary process
with variance :math:`\sigma^2` and exponential temporal autocorrelation with timescale
:math:`t_\mathrm{decay}`.

**Helmholtz projection**

For each mode the raw OU phases are split into solenoidal (curl) and compressive
(divergence) parts:

.. math::

   \tilde{a}_{m,j} = \zeta\,\left(\phi^\mathrm{curl}_{m,j}\right)
                    + (1-\zeta)\,\left(\phi^\mathrm{div}_{m,j}\right),

where :math:`\zeta = \texttt{st\_solweight} \in [0,1]` interpolates between
purely compressive (:math:`\zeta = 0`) and purely solenoidal (:math:`\zeta = 1`)
driving; :math:`\zeta = 0.5` gives a natural mixture.

**Spectral amplitudes**

- ``st_spectform = 0`` (flat band): :math:`\hat{a}_m = 1`.
- ``st_spectform = 1`` (parabola): :math:`\hat{a}_m = 4(a_\min - 1)(k_m - k_c)^2/(k_\max - k_\min)^2 + 1`, where :math:`k_c = (k_\min + k_\max)/2`.
- ``st_spectform = 2`` (Kolmogorov): :math:`\hat{a}_m = (k_\min/k_m)^{5/3}`.

The following reference describes the turbulence-driving algorithm:

- Federrath, C., Klessen, R. S. & Schmidt, W. 2008, ApJ, 688, L79 — not yet in phantom.bib
- Uhlenbeck, G. E. & Ornstein, L. S. 1930, Phys. Rev., 36, 823 — not yet in phantom.bib

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/forcing.f90
