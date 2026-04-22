.. phantom-doc: hand-written

extern_binary_gw
================

Overview
--------

The ``extern_binary`` module (source file ``extern_binary_gw.f90``)
implements an external gravitational force from a decaying binary system
whose orbit shrinks due to gravitational wave emission. The binary consists
of two point masses ``mass1`` and ``mass2`` on an orbit that evolves
according to the Peters (1964) formula for energy loss via gravitational
radiation. The module computes the force on SPH particles from both members
of the binary and optionally accretes particles that fall within the
accretion radii ``accradius1`` and ``accradius2``.

The orbit evolves in time via ``update_binary``, which advances the binary
position using the current semi-major axis ``a0`` and eccentricity. This
module is suitable for simulations of circumbinary discs or common-envelope
evolution around gravitational-wave-driven inspiralling binaries. It is a
Category B module and is not processed by the Fortran autodoc parser.

Physical & Mathematical Description
------------------------------------

The gravitational wave energy loss rate for a circular binary is given by
the Peters (1964) formula:

.. math::

   \frac{dE}{dt} = -\frac{32}{5} \frac{G^4}{c^5}
   \frac{m_1^2 m_2^2 (m_1 + m_2)}{r^5},

which drives a corresponding decrease in the semi-major axis
:math:`da/dt = -(64/5)(G^3 m_1 m_2 (m_1 + m_2))/(c^5 a^3)`. The
gravitational force on an SPH particle at position :math:`\mathbf{r}` from
binary component :math:`k` at position :math:`\mathbf{r}_k` is the standard
Newtonian point-mass force :math:`\mathbf{f} = -G m_k (\mathbf{r} -
\mathbf{r}_k) / |\mathbf{r} - \mathbf{r}_k|^3`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
