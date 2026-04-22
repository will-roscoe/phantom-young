.. phantom-doc: hand-written

options
=======

Overview
--------

The ``options`` module collects and exposes the default values of all runtime
parameters that control the physical behaviour of a Phantom simulation. Parameters
include the SPH artificial viscosity coefficients (``alpha``, ``beta``, ``alphau``,
``alphaB``), the equation-of-state selector ``ieos``, the cooling flag ``icooling``,
and the external-force selector ``iexternalforce``. Default
values are set in ``set_default_options`` and are subsequently overwritten by the
``.in`` parameter file on startup.

Rather than duplicating declarations, the module re-exports parameters from lower-level
modules — ``alpha``, ``alphamax``, ``alphau``, ``alphaB``, and ``beta`` from
``shock_capturing``; ``ieos`` and ``icooling`` from ``eos``; ``idamp`` from ``damping``;
``nfulldump`` from ``io_control``; and ``curlv`` from ``dim``. This
design makes all global runtime options accessible through a single ``use options``
statement.

The subroutine ``set_default_options`` calls subordinate default-setting routines for
timestepping (``set_defaults_timestep``), I/O control (``set_defaults_iocontrol``),
equation of state (``set_defaults_eos``), shock capturing (``set_defaults_shock_capturing``),
physical viscosity (``set_defaults_viscosity``), radiation (``set_defaults_radiation``),
and MCFOST coupling (``set_defaults_mcfost``). Optional output flags ``calc_erot``
and ``curlv`` are written and read via ``write_options_output`` and
``read_options_output``.

Physical & Mathematical Description
------------------------------------

The physical content of this module is entirely encoded in the parameter defaults it
establishes. The smoothing length satisfies:

.. math::

   h = h_{\mathrm{fact}} \left(\frac{m}{\rho}\right)^{1/3}

where the default value ``hfact = hfact_default`` is set from the kernel module. The
artificial viscosity terms controlled by ``alpha`` and ``beta`` appear in the momentum
equation as:

.. math::

   \left(\frac{dv_i}{dt}\right)_{\mathrm{visc}}
   = -\sum_j m_j\,\Pi_{ij}\,\nabla_i W_{ij}

with the standard Monaghan viscosity tensor :math:`\Pi_{ij}` parameterised by
``alpha`` (linear shear viscosity) and ``beta`` (quadratic bulk viscosity). The
thermal and magnetic counterparts ``alphau`` and ``alphaB`` govern the artificial
conductivity and resistivity terms respectively.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/options.f90
