.. phantom-doc: hand-written

h2chem
======

Overview
--------

The ``chem`` module (source file ``h2chem.f90``) implements a coupled
chemical network for hydrogen and carbon monoxide in the interstellar
medium. The routines were originally written by Clare Dobbs, modified
extensively by Alex Pettitt, and subsequently translated to Fortran 90 and
adapted for Phantom by Daniel Price (2011). The current module owner is
Lionel Siess.

The module tracks five species: molecular hydrogen (H\ :sub:`2`), atomic
hydrogen (H I), ionised hydrogen (H II / protons), electrons, and carbon
monoxide (CO). Their fractional abundances are advanced forward in time by
``update_abundances``, which first calls the internal ``evolve_abundances``
routine and then ``get_extra_abundances`` to populate the full abundance
array required by the ISM cooling routines.

Time integration of H\ :sub:`2` and CO uses a subcycled explicit Euler
scheme. The H\ :sub:`2` subcycle timestep is set adaptively to one-tenth of
the photodissociation timescale, with a floor of 201 steps per hydrodynamic
timestep. CO is further subcycled within each H\ :sub:`2` step using a
rate-based criterion. Hydrogen ionisation (H I :math:`\leftrightarrow`
H II) is evolved analytically over the full hydrodynamic timestep using
creation and destruction coefficients supplied by the ``hchem`` routine,
written by S. Glover (AIP, 2006).

The photodissociation path length ``dphot`` can be held constant or computed
from the Miyamoto–Nagai stellar disk density profile, controlled by the
``dphotflag`` argument to ``get_dphot``. The mean molecular weight
:math:`\bar{\mu}` is recomputed self-consistently from the H\ :sub:`2`
fraction at every subcycle step.

Physical & Mathematical Description
------------------------------------

**Mean molecular weight.** For a hydrogen–helium gas with a He/H number
ratio of 0.1, the mean molecular weight is

.. math::

   \bar{\mu} = \frac{2 f_{\mathrm{H_2}} + (1 - 2 f_{\mathrm{H_2}}) + 0.4}
                    {0.1 + f_{\mathrm{H_2}} + (1 - 2 f_{\mathrm{H_2}})},

where :math:`f_{\mathrm{H_2}} \equiv n_{\mathrm{H_2}} / n_\mathrm{tot}` is
the ratio of molecular hydrogen number density to total number density.

**Total number density.** The total particle number density is approximated
as

.. math::

   n_\mathrm{tot} = \frac{5}{7}\,\frac{\rho}{m_\mathrm{p}},

consistent with a predominantly H\ :sub:`2` gas (:math:`\gamma = 7/5`).

**H**\ :sub:`2` **formation and destruction** (Bergin et al. 2004). The
rate of change of the H\ :sub:`2` number density is

.. math::

   \frac{d n_{\mathrm{H_2}}}{d t} = R_\mathrm{grain}\,n_\mathrm{tot}\,n_\mathrm{H} -
   (\eta_\mathrm{diss} + \zeta_\mathrm{CR})\,n_{\mathrm{H_2}},

where :math:`R_\mathrm{grain} = R_0\sqrt{T}` is the grain-surface formation
rate [cm\ :sup:`3` s\ :sup:`-1`] (Bergin et al. 2004 give :math:`R_0 =
6\times10^{-18}` cm\ :sup:`3` s\ :sup:`-1` K\ :sup:`-1/2`; the module uses
``Rconst`` :math:`= 3\times 10^{-1}\times 2.2\times10^{-18}`), :math:`\zeta_\mathrm{CR}` is the
cosmic-ray ionisation rate, and :math:`\eta_\mathrm{diss}` is the UV
photodissociation rate given by

.. math::

   \eta_\mathrm{diss} = \eta_\mathrm{diss}^{(0)}\,f_\mathrm{shield}\,f_\mathrm{dust},

with the bare rate ``rate_diss0`` :math:`= 4.17\times10^{-11}` s\
:sup:`-1`. The dust-attenuation factor is

.. math::

   f_\mathrm{dust} = \exp\!\left(-3.74\,\alpha_{AV}\,N_\mathrm{tot}\right),

where :math:`N_\mathrm{tot} = n_\mathrm{tot}\,d_\mathrm{phot}` is the
total column density along the photodissociation path and
:math:`\alpha_{AV}` is the AV conversion factor from ``cooling_ism``.

The H\ :sub:`2` self-shielding factor follows Draine & Bertoldi (1996) with
turbulent broadening parameter :math:`b = 3` km s\ :sup:`-1`:

.. math::

   f_\mathrm{shield} = \frac{0.965}{(1 + x/b)^2}
   + \frac{0.035}{\sqrt{1+x}}\exp\!\left(-8.5\times10^{-4}\sqrt{1+x}\right),

