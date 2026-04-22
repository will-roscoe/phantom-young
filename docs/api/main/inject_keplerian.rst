.. phantom-doc: hand-written

inject_keplerian
================

Overview
--------

The ``inject_keplerian`` module (module name ``inject``,
``inject_type = 'keplerian'``) injects gas particles at a specified radius
in a Keplerian orbit around a central sink particle. It is used to model
mass inflow into an accretion disc at a controlled rate, as might arise from
mass transfer in a binary system or from a circumbinary disc feeding a
central binary. Particles are placed at radius ``rinj`` with velocities set
by Keplerian circular orbits and a thermal velocity corresponding to the
aspect ratio ``HonR_inj`` at the injection radius.

Runtime parameters include the mass injection rate ``mdot`` (in Msun/yr),
the injection radius ``rinj``, the disc aspect ratio ``HonR_inj`` that sets
the sound speed at injection, optional inclination angles (``incx``, ``incy``,
``incz``) for a tilted injection plane, a Gaussian width ``sigma_inj`` for
radially spread injection (ring injection when zero), and a flag
``follow_sink`` to track the sink particle's position as the injection centre.

Physical & Mathematical Description
------------------------------------

At each timestep the module computes the number of particles to inject as
:math:`\Delta N = \lfloor \dot{M} \Delta t / m_\text{SPH} \rfloor`. Each
particle is placed at radius :math:`r_\text{inj}` (or drawn from a Gaussian
of width :math:`\sigma_\text{inj}` around it) at a random azimuthal angle
:math:`\phi \in [0, 2\pi)`. The Keplerian circular velocity at the injection
radius is

.. math::

   v_\phi = \sqrt{\frac{G M_\star}{r_\text{inj}}},

where :math:`M_\star` is the mass of the first sink particle. The sound speed
is set from the local aspect ratio:

.. math::

   c_s = H/R \cdot v_\phi = \mathtt{HonR\_inj} \cdot v_\phi,

and the internal energy is :math:`u = c_s^2 / [\gamma(\gamma-1)]`. Particles
are optionally rotated into an inclined frame using the supplied Euler angles
before being passed to ``add_or_update_particle``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
