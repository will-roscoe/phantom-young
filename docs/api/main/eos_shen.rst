.. phantom-doc: hand-written

eos_shen — Shen Nuclear Equation of State
=========================================

Overview
--------

The ``eos_shen`` module provides the nuclear-matter equation of state of Shen,
Toki, Oyamatsu & Sumiyoshi (1998, 2011), commonly referred to as the NL3 EOS.
This tabulated EOS covers the full range of conditions encountered in core-collapse
supernovae and neutron-star mergers: densities up to and beyond nuclear saturation
density, temperatures from zero to hundreds of MeV, and proton fractions spanning
the range relevant to the neutron-rich nuclear matter.  The table entries give the
free energy per baryon, from which the pressure, entropy, and sound speed are
derived.

This EOS is selected by ``ieos = 16`` in the Phantom input file.  Because the Shen
EOS spans sub-nuclear to supra-nuclear densities, it supersedes simpler analytic
prescriptions for neutron-star and supernova physics.  The module reads a binary
table (``eos_binary_table.dat``) at initialisation from the Phantom data directory
under ``eos/shen``, interpolates to the requested :math:`(\rho, T, Y_p)` point,
and returns the pressure and sound speed in CGS units for conversion by the master
dispatcher in :doc:`eos`.

The module is marked as experimental in the Phantom source; users are advised to
verify results against published benchmarks before production use.  The thermal
energy variable evolved in Phantom is treated as a temperature proxy when
``ieos = 16``, which requires that the energy-equation be evolved rather than the
entropy.

Physical & Mathematical Description
-------------------------------------

The Shen table is parameterised by:

* **Baryon number density** :math:`n_B` (fm\ :sup:`-3`), with
  :math:`\rho = n_B\,m_u` where :math:`m_u = 1.6605 \times 10^{-24}\ \mathrm{g}`.
* **Temperature** :math:`T` (MeV), converted from Kelvin via
  :math:`1\ \mathrm{MeV} = 1.1604 \times 10^{10}\ \mathrm{K}`.
* **Proton fraction** :math:`Y_p \in [0.05, 0.56]`; the Phantom interface fixes
  :math:`Y_p = 0.05` as a default for neutron-rich matter.

The table stores the free energy per baryon :math:`F(n_B, T, Y_p)` in MeV.
Pressure is derived as

.. math::

   P = n_B^2\,\frac{\partial F}{\partial n_B}\bigg|_{T,Y_p}

and the sound speed is obtained from the tabulated derivative via

.. math::

   c_s = \sqrt{\frac{\partial P}{\partial\rho}\bigg|_s}.

Interpolation is performed by three-dimensional linear interpolation in
:math:`(\log n_B, T, Y_p)` space.

The table covers densities from approximately
:math:`n_B \sim 10^{-8}\ \mathrm{fm}^{-3}` up to several times nuclear saturation
density :math:`n_0 \approx 0.16\ \mathrm{fm}^{-3}`.  Below the table range the
code applies a low-density extrapolation.

Derivations
-----------

At densities below the table minimum the code uses a turning-point construct: it
evaluates the pressure at the minimum tabulated density and constructs a linear
extrapolation in :math:`\rho` to ensure a smooth transition.  The sound speed in
the sub-table regime is approximated from the finite difference
:math:`dP/d\rho|_{n_{\rm min}}`.

The unit conversion from the Shen table (fm, MeV) to CGS is

.. math::

   \rho_{\rm CGS} = n_B \times \frac{m_u}{(10^{-13}\ \mathrm{cm})^3}, \quad
   T_{\rm CGS} = T_{\rm MeV} \times 1.1604 \times 10^{10}\ \mathrm{K}, \quad
   P_{\rm CGS} = P_{\rm MeV/fm^3} \times 1.6022 \times 10^{33}\ \mathrm{dyn\,cm^{-2}}.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Shen, H., Toki, H., Oyamatsu, K. & Sumiyoshi, K. 1998, Nucl. Phys. A, 637, 435 — NL3 nuclear EoS original paper
- Shen, G., Horowitz, C. J. & Teige, S. 2011, Phys. Rev. C, 83, 035802 — updated NL3 table

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_shen.f90
