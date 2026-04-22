.. phantom-doc: hand-written

apr_region
==========

Overview
--------

The ``apr_region`` module defines the supported APR region geometries and
provides routines to set and update the centre of each refinement zone as
the simulation evolves. Currently supported region types are: (1) a static
sphere at a fixed position read from the ``.in`` file; (2) a sphere that
tracks a named sink particle; (3) a sphere that follows self-gravitating
fragments detected dynamically in the disc; (4) a sphere centred between two
sequential sink particles (for binary systems); (5) a sphere centred on the
system centre of mass; and (6) a vertical refinement zone.

The public routine ``set_apr_centre`` updates the APR centre coordinates
``apr_centre`` for the current simulation time by querying sink particle
positions, the centre of mass, or fragment positions depending on the active
``apr_type``. The companion routine ``set_apr_regions`` initialises the
array of region radii. These routines import all their state from
``utils_apr`` and act as a thin region-geometry layer above the core APR
level-assignment routines in ``get_apr_level``.

Physical & Mathematical Description
------------------------------------

For all spherical region types the APR zone is a sequence of concentric
shells of radii :math:`r_\ell = r_\text{APR} + (\ell-1)\,\Delta r_\text{APR}`
for :math:`\ell = 1, \ldots, \ell_\text{max}`. A particle at radius
:math:`r` from the APR centre is assigned level :math:`\ell` such that
:math:`r_{\ell-1} < r \leq r_\ell`. Moving the centre (e.g., to follow a
sink) does not change the zone geometry; it simply shifts which particles
fall in each shell at the next ``update_apr`` call.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/apr_region.f90
