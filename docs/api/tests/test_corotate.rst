.. phantom-doc: hand-written

test_corotate
=============

Overview
--------

The ``test_corotate`` module (Fortran module ``testcorotate``) verifies the Coriolis and
centrifugal force routines used when Phantom runs in a corotating reference frame. The
test instantiates arbitrary position and velocity vectors, sets a known angular velocity
``omega_corotate``, and then calls ``get_centrifugal_force`` and ``get_coriolis_force``
from ``extern_corotate``, comparing the returned force components to the closed-form
analytic expressions.

A third sub-test constructs a binary sink-particle system using ``setbinary``, places a
test particle at an arbitrary location in the orbital plane, and verifies that the net
corotating-frame force transforms consistently between the inertial and rotating frames.
This catches sign errors and missing factors in the frame-transformation code that would
be invisible in pure unit-vector tests.

All comparisons use machine-epsilon tolerances because the analytic expressions reduce to
simple algebraic products of the input scalars, so any deviation larger than round-off
indicates a coding error rather than a physical approximation error.

Physical & Mathematical Description
------------------------------------

In a frame rotating at angular velocity :math:`\boldsymbol{\Omega} = \Omega\hat{z}` the
centrifugal force on a particle at position :math:`\mathbf{r}` is
:math:`\mathbf{f}_{\rm cent} = \Omega^2 (x\hat{x} + y\hat{y})` and the Coriolis force is
:math:`\mathbf{f}_{\rm Cor} = 2\boldsymbol{\Omega}\times\mathbf{v}`, giving components
:math:`f_x = 2\Omega v_y` and :math:`f_y = -2\Omega v_x`. The centrifugal potential is
:math:`\phi = -\tfrac{1}{2}\Omega^2 R^2` where :math:`R^2 = x^2 + y^2`. Each of these
relations is checked to floating-point precision.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_corotate.f90
