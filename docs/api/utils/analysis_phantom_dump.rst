.. phantom-doc: hand-written

analysis_phantom_dump
=====================

Overview
--------

``analysis_phantom_dump`` prints the stellar radius and mass computed relative to the location of the particle with maximum density, providing a quick measure of the stellar structure in a tidal disruption event or stellar oscillation simulation. Written by Megha Sharma, it is designed for monitoring the surviving stellar remnant after a partial TDE.

On each dump the routine finds the particle with the highest density (taken as the stellar centre), sorts all other particles by distance from this centre, and integrates the cumulative mass profile outward until the stellar surface is reached. The radius enclosing a given fraction of the total mass is reported as the effective stellar radius.

Output is written to a file recording time, stellar radius, and stellar mass in code units (convertible to solar units via ``udist`` and ``umass``), enabling the remant's structural evolution to be tracked over successive post-disruption orbits.

Physical & Mathematical Description
------------------------------------

The stellar radius :math:`R_*` is defined as the radius enclosing a specified fraction of the total stellar mass, computed by sorting particles by distance from the density maximum and integrating :math:`M(r) = \sum_{i: r_i < r} m_i` outward. This is equivalent to the effective radius in a mass-radius profile, giving a physically meaningful stellar size for the SPH particle distribution.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_phantom_dump.f90`` for the complete source.
