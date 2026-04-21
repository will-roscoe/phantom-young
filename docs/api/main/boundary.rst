.. phantom-doc: hand-written

boundary
========

Overview
--------
The ``boundary`` module defines the Cartesian domain boundaries used for
periodic boundary conditions in Phantom. It stores the six boundary coordinates
(``xmin``, ``xmax``, ``ymin``, ``ymax``, ``zmin``, ``zmax``) as module-level
public variables that are read throughout the code wherever periodicity
corrections are required.

The module is dependency-free: it uses no other Phantom modules and contains
only simple arithmetic. Its small size reflects the fact that boundary
conditions in SPH are implemented at the level of the neighbour search (via the
minimum-image convention applied during tree traversal) and position
correction (via the ``cross_boundary`` subroutine), rather than at the force
evaluation level.

Three public routines are provided:

- ``set_boundary`` — initialises the boundary coordinates. Accepts keyword
  arguments for individual faces, a single box length ``l`` (producing a
  symmetric box :math:`[-l/2, l/2]^3`), or a six-element position array.
  Subsidiary quantities ``dxbound``, ``dybound``, ``dzbound`` (box lengths),
  ``hdlx``, ``hdly``, ``hdlz`` (half-box lengths), and ``totvol`` (total
  volume) are computed automatically.
- ``cross_boundary`` — checks whether a particle has crossed a periodic
  boundary in each active dimension and applies the corresponding coordinate
  shift.
- ``print_boundaries`` — writes the boundary coordinates to the log file.

Physical & Mathematical Description
-------------------------------------
Periodic boundary conditions require that whenever a particle coordinate
:math:`x_a` satisfies :math:`x_a < x_{\rm min}` or :math:`x_a > x_{\rm max}`,
it is remapped by adding or subtracting the box length:

.. math::
   :label: periodic_wrap

   x_a \leftarrow x_a + L_x\quad \text{if } x_a < x_{\rm min},\qquad
   x_a \leftarrow x_a - L_x\quad \text{if } x_a > x_{\rm max},

where :math:`L_x = x_{\rm max} - x_{\rm min} = \texttt{dxbound}`. The same
applies independently in :math:`y` and :math:`z`.

In the neighbour search the minimum-image convention is applied to inter-particle
separations: for any pair :math:`(a,b)` the effective separation in dimension
:math:`x` is

.. math::

   \Delta x_{ab} = x_a - x_b - L_x \operatorname{round}\!\left(
                   \frac{x_a - x_b}{L_x}\right),

ensuring that the closest periodic image is used. This convention is applied
at the tree-traversal level in ``neighkdtree``, not within this module.

The ``isperiodic(1:3)`` logical array (defined in ``mpidomain``) controls
which dimensions are periodic. Only the dimensions for which
``isperiodic(k) = .true.`` are corrected by ``cross_boundary``.

The total simulation volume is

.. math::

   V = L_x\,L_y\,L_z = \texttt{totvol},

which is used in the computation of mean densities and normalisation of
turbulent driving spectra.

Derivations
-----------
Periodic and reflective boundary conditions are standard techniques in
computational fluid dynamics and require no non-trivial derivation. The
coordinate wrapping formula :eq:`periodic_wrap` is the direct implementation
of the mathematical requirement that the simulation domain be topologically
equivalent to a torus: :math:`x \equiv x \pmod{L_x}`. The minimum-image
convention for inter-particle separations follows from the same periodicity
requirement. Both procedures are self-evident from the formulae given in the
Physical & Mathematical Description section above, and no external literature
citation is required.

References
----------

No external literature reference is required for this computation; the method follows directly from standard discretisation principles.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/boundary.f90
