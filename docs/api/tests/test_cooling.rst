.. phantom-doc: hand-written

test_cooling
============

Overview
--------

The ``test_cooling`` module (Fortran module ``testcooling``) contains unit tests for the
Phantom cooling framework, which handles radiative energy losses in gas dynamics
simulations. The module exports both ``test_cooling``, the standard suite entry point, and
``test_cooling_rate``, a detailed sub-test that evaluates the ISM cooling function
``energ_cooling_ism`` over a wide temperature range from 1 K to 10⁸ K. Units are set to
galaxy-scale values (10⁷ solar masses, 1 kpc, G = 1) before any checks are performed.

The ``test_cooling_rate`` routine steps through 400 logarithmically spaced temperatures,
computes the chemical abundance evolution via ``update_abundances``, then evaluates the
net cooling rate in both code and CGS units. The results are written to a text file
``cooltable.txt`` for visual inspection and any single-temperature check that deviates by
more than a prescribed tolerance is flagged as a failure. At present the main
``test_cooling`` driver calls ``test_cooling_rate`` to exercise the ISM cooling path.

The module is designed to be easily extended: additional cooling functions (Stamatellos
opacity-based cooling, molecular cooling) can be called from the same driver by adding
further sub-tests, and the ``test_cooling_rate`` sub-routine can be invoked independently
from other test modules that need a verified cooling environment.

Physical & Mathematical Description
------------------------------------

The test evaluates the volumetric cooling rate
:math:`\Lambda(T) = -\dot{u} \rho` in units of erg s⁻¹ cm⁻³ as a function of gas
temperature :math:`T`, where :math:`\dot{u}` is the specific cooling rate returned by
``energ_cooling_ism``. At a reference temperature of :math:`T = 10^7` K the expected
cooling rate is compared to the tabulated value from the Sutherland & Dopita (1993)
collisional ionisation equilibrium curve, with a relative tolerance of approximately 1%.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/tests/test_cooling.f90
