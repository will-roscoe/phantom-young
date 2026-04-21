.. phantom-doc: hand-written

eos_tillotson — Tillotson Equation of State for Solids and Fluids
=================================================================

Overview
--------

The ``eos_tillotson`` module implements the Tillotson (1962) equation of state,
which describes the thermodynamic behaviour of solid or fluid materials — such as
basalt, granite, ice, and iron — under hypervelocity impact conditions.  The EOS
interpolates between a compressed/cold state and a hot, expanded vapour state,
capturing the physics of shock compression, melting, and vaporisation that occur
in planetary impact simulations.

This EOS is selected by ``ieos = 23`` in the Phantom input file and is appropriate
for simulations of planetesimal collisions, giant impacts, and related problems in
planetary science.  The implementation follows Benz, Slattery & Cameron (1986),
Asphaug & Melosh (1993), and Kegerreis et al. (2019).  Default parameters
correspond to basalt (reference density :math:`\rho_0 = 2.7\ \mathrm{g\,cm^{-3}}`).

Bodies set up with this EOS should be initialised with a uniform density equal to
or close to the reference density :math:`\rho_0`; the EOS is undefined for
:math:`\rho \ll \rho_0` in the cold state.

Physical & Mathematical Description
-------------------------------------

Three pressure regimes are identified by comparing the density to the reference
density :math:`\rho_0` and the specific internal energy :math:`u` to two
threshold energies: the incipient vaporisation energy :math:`u_{\rm iv}` and
the complete vaporisation energy :math:`u_{\rm cv}`.

Define the dimensionless density variables:

.. math::

   \eta = \frac{\rho}{\rho_0}, \qquad
   \mu  = \eta - 1, \qquad
   \nu  = \frac{1}{\eta} - 1, \qquad
   \omega = \frac{u}{u_0\,\eta^2} + 1.

**Compressed / cold state** (:math:`\rho \ge \rho_0` or :math:`u < u_{\rm iv}`):

.. math::

   P_c = \left[a + \frac{b}{\omega}\right]\rho\,u + A\mu + B\mu^2

where :math:`a`, :math:`b`, :math:`A`, :math:`B`, and :math:`u_0` are
material-dependent constants.

**Hot, expanded state** (:math:`\rho < \rho_0` and :math:`u > u_{\rm cv}`):

.. math::

   P_e = a\,\rho\,u + \left[\frac{b\,\rho\,u}{\omega}
         + A\,\mu\,\exp(-\beta\,\nu)\right]\exp(-\alpha\,\nu^2)

**Hybrid (intermediate) state** (:math:`\rho < \rho_0` and
:math:`u_{\rm iv} \le u \le u_{\rm cv}`):

.. math::

   P = \frac{(u - u_{\rm iv})\,P_e + (u_{\rm cv} - u)\,P_c}{u_{\rm cv} - u_{\rm iv}}

The sound speed in each regime is derived from the corresponding derivative of
pressure with respect to density at constant internal energy, and the effective
adiabatic index is

.. math::

   \gamma = 1 + \frac{P}{\rho\,u}.

**Default material parameters (basalt, Benz & Asphaug 1999):**

.. list-table::
   :header-rows: 1
   :widths: 20 20 60

   * - Symbol
     - Default value
     - Description
   * - :math:`\rho_0`
     - 2.7 g cm\ :sup:`-3`
     - Reference (zero-pressure) density
   * - :math:`a`
     - 0.5
     - Dimensionless material parameter
   * - :math:`b`
     - 1.5
     - Dimensionless material parameter
   * - :math:`\alpha`
     - 5.0
     - Dimensionless expansion parameter
   * - :math:`\beta`
     - 5.0
     - Dimensionless expansion parameter
   * - :math:`A`
     - :math:`2.67 \times 10^{11}\ \mathrm{erg\,cm^{-3}}`
     - Bulk modulus
   * - :math:`B`
     - :math:`2.67 \times 10^{11}\ \mathrm{erg\,cm^{-3}}`
     - Second bulk modulus
   * - :math:`u_0`
     - :math:`4.87 \times 10^{12}\ \mathrm{erg\,g^{-1}}`
     - Reference internal energy
   * - :math:`u_{\rm iv}`
     - :math:`4.72 \times 10^{10}\ \mathrm{erg\,g^{-1}}`
     - Incipient vaporisation energy
   * - :math:`u_{\rm cv}`
     - :math:`1.82 \times 10^{11}\ \mathrm{erg\,g^{-1}}`
     - Complete vaporisation energy

Derivations
-----------

The compressed-state sound speed squared is derived from
:math:`c_c^2 = \partial P_c / \partial\rho |_u`:

.. math::

   c_c^2 = \left[a + \frac{b}{\omega}\right]u
          - \frac{b\,\rho\,u}{\omega^2}\frac{\partial\omega}{\partial\rho}
          + \frac{A + 2B\mu}{\rho_0}

where :math:`\partial\omega/\partial\rho = -2u/(u_0\eta^3\rho_0)`.
An analogous expression applies for the expanded state.  A minimum sound
speed estimate :math:`c_{\min}^2 = A/\rho_0` (the elastic wave speed) is
applied to prevent pathologically small values in the compressed state.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Tillotson, J. H. 1962, Metallic equations of state for hypervelocity impact, GA-3216, General Atomic — original EoS formulation
- Benz, W., Slattery, W. L. & Cameron, A. G. W. 1986, Icarus, 66, 515 — implementation and validation
- Asphaug, E. & Melosh, H. J. 1993, Icarus, 101, 144 — revised implementation used here
- Kegerreis, J. A. et al. 2019, MNRAS, 487, 5029 — updated implementation and parameter sets
- Benz, W. & Asphaug, E. 1999, Icarus, 142, 5 — basalt parameters

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_tillotson.f90
=============

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

.. f:autosrcfile:: ../../../src/main/eos_tillotson.f90
