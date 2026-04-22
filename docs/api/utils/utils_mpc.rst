.. phantom-doc: hand-written

utils_mpc
=========

Overview
--------

``utils_mpc`` (module ``mpc``) provides routines for reading orbital element data from files downloaded from the IAU Minor Planet Centre (MPC) database (https://minorplanetcenter.net/data). The ``read_mpc`` routine parses the Extended MPCORB format, extracting orbital elements (semi-major axis, eccentricity, inclination, etc.) and auxiliary data for each minor planet or comet.

The module defines derived types ``mpc_entry`` (for minor planets) and ``mpc_comet`` (for comets), with fields for the standard six Keplerian elements plus reference epoch, magnitude, slope parameter, and object name. The ``read_mpc`` routine is called with a filename and returns an allocatable array of ``mpc_entry`` records, one per object in the file.

This module is used in Phantom setup routines for solar system dynamics simulations, enabling realistic initial conditions for large numbers of minor planets or Trans-Neptunian Objects (TNOs) from the MPC catalogue.

Physical & Mathematical Description
------------------------------------

The MPC Extended format stores orbital elements in a fixed-width ASCII format: the semi-major axis :math:`a` (AU), eccentricity :math:`e`, inclination :math:`i` (degrees), longitude of ascending node :math:`\Omega` (degrees), argument of perihelion :math:`\omega` (degrees), and mean anomaly :math:`M_0` at the epoch :math:`t_0`. From these the position and velocity can be computed by solving Kepler's equation :math:`M_0 = E - e \sin E` and applying the standard coordinate rotation matrices.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_mpc.f90
