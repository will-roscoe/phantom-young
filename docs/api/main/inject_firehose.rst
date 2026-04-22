.. phantom-doc: hand-written

inject_firehose
===============

Overview
--------

The ``inject_firehose`` module (module name ``inject``, ``inject_type = 'firehose'``)
injects a cylindrical stream of gas particles to model the debris stream produced
by a tidal disruption event (TDE), as used in Liptai et al. studies of TDE
physics. The stream is directed along the x-axis toward a central black hole,
and particles are placed on a regular grid cross-section at each injection wall.
The injection velocity is set to the parabolic orbital speed at the tidal radius,
and the sound speed is determined from the specified Mach number.

Runtime parameters control the peak mass injection rate (``Mdot`` in Msun/yr),
the functional form of :math:`\dot{M}(t)` (``mdot_func``, where 0 is constant),
the number of particles across the stream diameter (``N``), the Mach number of
the injected stream (``mach``), and the stream width in solar radii
(``stream_width``). The module supports optional time-variable mass injection
rates to model the expected fallback rate from TDEs.

Physical & Mathematical Description
------------------------------------

The injection point is placed at the tidal radius
:math:`R_\text{tidal} = R_\star (M_\text{BH}/M_\star)^{1/3}` with penetration
factor :math:`\beta = 1`, so :math:`R_p = R_\text{tidal}`. The injection speed
is the parabolic orbital speed at this point:

.. math::

   v_\text{inj} = \frac{1}{2}\sqrt{\frac{2 G M_\text{BH}}{R_p}},

and the sound speed is set by the Mach number,
:math:`c_s = v_\text{inj}/\mathcal{M}`. The internal energy of each injected
particle follows from the ideal gas relation
:math:`u = c_s^2 / [\gamma(\gamma-1)]`.

The stream is a cylinder of radius :math:`r_\text{cyl} = \mathtt{stream\_width} \times R_\star`
centred on the injection point. Particles fill the cylinder cross-section on a
uniform grid with spacing :math:`\delta r = 2 r_\text{cyl}/N`. A new injection
wall is placed whenever the elapsed time since the last wall equals
:math:`\delta r / v_\text{inj}`, maintaining a constant inter-particle separation
along the stream axis. The number of particles per wall scales as
:math:`N_\text{wall} \approx \pi N^2/4`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
