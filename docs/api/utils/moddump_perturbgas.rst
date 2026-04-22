.. phantom-doc: hand-written

moddump_perturbgas
==================

Overview
--------

``moddump_perturbgas`` applies a random velocity perturbation to gas particles in an existing Phantom dump, enabling numerical noise to be injected into a relaxed configuration to excite modes or test stability. Written by Mike Lau, it accepts a ``--perturb_factor`` command-line flag controlling the amplitude of the perturbation.

Each gas particle receives a random velocity kick :math:`\delta v_i = f_\mathrm{perturb} v_i \xi_i`, where :math:`\xi_i` is a random unit vector and :math:`f_\mathrm{perturb}` is the perturbation factor (default 0.5). An optional ``--perturb_sink`` flag allows sink particle velocities to also be perturbed by a separate ``--sink_perturb_factor``.

This moddump is useful for studying the linear stability of equilibrium configurations (stars, discs, tori) by applying a small initial perturbation and observing the subsequent growth or damping of modes.

Physical & Mathematical Description
------------------------------------

The perturbed velocity of particle :math:`i` is :math:`\mathbf{v}_i' = \mathbf{v}_i (1 + f_\mathrm{perturb} \boldsymbol{\xi}_i)`, where :math:`\boldsymbol{\xi}_i` is a vector of random numbers drawn from the uniform distribution :math:`[-1, 1]` in each component. For ``perturb_factor = 0.5`` the maximum perturbation is 50% of the original velocity magnitude, which will excite all unstable modes while remaining within the linear regime for small perturbation amplitudes.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_perturbgas.f90`` for the complete source.
