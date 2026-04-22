.. phantom-doc: hand-written

porosity
========

Overview
--------

The ``porosity`` module implements the evolution of dust aggregate porosity
(filling factor) for the porous dust growth model in Phantom. Porous dust
aggregates are characterised by a filling factor :math:`\phi` (the ratio of
solid material volume to total aggregate volume), which evolves as aggregates
grow, bounce, fragment, and compact. The physics follows the models of
Okuzumi et al. (2012), Garcia & Gonzalez (2020), Tatsuuma & Kataoka (2021),
and Michoulier & Gonzalez (2022).

The public routines include ``init_porosity`` and ``init_filfac`` for
setup, ``get_filfac`` for computing the updated filling factor after a
collision, ``get_disruption`` for checking whether rotational disruption
occurs, and ``get_probastick`` for computing the sticking probability as
a function of collision velocity. Options ``ibounce``, ``icompact``, and
``idisrupt`` enable/disable bouncing, compaction during fragmentation, and
rotational disruption respectively. Monomer properties (size, surface energy,
Young's modulus) are configurable runtime parameters.

The module computes characteristic velocities for sticking, bouncing, and
fragmentation transitions, which depend on the rolling energy
:math:`E_\text{roll}` and the aggregate structure. The Okuzumi b-parameter
``b_oku = 0.15`` and the common ratio ``cratio`` control the filling-factor
evolution law.

Physical & Mathematical Description
------------------------------------

The filling factor :math:`\phi` of a porous aggregate evolves during a
collision according to the static compression model. After a hit-and-stick
collision the aggregate is more porous (:math:`\phi` decreases); during
compressive bouncing or fragmentation events :math:`\phi` increases. The
rolling energy threshold is

.. math::

   E_\text{roll} = 6\pi^2 \gamma_s a_0 \xi_\text{crit},

where :math:`\gamma_s` is the surface energy, :math:`a_0` is the monomer
radius, and :math:`\xi_\text{crit}` is the critical rolling displacement.
Fragmentation is triggered when the aggregate kinetic energy exceeds the
tensile strength :math:`\propto \phi^3`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/porosity.f90
