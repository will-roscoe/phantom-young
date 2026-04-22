.. phantom-doc: hand-written

growth — Dust Grain Size Evolution
====================================

Overview
--------

The ``growth`` module evolves the size (or equivalently the mass) of individual
dust grains in the Phantom SPH code by integrating coagulation and fragmentation
source terms.  It is designed for the two-fluid formulation where dust particles
are represented explicitly, though it also supports the one-fluid (dust-fraction)
approach.  The central routine ``get_growth_rate`` loops over all active dust
particles and returns :math:`\mathrm{d}m/\mathrm{d}t` for each, which is then
applied by the time-integrator.

Growth is driven by the local relative velocity between dust and gas.  The
module computes the turbulence-induced relative velocity following Stepinski &
Valageas (1997), using a dimensionless turbulence parameter ``alpha_dg`` that
plays the role of the Shakura–Sunyaev :math:`\alpha`.  When the relative
velocity exceeds the fragmentation threshold ``vfrag`` the mass source term
changes sign and grains are destroyed.  Two fragmentation prescriptions are
available: a symmetric model (``ifrag = 1``) that mirrors the growth rate, and
the Kobayashi & Tanaka (2010) model (``ifrag = 2``) in which the fragmentation
efficiency depends on the velocity ratio squared.  A diagnostic mode
(``ifrag = -1``) freezes the grain size by forcing :math:`\mathrm{d}s/\mathrm{d}t = 0`,
which is useful for testing without grain evolution.

An aeolian erosion model due to Rozner, Grishin & Perets (2020) is optionally
activated (``ieros = 1``), representing the chipping of small grains from large
aggregates by high-velocity gas impacts.  A snow-line treatment allows different
fragmentation thresholds interior and exterior to a specified radius or
temperature, accounting for the enhanced sticking ability of icy grains beyond
the water ice line.  Grain porosity (``iporosity = 1``) is also supported, in
which case grain sizes are derived from both mass and a filling factor, and the
minimum grain constraint is expressed in terms of a minimum stopping time
``tsmin`` rather than a minimum physical size.

Utility routines provide size-bin mapping for post-processing with the MCFOST
radiative transfer code, conversion from one-fluid to two-fluid initial
conditions, and the Keplerian frequency needed by the turbulent velocity model.

Physical & Mathematical Description
-------------------------------------

**Mass growth rate.**  For a spherical grain of radius :math:`s`, mass
:math:`m = (4\pi/3)\rho_\mathrm{grain} s^3`, and local dust density
:math:`\rho_d`, the geometric sweep rate is

.. math::

   \frac{\mathrm{d}m}{\mathrm{d}t} = 4\pi s^2\, \rho_d\, v_\mathrm{rel},

where :math:`v_\mathrm{rel}` is the relative velocity between dust and gas.
When ``ifrag = 0`` this expression is used unchanged (pure growth).  When
``ifrag = 1`` the rate is negated for :math:`v_\mathrm{rel} > v_\mathrm{frag}`
(symmetric fragmentation).  When ``ifrag = 2`` the Kobayashi & Tanaka (2010)
prescription is used:

.. math::

   \frac{\mathrm{d}m}{\mathrm{d}t} = -4\pi s^2\, \rho_d\, v_\mathrm{rel}\,
   \frac{(v_\mathrm{rel}/v_\mathrm{frag})^2}{1 + (v_\mathrm{rel}/v_\mathrm{frag})^2}.

**Turbulent relative velocity.**  Following Stepinski & Valageas (1997) the
turbulent velocity of the gas is

.. math::

   V_t = \sqrt{\sqrt{2}\,\mathrm{Ro}\,\alpha_\mathrm{dg}}\,c_s,

where :math:`\mathrm{Ro} = 3` is the Rossby number and :math:`\alpha_\mathrm{dg}`
the turbulence parameter.  The dust–gas relative velocity is then

.. math::

   v_\mathrm{rel} = \frac{\sqrt{2}\,V_t\,\sqrt{S_c - 1}}{S_c},

where the Schmidt number is

.. math::

   \mathrm{St} = \Omega_k\,t_s,

.. math::

   S_c = (1 + \mathrm{St})\,
   \sqrt{1 + \left(\frac{|\Delta\mathbf{v}|}{V_t}\right)^2},

with :math:`\Omega_k` the local Keplerian frequency, :math:`t_s` the drag
stopping time, and :math:`\mathrm{St} = \Omega_k t_s` the Stokes number.

**Aeolian erosion.**  When ``ieros = 1`` and the differential velocity exceeds
the erosion threshold

.. math::

   |\Delta\mathbf{v}| \geq \sqrt{0.0123}\,
   \sqrt{\frac{1.65\,u_t^2}{m\,\rho_\mathrm{grain}\,s_\mathrm{eject}}},

a mass loss term is added:

.. math::

   \frac{\mathrm{d}m}{\mathrm{d}t}\bigg|_\mathrm{eros}
   = -\frac{4\pi\,s\,\rho_\mathrm{grain}\,\rho_g\,
     |\Delta\mathbf{v}|^3\,s_\mathrm{eject}^2}{3\,a_\mathrm{coh}},

where :math:`s_\mathrm{eject}` is the ejected-grain size (``dsize``) and
:math:`a_\mathrm{coh}` is the cohesive acceleration (``cohacc``).

**Minimum size enforcement.**  When fragmentation would drive the grain mass
below a minimum :math:`m_\mathrm{min} = (4\pi/3)\rho_\mathrm{grain}
s_\mathrm{min}^3`, the mass source term is tapered smoothly to zero as the grain
mass approaches :math:`m_\mathrm{min}`.

**Snow-line treatment.**  When ``isnow = 1`` the boundary is defined by a
prescribed radial distance ``rsnow`` from the primary; when ``isnow = 2`` it is
defined by a temperature threshold ``Tsnow``.  Interior grains use
``vfragin`` and exterior grains use ``vfragout`` as their fragmentation
thresholds.

References
----------

Stepinski, T. F. & Valageas, P. (1997), A&A 319, 1007 [not yet in phantom.bib]

Kobayashi, H. & Tanaka, H. (2010), Icarus 206, 735 [not yet in phantom.bib]

Rozner, M., Grishin, E. & Perets, H. B. (2020), MNRAS 496, 4827
[not yet in phantom.bib]

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/growth.f90
