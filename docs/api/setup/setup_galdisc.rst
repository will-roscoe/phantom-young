.. phantom-doc: hand-written

setup_galdisc
=============

Overview
--------

``setup_galdisc`` configures galactic disc simulations with live or analytic stellar, gaseous, and dust components. The disc occupies a radial range from ``rcylin`` to ``rcyl`` in kiloparsecs, with the total particle count set by ``np``. Particles can be distributed randomly or according to an observed surface density profile (controlled by ``partdist``). The velocity field can be set from a rotation curve, a flat profile, or a constant value (``vset``).

Optional live components — a stellar disc, a bulge, and a dark matter halo — can be included alongside the gas disc by enabling ``use_live_stars``, ``use_bulge``, and ``use_halo``. Dust can be added with a specified dust-to-gas ratio. An analytic spiral arm potential (``extern_spiral``) can be activated to impose spiral structure on an otherwise axisymmetric disc.

This setup is used to study galactic-scale star formation, spiral arm driven shocks, gas dynamics in barred spirals, and the gravitational stability of the disc measured by the Toomre :math:`Q` parameter.

Physical & Mathematical Description
------------------------------------

The Toomre stability parameter for the gaseous disc is :math:`Q = c_s \kappa / (\pi G \Sigma)`, where :math:`\kappa = \sqrt{R (d\Omega^2/dR) + 4\Omega^2}` is the epicyclic frequency and :math:`\Sigma` is the surface density. The disc becomes locally unstable when :math:`Q < 1`, leading to fragmentation. The angular velocity profile is set by the rotation curve :math:`v_c(R)` via :math:`\Omega = v_c / R`, with corrections for the radial pressure gradient in the gas component.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_galdisc.f90`` for the complete source.
