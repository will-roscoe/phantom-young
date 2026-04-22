.. phantom-doc: hand-written

extern_staticsine — Static Sinusoidal Density-Wave Potential
=============================================================

Overview
--------

The ``extern_staticsine`` module implements a one-dimensional, static sinusoidal
external potential.  It is intended primarily for testing and code-verification
purposes — for example, checking that SPH correctly captures linear and nonlinear
wave dynamics — as well as for idealised studies of density-wave perturbations in
disc and shearing-box simulations.

The potential takes the form
:math:`\Phi = A\cos\bigl(k(x'+B)\bigr)`,
where :math:`x' = x\cos\theta - y\sin\theta` is the coordinate along the wave
propagation direction, :math:`A` = ``amplitude``, :math:`k` = ``wavek``,
:math:`B` = ``phase``, and :math:`\theta` = ``inclination`` is the orientation angle
of the perturbation in the :math:`x`–:math:`y` plane (in radians; zero aligns the
wave with the :math:`x`-axis).

The module is activated when ``iexternalforce = iext_staticsine``.  The force is
purely two-dimensional (:math:`f_z = 0`) and can be rotated in the horizontal plane
to any azimuthal angle.

Physical & Mathematical Description
-------------------------------------

The potential and its associated body force are

.. math::

   \Phi(x, y)
   = A\cos\!\bigl(k(x'+B)\bigr),
   \quad
   x' = x\cos\theta - y\sin\theta,

.. math::

   f_i = -\frac{\partial\Phi}{\partial x_i}
        = Ak\sin\!\bigl(k(x'+B)\bigr)\,\hat{n}_i,

where the wave-normal unit vector is
:math:`\hat{n} = (\cos\theta,\,-\sin\theta,\,0)`.  In component form:

.. math::

   f_x = Ak\sin\!\bigl(k(x'+B)\bigr)\cos\theta,
   \qquad
   f_y = -Ak\sin\!\bigl(k(x'+B)\bigr)\sin\theta,
   \qquad
   f_z = 0.

For :math:`\theta = 0` this reduces to a pure :math:`x`-directed sinusoidal force
:math:`f_x = Ak\sin(k(x+B))`, :math:`f_y = f_z = 0`.  The amplitude ``amplitude``
and wavenumber ``wavek`` set the strength and spatial frequency of the perturbation;
``phase`` shifts the wave origin.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_staticsine.f90
