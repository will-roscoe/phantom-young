.. phantom-doc: hand-written

cooling_molecular
=================

Overview
--------

The ``cooling_molecular`` module computes radiative cooling by the molecular
species CO, H\ :sub:`2`\ O, and HCN in the circumstellar envelope of an
AGB star or similar evolved-star binary wind. It is intended for use alongside
the ``cooling_solver`` library (``icooling = 1`` or ``2``) when molecular
line cooling is the dominant energy-loss mechanism in a cool, dense wind.

Cooling rates are obtained by trilinear interpolation within a pre-computed
three-dimensional table (``radcool_all.dat``) that tabulates the volumetric
cooling emissivity :math:`\Lambda` as a function of gas temperature :math:`T`,
hydrogen number density :math:`n_\mathrm{H}`, and molecular column density
:math:`N_\mathrm{coolant}`, following the approach of Gail & Sedlmayr (see
references). The relevant column density for each molecule is itself obtained
by interpolation in a separate table (``table_cd.dat``) that parameterises the
column density as a function of radial position, line width, density power-law
exponent, and the binary separation, accounting for the wind geometry.

The three molecular abundances are configurable runtime parameters:

- ``CO_abun``: CO abundance relative to hydrogen (default
  :math:`10^{-4}`, typical for O-rich AGB stars).
- ``H2O_abun``: H\ :sub:`2`\ O abundance (default :math:`5\times10^{-5}`).
- ``HCN_abun``: HCN abundance (default :math:`3\times10^{-7}`).

Setting any abundance to zero disables cooling by that species.
Molecular cooling is active only when at least one abundance is positive
and all three parameters have been successfully read from the input file.

The module also provides a local temperature floor ``Tfloor`` (default 0 K,
independent of the global ``Tfloor`` in ``cooling.f90``) to prevent the
molecular cooling from driving unphysical temperatures.

Physical & Mathematical Description
-------------------------------------

The net specific cooling rate from molecular emission is

.. math::

   \dot{u}_\mathrm{mol} = \sum_{s \in \{\mathrm{CO, H_2O, HCN}\}}
   Q_s = -\sum_s \Lambda_s\,\frac{X_s\,\rho_\mathrm{H}}{\bar{\mu}\,m_\mathrm{p}},

where :math:`\Lambda_s` [erg s\ :sup:`-1` sr\ :sup:`-1`] is the tabulated
cooling emissivity for species :math:`s`, and :math:`X_s` is the fractional
abundance relative to hydrogen.

The cooling emissivity :math:`\Lambda_s(T,\,n_\mathrm{H},\,N_s)` is stored in
logarithmic form (base 10) in the table ``radcool_all.dat``, which covers a
grid of 40 temperature points, 40 density points, and 40 column density points.
Interpolation is performed by the trilinear scheme in ``CoolingRate``.

The molecular column density :math:`N_s = X_s\,n_0\,N_\mathrm{H}` is derived
from the hydrogen column density :math:`N_\mathrm{H}` read from
``table_cd.dat``, where :math:`n_0` is the hydrogen number density at the
inner boundary of the wind. The column density table is parameterised by:

- :math:`r_\mathrm{part}` (au): radial distance of the SPH particle.
- :math:`\Delta v` (normalised by the wind velocity ``fit_vel``): thermal line
  width of the molecule, :math:`\Delta v = \sqrt{2k_\mathrm{B}T/m_s}/v_\mathrm{wind}`.
- :math:`m_\mathrm{exp}` (``fit_rho_power``): exponent of the radial density
  power law.
- :math:`r_\mathrm{sep}` (``r_compOrb``): orbital separation of the binary.

The hydrogen density profile assumed in the column-density calculation is

.. math::

   n_\mathrm{H}(r) =
   \begin{cases}
     n_0 & r \leq r_\mathrm{sep}, \\
     n_0\,(r_\mathrm{sep}/r)^{m_\mathrm{exp}} & r > r_\mathrm{sep},
   \end{cases}

with inner density ``fit_rho_inner`` and power-law index ``fit_rho_power``.

The logarithmic derivative :math:`\mathrm{d}\ln Q / \mathrm{d}\ln T` required
by ``cooling_solver`` is computed numerically by finite differences across
adjacent temperature nodes in the cooling table.

References
----------

Gail, H.-P. & Sedlmayr, E. 2013, Physics and Chemistry of Circumstellar Dust
Shells, Cambridge University Press (not yet in phantom.bib)

Hollenbach, D. & McKee, C. F. 1989, ApJ, 342, 306 (not yet in phantom.bib)

Neufeld, D. A. & Kaufman, M. J. 1993, ApJ, 418, 263 (not yet in phantom.bib)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/cooling_molecular.f90
