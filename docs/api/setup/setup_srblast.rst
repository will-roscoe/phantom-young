.. phantom-doc: hand-written

setup_srblast
=============

Overview
--------

``setup_srblast`` sets up a special-relativistic blast wave problem. A high-pressure sphere of radius ``rblast`` is embedded in a low-pressure uniform background; both regions are specified by their pressures ``pblast`` and ``pmed``. The contact discontinuity at the sphere boundary is smoothed over a length ``smoothfac`` times the initial particle spacing to reduce post-shock noise. Particles are placed on a uniform Cartesian lattice using ``set_unifdis``.

This test targets Phantom's special-relativistic hydrodynamics solver. The relativistic Rankine-Hugoniot conditions differ from the Newtonian case: the shock velocity is limited by :math:`c`, and the compression ratio approaches :math:`(\gamma+1)/(\gamma-1) + (\gamma+1) e / (\rho c^2)` in the ultra-relativistic limit. Comparison with analytic or high-resolution reference solutions provides a convergence test.

Units are set using Phantom's unit system with ``set_units``, and the adiabatic index and relativistic equation of state are applied consistently with the SR hydrodynamics module.

Physical & Mathematical Description
------------------------------------

In special relativistic hydrodynamics the energy-momentum tensor is :math:`T^{\mu\nu} = (e + P) u^\mu u^\nu / c^2 + P g^{\mu\nu}`, where :math:`e` is the energy density and :math:`u^\mu` is the four-velocity. The relativistic Rankine-Hugoniot conditions give a shock speed :math:`v_s < c`, and the Lorentz factor of the post-shock material is :math:`\Gamma_s = 1/\sqrt{1 - v_s^2/c^2}`. For an ultra-relativistic gas (:math:`P \gg \rho c^2`) the effective adiabatic index approaches :math:`4/3`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_srblast.f90`` for the complete source.
