.. phantom-doc: hand-written

inject_masstransfer
===================

Overview
--------

The ``inject_masstransfer`` module (module name ``inject``,
``inject_type = 'masstransfer'``) injects a uniform wind into a cylindrical
domain to simulate gas flowing onto a sphere — a configuration used for
Bondi-Hoyle-Lyttleton (BHL) accretion tests and mass-transfer wind-tunnel
problems. The injected wind is a flat-fronted cylinder of particles placed at
a fixed x-position (``wind_injection_x``), flowing in the +x direction at
the specified speed ``v_inf`` and Mach number ``mach``.

Runtime parameters include the wind speed ``v_inf``, Mach number ``mach``,
wind cylinder radius ``wind_radius``, x-position of the injection boundary
``wind_injection_x``, lattice type (``lattice_type``: 0 for cubic, 1 for
close-packed), the number of BHL wind layers held in memory
``handled_layers``, and optionally a MESA stellar model file (``filemesa``)
from which the time-variable mass transfer rate is read when
``use_mesa_file = .true.``.

Physical & Mathematical Description
------------------------------------

The wind is injected as successive parallel layers of particles. The layer
spacing equals the inter-particle separation ``psep`` computed from the
particle mass and wind density. For a close-packed lattice (``lattice_type = 1``),
alternating layers are offset by half a particle spacing in y and z, giving
a face-centred cubic (FCC) arrangement that minimises grid noise. The
time between successive layers is

.. math::

   \Delta t_\text{layer} = \frac{\mathtt{psep}}{v_\text{inf}},

and ``handled_layers`` layers of boundary particles are maintained upstream
to provide an accurate pressure boundary condition. The sound speed is
:math:`c_s = v_\text{inf}/\mathcal{M}` and the internal energy is
:math:`u = c_s^2/[\gamma(\gamma-1)]`. When a MESA data file is provided,
the mass transfer rate :math:`\dot{M}(t)` is interpolated from the tabulated
stellar evolution track to set the particle mass at each timestep.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
