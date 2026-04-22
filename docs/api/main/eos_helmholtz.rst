.. phantom-doc: hand-written

eos_helmholtz — Helmholtz Free Energy Equation of State
=======================================================

Overview
--------

The ``eos_helmholtz`` module implements the Helmholtz free-energy equation of state
of Timmes & Swesty (2000), which provides thermodynamically consistent pressure,
entropy, internal energy, and sound speed for a fully ionised plasma over a very wide
range of density and temperature.  The EOS covers densities
:math:`10^{-12} \lesssim \rho \lesssim 10^{15}\ \mathrm{g\,cm^{-3}}` and
temperatures :math:`10^3 \lesssim T \lesssim 10^{13}\ \mathrm{K}`, making it
appropriate for modelling degenerate matter in white dwarfs, core-collapse
supernovae, and similar environments.

The EOS is selected by ``ieos = 15`` in the Phantom input file.  It is currently
hard-coded to a 50/50 carbon–oxygen mixture by mass, which is the typical white-dwarf
composition.  The tables are read from a binary datafile at initialisation
(``eos_helmholtz_init``), and all thermodynamic quantities are recovered by
bicubic-spline interpolation in :math:`(\log\rho, \log T)`.

Within the Phantom pipeline the module is called from the master dispatcher in
:doc:`eos` and from the ``eosinfo`` print routine.  Because the tables carry
explicit free-energy derivatives, the Helmholtz EOS guarantees exact Maxwell
relations and is therefore described by its authors as "perfectly thermodynamically
consistent."  The module provides a query function for the heat capacity at constant
volume (:math:`c_v`) and the temperature derivative of pressure
(:math:`\partial P/\partial T|_\rho`) in addition to the standard pressure and
sound speed.

Physical & Mathematical Description
-------------------------------------

The total Helmholtz free energy per unit volume is decomposed as

.. math::

   F = F_{\rm ion} + F_{\rm ele} + F_{\rm rad} + F_{\rm Coul}

where the four contributions are:

* **Ion** — classical ideal gas of nuclei.
* **Electron/positron** — relativistic, partially degenerate; evaluated from
  tabulated splines of :math:`f(\rho, T)`.
* **Radiation** — blackbody photons, :math:`F_{\rm rad} = -\frac{1}{3}\frac{a
  T^4}{\rho}` per unit mass.
* **Coulomb** — ion–electron correction.

The total pressure is

.. math::

   P = \rho^2 \left.\frac{\partial F}{\partial\rho}\right|_T + P_{\rm rad}

and the specific internal energy is

.. math::

   u = F - T\left.\frac{\partial F}{\partial T}\right|_\rho.

The adiabatic sound speed is

.. math::

   c_s^2 = \frac{\Gamma_1 P}{\rho}, \qquad
   \Gamma_1 = \frac{\partial \ln P}{\partial \ln \rho}\bigg|_s

where :math:`\Gamma_1` (the first adiabatic index) is obtained from the table
derivatives.

**Table structure.**  The electron contribution is tabulated on a
:math:`271 \times 101` uniform grid in :math:`(\log T, \log\rho)` with spacing
chosen to represent the full domain of astrophysical interest.  The spline
coefficients for :math:`f`, :math:`f_\rho`, :math:`f_T`, :math:`f_{\rho\rho}`,
:math:`f_{TT}`, :math:`f_{\rho T}`, and cross derivatives are stored in memory
after the initial table read, enabling :math:`O(1)` evaluation.

Derivations
-----------

The temperature iteration in ``eos_helmholtz_pres_sound`` proceeds by Newton–Raphson
on the temperature given an input temperature guess and the pre-read table splines.
The outer routine ``eos_helmholtz_pres_sound`` performs one iteration of Newton–
Raphson to converge on the temperature consistent with the input conditions before
calling the inner ``eos_helmholtz_compute_pres_sound`` to evaluate all derivatives.

For the ion contribution the pressure is analytic:

.. math::

   P_{\rm ion} = \frac{\rho\,R_g\,T}{\bar{A}\,m_u}

where :math:`\bar{A}` is the mass-weighted mean nucleon number of the mixture and
:math:`m_u` is the atomic mass unit.  The radiation contribution is

.. math::

   P_{\rm rad} = \frac{a\,T^4}{3}.

The electron/positron contribution requires the tabulated spline evaluation; details
are given in Timmes & Swesty (2000), Section 3.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Timmes, F. X. & Swesty, F. D. 2000, ApJS, 126, 501 — Helmholtz free energy EoS tables and algorithm

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_helmholtz.f90
