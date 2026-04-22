.. phantom-doc: hand-written

utils_ephemeris
===============

Overview
--------

``utils_ephemeris`` (module ``ephemeris``) provides routines for downloading and reading orbital element data from the JPL Horizons ephemeris web service (https://ssd-api.jpl.nasa.gov/). The ``get_ephemeris`` function returns the six Keplerian elements and additional parameters for any solar system body accessible via the Horizons API.

The module queries the JPL server for the specified object name (or designation) and epoch, downloading the orbital element file if it is not already cached locally. The returned elements include semi-major axis, eccentricity, inclination, longitude of ascending node, argument of perihelion, and mean anomaly.

This module is used in Phantom setup routines for solar system simulations (e.g. N-body integrations of planetary systems) to initialise particle orbits from actual ephemeris data rather than approximate analytic formulae.

Physical & Mathematical Description
------------------------------------

The Horizons API returns osculating Keplerian elements :math:`(a, e, i, \Omega, \omega, M_0)` at the specified epoch, where :math:`a` is in AU, inclination and angles in degrees, and :math:`M_0` is the mean anomaly. The function returns ``nelem = 9`` orbital parameters including auxiliary quantities. Conversion from the mean anomaly :math:`M_0` to true anomaly :math:`f` requires solving Kepler's equation :math:`M = E - e \sin E`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/utils_ephemeris.f90
