.. phantom-doc: hand-written

moddump\_sink2gas
=================

Overview
--------

``moddump_sink2gas`` is a dump-modification utility that converts sink particles in an existing Phantom dump into resolved, self-gravitating gaseous spheres or stellar objects. It was written by Daniel Price and relies on the ``setstar`` infrastructure to place and optionally relax each replacement sphere in place of the original sink.

The routine reads the current sink-particle table (``xyzmh_ptmass``, ``vxyz_ptmass``) and, for each sink, inserts a distribution of SPH gas particles representing a star. The stellar profile (mass, radius, equation of state) is supplied through a ``star_t`` derived type via ``read_options_stars``. An optional relaxation step equilibrates internal pressure gradients before the run continues.

This moddump is particularly useful when a simulation begins with sink particles standing in for stellar companions and later requires fully resolved hydrodynamic or radiation-hydrodynamic treatment of those stars, for example during common-envelope in-spiral or stellar merger setups.

Physical & Mathematical Description
------------------------------------

Each replacement sphere is placed at the position and velocity of the original sink and populated with a polytropic density profile :math:`P = K \rho^{\gamma}`, where :math:`K` is determined from the stellar mass and radius. The specific thermal energy of each particle is :math:`u = P / [(\gamma - 1) \rho]`. If relaxation is enabled, the sphere evolves under SPH pressure and self-gravity until kinetic energy falls below a convergence threshold, minimising the residual velocity field :math:`|\mathbf{v}| / c_s \ll 1`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_sink2gas.f90`` for the complete source.
