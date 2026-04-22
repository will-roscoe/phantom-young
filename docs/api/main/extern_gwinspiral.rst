.. phantom-doc: hand-written

extern_gwinspiral — Gravitational-Wave Inspiral Radiation-Reaction Force
=========================================================================

Overview
--------

The ``extern_gwinspiral`` module simulates the orbital decay of a compact binary
system caused by gravitational-wave (GW) emission.  It applies a radiation-reaction
body force to all SPH particles and/or sink particles making up each star, causing the
orbit to shrink at the rate predicted by the leading-order quadrupole formula of
Peters (1964).  The implementation was written by Bernard Field under the supervision
of James Wurster and Paul Lasky.

The module supports three configurations: two resolved stars (each represented by an
SPH particle cloud), one resolved star plus one sink particle, and two sink particles.
At each global timestep ``gw_still_inspiralling`` computes the centre of mass and
centre-of-mass velocity of each stellar component and evaluates the force coefficients.
``get_gw_force`` then constructs the per-star drag vector, and ``get_gw_force_i``
applies the appropriate vector to each individual particle based on its stellar
membership.  Inspiral ceases automatically when the merger criterion — a threshold
fraction ``stopratio`` of particles having crossed the inter-stellar midplane — is
satisfied.

Physical & Mathematical Description
-------------------------------------

In the quadrupole approximation of general relativity, the power radiated by a
binary of masses :math:`m_1`, :math:`m_2` in a circular orbit of separation
:math:`a` is

.. math::

   \frac{dE}{dt} = -\frac{32}{5}\frac{G^4}{c^5}
                    \frac{m_1^2\,m_2^2\,(m_1+m_2)}{a^5}.

The radiation-reaction force applied to star :math:`k` (with mass :math:`m_k`,
centre-of-mass velocity :math:`\mathbf{v}_k`, and orbital separation :math:`a`) is
modelled as a velocity-aligned drag:

.. math::

   \mathbf{F}_k = C_k\,\frac{\mathbf{v}_k}{|\mathbf{v}_k|^2\,a^5},

where the coefficient for each star is (in code units :math:`G = 1`)

.. math::

   C_1 = -\frac{32}{5}\frac{m_1\,m_2^3}{c^5},
   \qquad
   C_2 = -\frac{32}{5}\frac{m_2\,m_1^3}{c^5}.

Each SPH particle belonging to star :math:`k` receives the uniform per-particle
acceleration :math:`\mathbf{f}_k = \mathbf{F}_k / m_k^\mathrm{eff}`, computed as the
ratio of the total force vector to the star's effective velocity magnitude and
separation.

The merger condition counts how many particles of star 1 have crossed the midplane
towards star 2 and vice versa, halting GW emission when this count exceeds
:math:`N_\mathrm{threshold} = \max\!\bigl(\lfloor N_\mathrm{total}\,
\texttt{stopratio}\rfloor,\,1\bigr)`.

References
----------

The leading-order gravitational-wave energy loss rate is from:

- Peters, P. C. 1964, Phys. Rev., 136, B1224 — not yet in phantom.bib

The module header also cites:

- Tong, D. 2015, Classical Dynamics Lecture Notes — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_gwinspiral.f90
