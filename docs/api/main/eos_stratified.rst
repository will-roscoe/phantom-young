.. phantom-doc: hand-written

eos_stratified — Vertically Stratified Disc Equation of State
=============================================================

Overview
--------

The ``eos_stratified`` module implements a vertically stratified locally isothermal
equation of state for protoplanetary and protostellar disc simulations.  In contrast
to the radially-stratified disc EOS (``ieos = 3``), this prescription introduces an
explicit dependence of the sound speed on the height :math:`z` above the disc
mid-plane, allowing the disc atmosphere to be hotter (and therefore more
pressure-supported) than the mid-plane.

This EOS is selected by ``ieos = 7`` in the Phantom input file.  It supports two
temperature structure prescriptions, controlled by the integer ``istrat``:

* ``istrat = 0`` — the MAPS prescription, based on a modified version of equation 6
  from Law et al. (2021), in which the transition between mid-plane and atmospheric
  temperature is smooth and controlled by the ``alpha_z`` parameter.
* ``istrat = 1`` — the Dartois et al. (2003) prescription, which uses a cosine
  profile below a critical height :math:`z_q` and the atmospheric temperature above.

The module should not be used for misaligned discs, because the height :math:`z`
is measured from the :math:`x`-:math:`y` plane rather than from the local disc
plane.

Physical & Mathematical Description
-------------------------------------

Both prescriptions are expressed in terms of two reference sound speeds:

* :math:`c_{s,\rm mid}^2 = K_1\,R^{-2q_1}` — mid-plane sound speed at cylindrical
  radius :math:`R = \sqrt{x^2 + y^2}`.
* :math:`c_{s,\rm atm}^2 = K_2\,R^{-2q_2}` — atmospheric sound speed.

The characteristic height is

.. math::

   z_q = z_0\,R^{\beta_z / 2}

where :math:`z_0` and :math:`\beta_z` are user-supplied parameters.

**Dartois et al. (istrat = 1):**

.. math::

   c_s^2(R,z) =
   \begin{cases}
     c_{s,\rm atm}^2 + (c_{s,\rm mid}^2 - c_{s,\rm atm}^2)\,
     \cos^2\!\!\left(\frac{\pi\,z}{2\,z_q}\right)
     & |z| \le z_q \\[6pt]
     c_{s,\rm atm}^2 & |z| > z_q
   \end{cases}

**MAPS (istrat = 0):**

.. math::

   c_s^2(R,z) = \left[c_{s,\rm mid}^4
     + \tfrac{1}{2}\!\left(1 + \tanh\!\left(\frac{|z| - \alpha_z\,z_q}{z_q}\right)\right)
     c_{s,\rm atm}^4\right]^{1/4}

This functional form provides a smooth transition from the mid-plane to the
atmosphere with the steepness controlled by the parameter :math:`\alpha_z`.

The pressure and sound speed are then

.. math::

   P = c_s^2(R,z)\,\rho, \qquad c_s = \sqrt{c_s^2(R,z)}.

Derivations
-----------

The parameters are stored in the dump header for both prescriptions:
``polyk`` (:math:`= c_{s,\rm mid}^2` at :math:`R = 1`), ``polyk2``
(:math:`= c_{s,\rm atm}^2` at :math:`R = 1`), ``qfacdisc`` (:math:`= q_1`),
``qfacdisc2`` (:math:`= q_2`), ``alpha_z``, ``beta_z``, ``z0``, and ``istrat``.
The code enforces ``qfacdisc2 > 0``; a zero value generates a run-time error.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Dartois, E., Dutrey, A. & Guilloteau, S. 2003, A&A, 399, 773 — vertically stratified disc temperature prescription (istrat=1)
- Law, C. J. et al. 2021, ApJS, 257, 3 — MAPS disc temperature prescription (istrat=0)

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_stratified.f90
==============

Overview
--------

.. todo:: Add overview narrative.

Physical & Mathematical Description
-------------------------------------

.. todo:: Add mathematical description with ``.. math::`` blocks.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_stratified.f90
