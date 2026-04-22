.. phantom-doc: hand-written

set_hierarchical_utils
======================

Overview
--------

The ``set_hierarchical_utils`` module provides utility routines that
support the construction of hierarchical multiple-star systems in
``set_hierarchical``.  Its main responsibilities are computing the orbital
parameters for each level of a nested binary tree from the individual
stellar masses and the user-supplied orbital elements, and verifying the
dynamical stability of the resulting configuration.

The routines in this module convert between different parametrisations of
multiple-star orbits (e.g.\ mass-ratio versus individual masses, mean
anomaly versus true anomaly) and compute derived quantities such as the
barycentre velocity and the orbital period at each hierarchy level.  They
are not intended to be called directly from setup routines; instead,
``set_hierarchical`` uses them internally.

Physical & Mathematical Description
------------------------------------

For a hierarchical level with component masses :math:`m_A` and :math:`m_B`
and semi-major axis :math:`a`, the orbital period is

.. math::

   T = 2\pi\sqrt{\frac{a^3}{G(m_A + m_B)}},

and the velocities of the two components relative to their barycentre are

.. math::

   v_A = \frac{m_B}{m_A + m_B}\,v_\mathrm{rel},\qquad
   v_B = \frac{m_A}{m_A + m_B}\,v_\mathrm{rel},

where :math:`v_\mathrm{rel}` is the relative orbital velocity at the
specified true anomaly.  The barycentre is then placed on the next higher-
level orbit by repeating the procedure.  The Mardling–Aarseth stability
criterion is evaluated at each level to warn the user if the chosen
separations are likely to lead to rapid dynamical instability.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc is not available for this file (excluded from Fortran index due to parser incompatibility).
