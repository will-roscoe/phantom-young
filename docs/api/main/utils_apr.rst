.. phantom-doc: hand-written

utils_apr
=========

Overview
--------

The ``utils_apr`` module stores the runtime parameters and shared state for
Phantom's adaptive particle refinement system. It acts as the central data
repository for the APR configuration: the number of additional refinement
levels ``apr_max``, the refinement/de-refinement direction ``ref_dir``, the
region type ``apr_type``, the innermost region radius ``apr_rad``, the step
size between shells ``apr_drad``, the splitting direction ``split_dir``, the
tracked sink particle ``track_part``, and the APR centre coordinates.

The module provides ``read_options_apr`` and ``write_options_apr`` for
``.in`` file integration, and declares the allocatable arrays ``apr_regions``
and ``apr_centre`` that are sized according to the number of refinement
levels and tracked region centres. The ``rho_crit_cgs`` density threshold
(imported from ``ptmass``) is used for the fragment-tracking APR type.

Physical & Mathematical Description
------------------------------------

The key numerical parameter is the mass ratio between consecutive APR levels.
In 3D, splitting one particle into eight children in a cubic arrangement
changes the mass by a factor of 8, which maintains a constant SPH resolution
(smoothing length :math:`h \propto (m/\rho)^{1/3}`) across the refinement
boundary. The ``apr_H`` array stores the disc scale height at each radius for
use in the vertical APR type.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_apr.f90
