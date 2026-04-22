.. phantom-doc: hand-written

set_dust_options
================

Overview
--------

The ``set_dust_options`` module reads and writes the dust setup parameters
from and to the Phantom ``.in`` parameter file.  It acts as the
configuration layer between the user-facing runtime parameter file and the
dust-initialisation routines in ``set_dust``.  Parameters managed by this
module include the number of dust species, the minimum and maximum grain
sizes, the grain-size distribution power-law index, and the total initial
dust-to-gas ratio.

This module is called during the ``phantomsetup`` phase to populate the
parameter file with default dust options, and it is called again at the
start of a simulation to read those options back so that the setup
routines receive consistent inputs.  It does not place particles; it only
manages the I/O of dust configuration data.

Physical & Mathematical Description
------------------------------------

The grain-size distribution is parametrised as a differential number
density power law,

.. math::

   \frac{dn}{ds} \propto s^{-q_\mathrm{dust}},
   \qquad s \in [s_\mathrm{min},\, s_\mathrm{max}],

where :math:`s` is the grain radius, :math:`q_\mathrm{dust}` is the
size-distribution index (typically 3.5 for an MRN distribution), and
:math:`[s_\mathrm{min}, s_\mathrm{max}]` defines the grain-size range.
For :math:`N_\mathrm{dust}` logarithmically spaced bins the representative
grain size in bin :math:`k` is

.. math::

   s_k = s_\mathrm{min}\left(\frac{s_\mathrm{max}}{s_\mathrm{min}}
         \right)^{(k-1/2)/N_\mathrm{dust}}.

The stopping time and hence the aerodynamic coupling of each species to
the gas depends on :math:`s_k`, so the bin sizes directly affect the
dust dynamics.  The total dust-to-gas ratio read from the parameter file
is distributed among the bins using the weights implied by the above
power law (see ``set_dust``).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_dust_options.f90
