.. phantom-doc: hand-written

geometry
========

Overview
--------

The ``geometry`` module provides bijective mappings between eight coordinate
systems for both particle positions and vector components. It is a standalone
module with no dependencies on other Phantom modules, making it suitable for
use in setup routines, post-processing tools, and the SPLASH visualisation
package from which it originates (Daniel Price, 2004–2021). Any routine that
needs to express coordinates or velocity fields in a non-Cartesian frame
should call the public interfaces of this module rather than performing the
trigonometric transformations inline.

Eight coordinate systems are supported, identified by the integer flag
``igeom``: (1) Cartesian :math:`(x, y, z)`; (2) cylindrical
:math:`(R, \phi, z)`; (3) spherical :math:`(r, \phi, \theta)` — note that
Phantom orders :math:`\phi` before :math:`\theta`; (4) toroidal
:math:`(r, \theta, \phi)`; (5) rotated Cartesian :math:`(x_1, x_2, x_3)`;
(6) flared cylindrical :math:`(R, \phi, z')`; (7) log-flared cylindrical; and
(8) planet-wake coordinates. Each system is identified by its ``igeom`` index
and the module dispatches to the appropriate transformation via a select-case
block.

The four public subroutines are ``coord_transform`` (position coordinates),
``vector_transform`` (contravariant vector components), ``coord_transform_limits``
(coordinate range limits), and ``get_scale_factors`` (metric scale factors
:math:`h_i`). The ``get_coord_limits`` routine returns the valid range of each
coordinate in a given system, which is used by visualisation and setup tools to
set sensible axis bounds.

Written as a self-contained utility, ``geometry`` is designed to be compiled and
linked independently of the rest of Phantom and has been shared with the SPLASH
visualisation code. Changes to coordinate definitions must therefore be kept
consistent between the two codebases.

Physical & Mathematical Description
------------------------------------

The cylindrical coordinate relations are

.. math::

   R = \sqrt{x^2 + y^2}, \quad
   \phi = \arctan\!\left(\frac{y}{x}\right), \quad
   z' = z.

The spherical coordinate relations are

.. math::

   r = \sqrt{x^2 + y^2 + z^2}, \quad
   \phi = \arctan\!\left(\frac{y}{x}\right), \quad
   \theta = \arccos\!\left(\frac{z}{r}\right).

Volume elements in curvilinear coordinates are expressed using metric scale
factors :math:`h_i` such that

.. math::

   \mathrm{d}V = h_1\,h_2\,h_3\;\mathrm{d}u_1\,\mathrm{d}u_2\,\mathrm{d}u_3.

For cylindrical coordinates :math:`(R, \phi, z)` the scale factors are
:math:`(1,\,R,\,1)`, giving :math:`\mathrm{d}V = R\,\mathrm{d}R\,\mathrm{d}\phi\,\mathrm{d}z`.
For spherical coordinates :math:`(r, \phi, \theta)` the scale factors are
:math:`(1,\,r\sin\theta,\,r)`, giving
:math:`\mathrm{d}V = r^2\sin\theta\,\mathrm{d}r\,\mathrm{d}\phi\,\mathrm{d}\theta`.

Vector components are transformed using the Jacobian matrix
:math:`J^i_{\ j} = \partial x^i / \partial u^j` of the coordinate change.
For a contravariant vector :math:`\mathbf{v}` with components :math:`v^i` in
Cartesian coordinates, the components in the new system are

.. math::

   \tilde{v}^i = \sum_j \frac{\partial u^i}{\partial x^j}\,v^j,

where the inverse Jacobian :math:`\partial u^i / \partial x^j` is evaluated
analytically for each supported coordinate pair in ``vector_transform``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/geometry.f90
