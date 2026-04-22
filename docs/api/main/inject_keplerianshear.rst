.. phantom-doc: hand-written

inject_keplerianshear
=====================

Overview
--------

The ``inject_keplerianshear`` module (module name ``inject``,
``inject_type = 'keplerianshear'``) injects particles to maintain a steady
Keplerian shearing flow in a wedge-shaped disc sector. It is designed for
shearing-box-style disc simulations where particles stream through an
azimuthal sector and must be recycled at the domain boundaries. The module
uses ``setdisc`` to initialise the disc profile, then maintains two injection
queues — one on each azimuthal boundary — from which particles are promoted
from boundary type to live gas type as they enter the active domain.

All particles start as boundary particles moving at the local Keplerian
velocity. Once a particle crosses the inner azimuthal boundary of the active
domain it becomes a live gas particle subject to SPH forces. When it reaches
the opposite azimuthal boundary it reverts to a boundary particle, and when
it exits the injection zone it is killed. Additional radial boundary particles
outside the inner and outer disc edges (``R_in`` and ``R_out``) maintain
correct pressure support for the active region.

Physical & Mathematical Description
------------------------------------

The disc surface density and sound speed follow power-law profiles:

.. math::

   \Sigma(r) \propto r^{-p}, \quad c_s(r) \propto r^{-q},

with indices ``p_index`` and ``q_index`` and aspect ratio ``HoverR`` at the
inner sector radius. The Keplerian velocity at radius :math:`r` is
:math:`v_\phi = \sqrt{G M_\text{obj}/r}` for central object mass
``object_mass``. Particles on the injection boundary are assigned
:math:`v_\phi(r)` plus a small thermal perturbation, and the smoothing
length is set self-consistently from the local surface density. The
azimuthal injection zone spans an angle ``phi_inject`` on each side of the
domain boundaries at :math:`\pm\mathtt{phimax}`, ensuring a continuous,
steady-state flow through the sector.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