where :math:`x = N_{\mathrm{H_2}} / (5\times10^{14}\ \mathrm{cm}^{-2})`
and :math:`N_{\mathrm{H_2}} = n_{\mathrm{H_2}}\,d_\mathrm{phot}`. The
module evaluates :math:`x` as :math:`N_{\mathrm{H_2}}\times 2\times
10^{-15}` to avoid the explicit division.

**CO formation and destruction** (Nelson & Langer 1997; Glover et al.
2010). The CO abundance evolves as

.. math::

   \frac{d a_\mathrm{CO}}{d t} =
   k_0\,n_\mathrm{tot}^2\,a_{\mathrm{C^+}}\,\beta
   - \Gamma_\mathrm{CO}\,n_\mathrm{tot}\,a_\mathrm{CO},

where :math:`a_X \equiv n_X / n_\mathrm{tot}` denotes fractional
abundance, :math:`k_0 = 5\times10^{-16}` cm\ :sup:`3` s\ :sup:`-1` is the
CHx formation rate constant, and the branching fraction :math:`\beta`
weights the C\ :sup:`+` → CHx → CO pathway against photodissociation of
CHx:

.. math::

   \beta = \frac{k_1\,(a_\mathrm{O} - a_\mathrm{CO})}
                {k_1\,(a_\mathrm{O} - a_\mathrm{CO})
                 + \Gamma_\mathrm{CHx}\,/\,n_{\mathrm{H_2}}},

with :math:`k_1 = 5\times10^{-10}` cm\ :sup:`3` s\ :sup:`-1`. The UV
photodissociation rates are

.. math::

   \Gamma_\mathrm{CO}  &= \phi_\mathrm{rates}
       \exp\!\left(-2.5\,\alpha_{AV}\,N_\mathrm{tot}\right), \\
   \Gamma_\mathrm{CHx} &= 5\,\Gamma_\mathrm{CO},

where ``phrates`` :math:`= 1.56\times10^{-10}` s\ :sup:`-1` is the
unshielded CO photodissociation rate (Nelson & Langer 1997). The
C\ :sup:`+` abundance is treated as
:math:`a_{\mathrm{C^+}} = a_{\mathrm{C,tot}} - a_\mathrm{CO}`.

**Hydrogen ionisation balance.** Atomic hydrogen obeys the linear rate
equation

.. math::

   \frac{d n_\mathrm{H}}{d t} = C - D\,n_\mathrm{H},

where the creation coefficient :math:`C` and destruction coefficient
:math:`D` are assembled in ``hchem`` from three processes:

1. *Collisional ionisation by electrons* — a nine-term polynomial fit in
   :math:`\ln(T/\mathrm{eV})` from Abel et al. (1997), based on Janev et
   al. (1987).

2. *Case B gas-phase recombination* (Ferland et al. 1992):

   .. math::

      k_\mathrm{rec} = \frac{2.753\times10^{-14}\,
        (315614\,/\,T)^{3/2}}
        {\left[1 + (115188\,/\,T)^{0.407}\right]^{2.242}}
        \quad [\mathrm{cm}^3\,\mathrm{s}^{-1}].

3. *Grain-surface recombination* (Weingartner & Draine 2001), with the
   grain charge parameter :math:`\phi \propto G_0\sqrt{T}/(n\,x_e)`,
   optionally attenuated by :math:`\exp(-2.5\,A_V)` for the dust-shielded
   case (``iphoto = 1``).

The full creation and destruction terms are

.. math::

   C &= k_\mathrm{rec}\,n_e\,n_{\mathrm{H^+}}
        + k_\mathrm{gr}\,n_{\mathrm{H^+}}\,n, \\
   D &= \zeta_\mathrm{CR} + k_\mathrm{ci}\,n_e.

References
----------

Nelson, R. P. & Langer, W. D. 1997, ApJ, 482, 796

Glover, S. C. O., Federrath, C., Mac Low, M.-M. & Klessen, R. S. 2010,
MNRAS, 404, 2

Bergin, E. A., Hartmann, L. W., Raymond, J. C. & Ballesteros-Paredes, J.
2004, ApJ, 612, 921

Abel, T., Anninos, P., Zhang, Y. & Norman, M. L. 1997, New Astron., 2, 181

Draine, B. T. & Bertoldi, F. 1996, ApJ, 468, 269

Ferland, G. J. et al. 1992, ApJ, 387, 95

Janev, R. K. et al. 1987, *Elementary Processes in Hydrogen-Helium Plasmas*,
Springer

Weingartner, J. C. & Draine, B. T. 2001, ApJ, 563, 842

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/h2chem.f90
