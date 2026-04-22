.. phantom-doc: hand-written

utils_orbits
============

Overview
--------

The ``orbits`` module provides utility routines for Keplerian orbital
mechanics, converting between Cartesian state vectors :math:`(\mathbf{r},
\mathbf{v})` and the classical orbital elements (semi-major axis,
eccentricity, inclination, argument of periapsis, longitude of ascending
node, true anomaly). These routines are used in setup scripts, post-processing
tools, and GR orbit initialisation.

Public routines include: ``Rochelobe_estimate`` (Eggleton 1983 formula for
the Roche lobe radius), ``L1_point`` (Lagrange L1 location), and a full
suite of orbital element extractors — ``get_semimajor_axis``,
``get_orbital_period``, ``get_eccentricity`` and
``get_eccentricity_vector``, ``get_pericentre_distance``,
``get_inclination``, ``get_argument_of_periapsis``,
``get_longitude_of_ascending_node``, and ``get_true_anomaly``.

Physical & Mathematical Description
------------------------------------

The Eggleton (1983) Roche lobe estimate uses the fitting formula

.. math::

   r_L / a = \frac{0.49 q^{2/3}}{0.6 q^{2/3} + \ln(1 + q^{1/3})},

where :math:`q = M_1/M_2` is the mass ratio and :math:`a` is the orbital
separation. Orbital elements are derived from the specific angular momentum
:math:`\mathbf{h} = \mathbf{r} \times \mathbf{v}` and the eccentricity
vector :math:`\mathbf{e} = \mathbf{v} \times \mathbf{h}/\mu - \hat{\mathbf{r}}`,
where :math:`\mu = G(M_1 + M_2)`.

References
----------

.. bibliography:: ../../phantom.bib
   :filter: key in {"eggleton83"}
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_orbits.f90
