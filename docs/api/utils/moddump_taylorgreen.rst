.. phantom-doc: hand-written

moddump\_taylorgreen
====================

Overview
--------

``moddump_taylorgreen`` superimposes a Taylor-Green vortex velocity field on an existing Phantom particle dump, replacing all pre-existing velocities. It was written by Daniel Price. The velocity field amplitude is set to :math:`v_0 = 0.1` in code units, producing a sub-sonic initial perturbation suitable for turbulence decay studies.

The routine iterates over all SPH particles and assigns the sinusoidal Taylor-Green pattern in the :math:`x`--:math:`y` plane, with the :math:`z`-component set to zero. This two-dimensional vortex structure is a standard benchmark for turbulence codes because its exact solution at early times is known analytically.

The moddump is a lightweight utility requiring no external dependencies beyond ``physcon`` for :math:`\pi`, making it straightforward to apply to any existing dump regardless of its EOS or particle type configuration.

Physical & Mathematical Description
------------------------------------

The Taylor-Green velocity field is :math:`v_x = v_0 \sin(2\pi x)\cos(2\pi y)`, :math:`v_y = -v_0 \cos(2\pi x)\sin(2\pi y)`, :math:`v_z = 0`. This is a divergence-free (:math:`\nabla \cdot \mathbf{v} = 0`) initial condition whose kinetic energy decays as :math:`E_k(t) = E_{k,0} \exp(-8\pi^2 \nu t)` for viscosity :math:`\nu` in the linear regime.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_taylorgreen.f90`` for the complete source.
