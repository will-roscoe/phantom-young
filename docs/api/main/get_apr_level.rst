.. phantom-doc: hand-written

get_apr_level
=============

Overview
--------

The ``get_apr_level`` module holds the procedure pointer ``get_apr`` and the
routines that implement each APR region geometry. At initialisation
``set_get_apr`` sets ``get_apr`` to point to the appropriate subroutine based
on the runtime parameter ``apr_type``: spherical regions, sink-centred
spheres, disc fragment tracking, binary-centred regions, centre-of-mass
regions, or vertical refinement. Once set, ``get_apr`` is called on every
particle each time the APR levels need to be updated.

The public subroutine ``create_or_update_apr_clump`` handles the special
case of APR type 3 (refinement around self-gravitating clumps), detecting
dense fragments in the simulation and dynamically updating the APR centres
to follow them. This allows the refinement zone to track condensing objects
such as protostellar cores or planet-forming clumps without any user
intervention.

Physical & Mathematical Description
------------------------------------

For the default spherical APR type, a particle at distance :math:`r` from
the APR centre is assigned level :math:`\ell` such that

.. math::

   r_\ell \leq r < r_{\ell+1}, \quad r_\ell = r_\text{APR} + (\ell - 1)\,
   \Delta r_\text{APR},

where :math:`r_\text{APR}` is the innermost region radius and
:math:`\Delta r_\text{APR}` is the step size between levels. Particles in
the innermost shell have the highest mass resolution (level 1), and each
outer shell contains particles of progressively lower resolution. The
splitting factor between levels is :math:`2^3 = 8` in 3D so that the
particle mass doubles with each level step.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/get_apr_level.f90
