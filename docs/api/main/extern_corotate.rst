.. phantom-doc: hand-written

extern_corotate — Corotating Frame Forces (Centrifugal and Coriolis)
=====================================================================

Overview
--------

The ``extern_corotate`` module implements the pseudo-forces required to simulate
dynamics in a frame that rotates with constant angular velocity
:math:`\boldsymbol{\Omega} = \Omega\,\hat{z}` about the :math:`z`-axis.  It is
activated when ``iexternalforce = iext_corotate`` and is also combined with the
binary potential when ``iexternalforce = iext_corot_binary``.

Two physical effects are treated.  The *centrifugal force* is purely position-dependent
and is handled as part of the standard spatial force evaluation in ``get_centrifugal_force``.
The *Coriolis force* :math:`-2\boldsymbol{\Omega}\times\mathbf{v}` is
velocity-dependent and must be treated implicitly in the leapfrog integrator to
remain stable; this is accomplished through ``update_coriolis``, which solves a
:math:`3\times 3` linear system at each corrector step.

Optionally, the gravity of one or two additional point masses in the corotating frame
can be included via the ``icompanion_grav`` switch: ``icompanion_grav = 1`` adds a
companion star potential, and ``icompanion_grav = 2`` adds both companion and primary
core potentials, softened with the SPH kernel via ``kernel_softening``.

Physical & Mathematical Description
-------------------------------------

In a frame rotating with angular velocity :math:`\boldsymbol{\Omega}`, the equation
of motion for a fluid parcel is

.. math::

   \frac{d^2\mathbf{r}}{dt^2}
   = \mathbf{f}_\mathrm{SPH}
     - 2\boldsymbol{\Omega}\times\frac{d\mathbf{r}}{dt}
     - \boldsymbol{\Omega}\times(\boldsymbol{\Omega}\times\mathbf{r}),

where the last two terms are the Coriolis and centrifugal accelerations respectively.

**Centrifugal force**

.. math::

   \mathbf{f}_\mathrm{cent}
   = -\boldsymbol{\Omega}\times(\boldsymbol{\Omega}\times\mathbf{r})
   = (\boldsymbol{\Omega}\times\mathbf{r})\times\boldsymbol{\Omega},

with associated potential :math:`\Phi_\mathrm{cent} = -\tfrac{1}{2}|\boldsymbol{\Omega}\times\mathbf{r}|^2`.
For :math:`\boldsymbol{\Omega} = (0,0,\Omega)` this gives

.. math::

   \mathbf{f}_\mathrm{cent} = \Omega^2(x,\,y,\,0),
   \qquad
   \Phi_\mathrm{cent} = -\tfrac{1}{2}\Omega^2(x^2+y^2).

**Coriolis force (implicit)**

The corrector step requires solving for the end-of-step velocity
:math:`\mathbf{v}^1` given the half-step velocity :math:`\mathbf{v}^{1/2}`:

.. math::

   \mathbf{v}^1 = \mathbf{v}^{1/2} + \tfrac{1}{2}\Delta t\,
                  \bigl[\mathbf{f}_\mathrm{SPH}
                        + 2\mathbf{v}^1\times\boldsymbol{\Omega}\bigr].

Rearranging gives the linear system :math:`R\,\mathbf{v}^1 = \mathbf{A}`, where

.. math::

   R = I - \tfrac{1}{2}\Delta t\,[\,2\boldsymbol{\Omega}\,]_\times,

with :math:`[\,\boldsymbol{\Omega}\,]_\times` the skew-symmetric cross-product
matrix.  This is inverted analytically via ``matrixinvert3D``.

References
----------

The corotating frame equations follow standard classical dynamics textbooks; see for
example:

- Tong, D. 2015, Classical Dynamics Lecture Notes, University of Cambridge — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_corotate.f90
