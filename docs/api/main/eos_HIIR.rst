.. phantom-doc: hand-written

eos_HIIR — HII Region Two-Temperature Equation of State
=======================================================

Overview
--------

The ``eos_HIIR`` module implements a two-temperature equation of state for
HII region simulations, in which the sound speed of a fluid particle is
determined by whether that particle is currently ionised.  Neutral particles
follow the standard isothermal or adiabatic EOS with the ambient sound speed
``polyk``, while ionised particles are assigned a fixed warm temperature
:math:`T_{\rm ion} = 10^4\ \mathrm{K}` corresponding to a much higher sound
speed :math:`c_{s,\rm ion}`.

The module provides two variants: an isothermal version (``ieos = 21``, used
when compiled with ``ISOTHERMAL=yes``) and an adiabatic version (``ieos = 22``,
used when the specific internal energy is stored).  Both are called from the
master dispatcher in :doc:`eos`, which passes the boolean ``isionised`` flag
that controls which branch is taken.

This prescription is appropriate for photoionisation or radiative transfer
applications in which a two-phase medium (warm HII / cool neutral) is
maintained at run time through external flagging of particles.  The mean
molecular weight of the ionised gas is set to :math:`\mu_{\rm ion} = 0.5`,
reflecting a fully ionised hydrogen plasma in which the number of free particles
(electrons + protons) is twice the number of hydrogen atoms.

Physical & Mathematical Description
-------------------------------------

The ionised sound speed is precomputed at initialisation:

.. math::

   c_{s,\rm ion}^2 = \frac{\mu_{\rm ion}^{-1}\,k_B\,T_{\rm ion}}{m_H}

where :math:`\mu_{\rm ion}^{-1} = 2` (two free particles per proton mass),
:math:`T_{\rm ion} = 10^4\ \mathrm{K}`, and :math:`k_B/m_H` is the Boltzmann
constant per unit proton mass (``kb_on_mh`` in code units).  This value is
stored as ``polykion`` and used in subsequent EOS calls.

**Isothermal variant (ieos = 21):**

.. math::

   \frac{P}{\rho} =
   \begin{cases}
     c_{s,\rm ion}^2 & \text{ionised} \\
     c_s^2           & \text{neutral}
   \end{cases}

where :math:`c_s^2 =` ``polyk`` is the ambient isothermal sound speed squared.

**Adiabatic variant (ieos = 22):**

For ionised particles the pressure is again :math:`P = \rho\,c_{s,\rm ion}^2`
(an effective isothermal prescription at :math:`T_{\rm ion}`).  For neutral
particles the standard adiabatic relation is used:

.. math::

   \frac{P}{\rho} = (\gamma - 1)\,u \quad \text{(if } u \text{ available)}, \qquad
   \text{or} \qquad
   \frac{P}{\rho} = K\,\rho^{\gamma-1} \quad \text{(polytropic fallback)}.

Derivations
-----------

The ionised sound speed ``polykion`` is computed once in ``init_eos_HIIR``:

.. math::

   \text{polykion} = \frac{\mu_{\rm ion}^{-1}\,k_B/m_H\,T_{\rm ion}}{v_{\rm unit}^2}

converting the physical sound speed squared to code units via the velocity unit
:math:`v_{\rm unit}`.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- No specific literature reference is cited in the module header; the two-temperature HII prescription is a standard technique in computational astrophysics.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_HIIR.f90
