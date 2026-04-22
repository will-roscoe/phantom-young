.. phantom-doc: hand-written

physcon
=======

Overview
--------

The ``physcon`` module is the single authoritative source for all physical and
mathematical constants used throughout Phantom. Every constant is declared as a
``double precision`` Fortran parameter, ensuring that numerical values are
fixed at compile time and never accidentally modified at runtime. Grouping the
constants in one place prevents subtle inconsistencies that arise when the same
quantity (e.g. the gravitational constant) is hard-coded independently in
multiple routines.

All dimensional quantities are expressed in the CGS-Gaussian unit system. In
particular, the magnetic permeability is set to ``cgsmu0 = 4*pi``, reflecting
the Gaussian convention :math:`\mu_0 = 4\pi` rather than the SI value of
:math:`4\pi \times 10^{-7}\ \mathrm{H\,m^{-1}}`. Users adapting Phantom to SI
contexts must account for this difference explicitly in any magnetic-field
conversion.

The module covers five categories of constants: (i) dimensionless mathematical
values (:math:`\pi`, :math:`2\pi`, :math:`4\pi`, :math:`\sqrt{\pi/2}`,
:math:`\sqrt{2}`, degree-to-radian conversion); (ii) fundamental physical
constants (speed of light, gravitational constant, Boltzmann constant, Planck
constants, Stefan-Boltzmann constant, radiation constant, electron and proton
masses, atomic mass unit, Avogadro's number, electron-volt); (iii) atomic and
plasma quantities (``Rg`` the specific gas constant, ``cgsmu0``); (iv) the
dimensionless Rossby number parameter ``Ro = 3.0``; and (v) astronomical
conversion factors (solar mass, solar radius, solar luminosity, AU, parsec,
kiloparsec, megaparsec, year, megayear, gigayear).

The ``units.f90`` module imports ``physcon`` constants to define code-unit
conversions between CGS and the internal dimensionless system. Any update to a
fundamental constant should therefore be made only in ``physcon.f90`` so that
all downstream conversions remain consistent.

Physical & Mathematical Description
------------------------------------

The radiation constant :math:`a` relates to the Stefan-Boltzmann constant
:math:`\sigma_\mathrm{SB}` and the speed of light :math:`c` by

.. math::

   a = \frac{4\sigma_\mathrm{SB}}{c},

giving ``radconst`` :math:`= 7.5646 \times 10^{-15}\ \mathrm{erg\,cm^{-3}\,K^{-4}}`.
This constant appears in the blackbody energy density
:math:`u_\mathrm{rad} = a T^4`.

For an ideal monatomic gas of mean molecular weight :math:`\mu`, the
temperature is related to specific internal energy :math:`u` by

.. math::

   T = \frac{(\gamma - 1)\,\mu\,m_\mathrm{H}}{k_\mathrm{B}}\,u,

where :math:`k_\mathrm{B}/m_\mathrm{H}` is evaluated from ``kboltz`` and
``mass_proton_cgs``. The gas constant ``Rg`` :math:`= k_\mathrm{B}/m_\mathrm{H}
\approx 8.31446 \times 10^7\ \mathrm{erg\,K^{-1}\,g^{-1}}` provides the
same ratio per gram of hydrogen.

In the CGS-Gaussian system the magnetic energy density is
:math:`B^2/(8\pi)` rather than :math:`B^2/(2\mu_0)` as in SI; this is
encoded by

.. math::

   \mu_0 = 4\pi \quad (\text{Gaussian}),

with ``cgsmu0 = 4*pi``. All MHD force and energy terms in Phantom use this
convention, so the Lorentz force per unit volume is
:math:`(\mathbf{J} \times \mathbf{B})/c = (\nabla \times \mathbf{B}) \times
\mathbf{B}/(4\pi)` in CGS.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/physcon.f90
