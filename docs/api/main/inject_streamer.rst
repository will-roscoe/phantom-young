.. phantom-doc: hand-written

inject_streamer
===============

Overview
--------

The ``inject_streamer`` module (module name ``inject``,
``inject_type = 'streamer'``) injects material along a parabolic infalling
streamer orbit following the Mendoza et al. (2009) analytical streamer model.
It is used to simulate the accretion streamer seen in some Class 0/I protostars,
where infalling envelope gas approaches the disc along a curved trajectory
defined by the angular momentum and centrifugal radius of the parent cloud.
The ``set_streamer`` module provides the per-particle position and velocity
along the analytic orbit at the injection radius ``r_inj``.

Runtime parameters include the mass injection rate ``mdot_streamer``
(Msun/yr), the injection radius ``Rin_streamer``, the pericentre distance
``Rp_streamer``, the impact radius on the disc ``Rimp_streamer``, the
inclination ``incl_streamer`` and node longitude ``phi_streamer``, the
cross-sectional half-width at injection ``Win_streamer``, and a flag
``ingoing`` to select pre- or post-pericentre injection. Angular momentum
balancing options (``sym_stream``) can be used to add a counter-stream to
conserve the angular momentum budget of the simulation.

Physical & Mathematical Description
------------------------------------

The streamer trajectory is a parabolic orbit in the gravitational potential
of the central mass. At the injection radius :math:`R_\text{in}`, the
analytic velocity vector :math:`\mathbf{v}_\text{stream}` is provided by
``set_streamer_particle`` based on the orbital parameters
:math:`(R_p, R_\text{imp}, i, \phi)`. The injection rate is

.. math::

   \dot{N} = \frac{\dot{M}_\text{stream}}{m_\text{SPH}},

and particles are placed in a small cylinder of half-width :math:`W_\text{in}`
around the analytic orbit position at :math:`R_\text{in}`, with positions
perturbed by a random offset drawn from ``ran2`` and scaled to the
cross-section width. The dust fraction ``dust_frac`` can be set to add
a dust component to the infalling material when the ``use_dust`` flag is
compiled in.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
