.. phantom-doc: hand-written

set_hierarchical
================

Overview
--------

The ``set_hierarchical`` module constructs the initial conditions for
hierarchical multiple-star systems: triples, quadruples, and higher-order
configurations.  It represents the system as a tree of nested binary
orbits; each node specifies either a leaf (a single star) or a sub-binary
whose two children are themselves nodes.  The module recurses through the
tree, calling ``set_binary`` at each level to compute the position and
velocity of each body relative to its parent barycentre, and then shifts
the result into the global simulation frame.

Sink particles are used to represent the individual stars or compact
objects.  For each star the module calls the appropriate stellar setup
routine to populate the particle positions, or simply places a point-mass
sink if no extended star is required.  The nesting depth is limited only
by the size of the configuration arrays, which are set at compile time.

Physical & Mathematical Description
------------------------------------

A hierarchical triple consists of an inner binary of masses
:math:`m_1` and :math:`m_2` with semi-major axis :math:`a_\mathrm{in}`,
orbited at much larger separation :math:`a_\mathrm{out}` by a third body
of mass :math:`m_3`.  The stability condition

.. math::

   \frac{a_\mathrm{out}}{a_\mathrm{in}} \gtrsim
   \frac{2.8}{1-e_\mathrm{out}}
   \left[(1+q_\mathrm{out})\frac{1+e_\mathrm{out}}
         {\sqrt{1-e_\mathrm{out}}}\right]^{2/5},

(Mardling & Aarseth 2001) must be satisfied to guarantee long-term
stability of the triple.  The ``set_hierarchical_utils`` module (see its
own documentation) provides routines to verify this condition and to
convert between the tree-node parametrisation and the physical orbital
elements used by ``set_binary``.  Positions and velocities are assembled
by recursively adding the Keplerian offsets at each level of the
hierarchy, working from the innermost binary outward.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_hierarchical.f90
