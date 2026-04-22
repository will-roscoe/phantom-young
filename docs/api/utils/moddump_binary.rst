.. phantom-doc: hand-written

moddump_binary
==============

Overview
--------

``moddump_binary`` converts a single-star dump into a binary system by adding a companion. The companion can be a sink particle (for common envelope simulations) or a second star from another dump file (for binary merger simulations). Maintained by Mike Lau, it supports the wide range of binary configurations needed for stellar evolution and common envelope studies.

For a sink companion, the routine uses ``set_binary`` from ``setbinary`` to position both stars on a Keplerian orbit with specified separation, mass ratio, and eccentricity. For a two-star configuration, it reads a second star from a separate dump file, centres both stars, and places them on the binary orbit using the combined mass.

The routine handles the corotating frame (``iext_corotate``) when requested, and sets up the binary in a frame where the centre of mass is at the origin with the orbital plane in the :math:`xy`-plane.

Physical & Mathematical Description
------------------------------------

The binary is initialised using the ``set_binary`` routine, which solves the two-body problem to place the stars at positions :math:`\mathbf{r}_1 = -\mu_2 \mathbf{r}_{12}` and :math:`\mathbf{r}_2 = \mu_1 \mathbf{r}_{12}` (mass-weighted from the CoM), with velocities from the vis-viva equation and the orbital angular momentum direction set by the inclination and argument of pericentre. The separation is :math:`|\mathbf{r}_{12}| = a(1 - e\cos E)` where :math:`E` is the eccentric anomaly.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_binary.f90`` for the complete source.
