.. phantom-doc: hand-written

analysis_NSmerger
=================

Overview
--------

``analysis_NSmerger`` is a comprehensive interactive analysis routine for neutron star merger simulations, written by Bernard Field and Madeline Marshall under the supervision of James Wurster and Paul Lasky. It provides multiple analysis options (up to 20) that the user selects interactively, covering density profiles, velocity maps, angular momentum, gravitational wave output, and disc properties.

The routine requires full dump files and uses a density cutoff in CGS units to define the dense nuclear matter region. It computes the centre of mass of each neutron star component separately using ``get_centreofmass``, accounting for the merger stage at which the stars may still be distinguishable. The ``Nstar`` parameter from ``extern_gwinspiral`` tracks the number of NS components.

All outputs are in code units unless explicitly converted. The interactive design allows the user to run a subset of analyses tailored to specific science goals without processing all data at every call.

Physical & Mathematical Description
------------------------------------

In neutron star mergers the gravitational wave luminosity from the quadrupole formula is :math:`\dot{E}_\mathrm{GW} = -G/(5c^5) \sum_{jk} \dddot{I}_{jk}^2`, where :math:`I_{jk}` is the reduced mass quadrupole tensor. The nuclear matter density threshold ``density_cutoff_cgs`` (default :math:`5 \times 10^{-5}` g cm:math:`^{-3}`) defines the remnant boundary for mass and radius computations.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_NSmerger.f90`` for the complete source.
