.. phantom-doc: hand-written

apr
===

Overview
--------

The ``apr`` module is the top-level driver for Phantom's live adaptive
particle refinement (APR) system. APR dynamically splits high-resolution
particles from low-resolution ones (or merges them back) during a simulation
run, allowing greater numerical resolution in regions of interest such as
forming stars, planet-forming clumps, or accretion disc instabilities,
without the memory cost of maintaining full resolution everywhere.

The two public routines are ``init_apr``, called at startup to initialise
the APR level array and set the particle-mass hierarchy, and
``update_apr``, called each timestep to check whether any particles have
crossed APR region boundaries and to perform the necessary splits or
merges. The splitting direction is controlled by ``split_dir``: along the
radius vector (``1``), along the particle trajectory (``2``), or randomly
(``3``). When splitting, new child particles are placed on a sub-lattice
and optionally relaxed to their equilibrium positions using ``relaxem``.

Physical & Mathematical Description
------------------------------------

Each APR level :math:`\ell` corresponds to a particle mass
:math:`m_\ell = m_\text{base} / 8^{\ell-1}`, so a level-2 particle has
one-eighth the mass of a level-1 particle. Splitting one level-:math:`\ell`
particle creates eight level-:math:`(\ell+1)` children placed at the
vertices of a cube of side :math:`\Delta r \approx h/(2^{1/3})` centred on
the parent. Merging recombines eight children back into one parent, conserving
total mass and momentum. The APR update checks each particle's position
against the region boundaries defined in ``get_apr_level`` and triggers
splits or merges as appropriate.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/apr.f90
