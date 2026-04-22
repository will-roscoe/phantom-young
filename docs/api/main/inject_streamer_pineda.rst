.. phantom-doc: hand-written

inject_streamer_pineda
======================

Overview
--------

The ``inject_streamer_pineda`` module (module name ``inject``,
``inject_type = 'streamer'``) is an alternative streamer injection module
designed for simulations of the Pineda streamer configuration. Like
``inject_streamer``, it injects material along a parabolic orbit toward a
central protostar or disc, but uses the Mendoza et al. (2009) parameterisation
with parameters tailored to match observational data for the Per-emb-2 system
studied by Pineda et al. The stream is modelled as a cylinder of particles
injected at a fixed distance from the centre of mass with velocities set by
the analytic orbit solution.

Runtime parameters include the mass injection rate ``Mdot`` (Msun/yr), the
functional form of :math:`\dot{M}(t)` (``mdot_func``), the injection distance
``r_inj``, the cross-sectional stream width ``stream_width``, the Mendoza et al.
parameters ``r0``, ``phi0``, ``theta0`` defining the orbit geometry, the cloud
angular velocity ``omega`` and initial radial velocity ``vr_0``, a dust fraction
``dust_frac``, and injection time window (``tstart``, ``tend``). An angular
momentum symmetrisation option ``sym_stream`` optionally adds a counter-stream
to balance the angular momentum injected by the main streamer.

Physical & Mathematical Description
------------------------------------

The velocity field of the streamer at the injection point follows from the
Mendoza et al. (2009) prescription. In spherical coordinates
:math:`(r, \theta, \phi)`, the initial conditions of the infalling cloud
parcel at large radius :math:`r_0` are radial velocity :math:`v_{r,0}`,
rotation rate :math:`\omega`, and orbital angles :math:`(\theta_0, \phi_0)`.
These are integrated along the parabolic trajectory to the injection radius
:math:`r_\text{inj}` to give :math:`\mathbf{v}_\text{stream}`. The injection
rate is

.. math::

   \dot{N} = \frac{\dot{M} (t)}{m_\text{SPH}},

where :math:`\dot{M}(t)` may be constant or vary according to ``mdot_func``.
Particles are placed in a cylinder of radius ``stream_width`` around the
analytic orbit position at :math:`r_\text{inj}`, with uniformly random
azimuthal scatter. The simulation stops injecting particles if the current
time falls outside the window :math:`[t_\text{start}, t_\text{end}]`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
