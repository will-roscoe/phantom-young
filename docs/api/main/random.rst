.. phantom-doc: hand-written

random
======

Overview
--------

The ``random`` module collects the random number generation routines used
throughout Phantom for particle setups, injection schemes, and stochastic
physics. The primary generator ``ran2`` wraps the L'Ecuyer combined
multiplicative congruential generator (``get_random``), which has a claimed
cycle length of :math:`2.3 \times 10^{18}` and is suitable for large-scale
particle placement. A simplified single-seed interface is provided via
``ran2`` that manages a second internal seed automatically.

Additional sampling routines build on the uniform generator:
``gauss_random`` draws from a Gaussian distribution using the Box-Muller
transform, ``rayleigh_deviate`` draws from a Rayleigh distribution,
``get_random_pos_on_sphere`` places a point uniformly on the unit sphere
using the Marsaglia (1972) rejection method, ``get_gaussian_pos_on_sphere``
samples from a Gaussian distribution on the sphere, and
``rinsphere``/``ronsphere`` place points uniformly inside or on the surface
of a sphere of given radius. The ``divide_unit_seg`` routine partitions
the unit interval into :math:`N` equal-probability segments.

Physical & Mathematical Description
------------------------------------

The Gaussian sampler uses the Box-Muller transform: given two independent
uniform deviates :math:`U_1, U_2 \in (0,1)`,

.. math::

   X_1 = \sqrt{-2\ln U_1}\,\cos(2\pi U_2), \quad
   X_2 = \sqrt{-2\ln U_1}\,\sin(2\pi U_2)

are independent standard normal deviates. The uniform sphere sampling uses
the Marsaglia (1972) method: generate :math:`(x_1, x_2)` uniform on the
unit disc, then the point
:math:`(2x_1\sqrt{1-x_1^2-x_2^2},\, 2x_2\sqrt{1-x_1^2-x_2^2},\, 1-2(x_1^2+x_2^2))`
is uniform on the unit sphere.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/random.f90
