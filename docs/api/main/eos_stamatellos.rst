.. phantom-doc: hand-written

eos_stamatellos — Tabulated Opacity/EoS for Radiative Cooling (ieos = 24)
=========================================================================

Overview
--------

The ``eos_stamatellos`` module provides the tabulated equation-of-state and opacity
infrastructure used by the ``icooling = 9`` radiative cooling approximation in
Phantom (the method of Stamatellos et al. 2007, as extended by Young et al. 2024).
Rather than solving the full radiation-transport problem, this approach approximates
the local cooling rate by evaluating the flux that would escape from a pseudo-cloud
of local conditions, using the optical depth to the nearest boundary as a proxy for
the column depth through which radiation must diffuse.

The EOS is selected by ``ieos = 24``.  At initialisation, ``read_optab`` reads a
multi-column ASCII table (default filename ``eos_lom.dat``, based on Lombardi et al.
2015) containing :math:`(\rho, T, u, \mu, \kappa_P, \kappa_R)` on a rectangular
grid in density and internal energy.  The ``getopac_opdep`` routine interpolates this
table to return the Planck-mean opacity :math:`\kappa_P`, Rosseland-mean opacity
:math:`\kappa_R`, temperature :math:`T`, and mean molecular weight :math:`\mu` at
any :math:`(\rho, u)` point.  The master dispatcher in :doc:`eos` then uses these
to compute the ideal-gas pressure and sound speed:

.. math::

   P = \frac{k_B}{\mu\,m_H}\,\rho\,T, \qquad
   c_s = \sqrt{\gamma\,P/\rho}

where :math:`\gamma = 1 + P/(\rho\,u)` is computed self-consistently from the
table.

In addition to the EOS function, the module allocates and manages per-particle
arrays used by the cooling integrator: thermal timescale ``ttherm_store``,
equilibrium energy ``ueqi_store``, optical depth ``tau_store``, and the
flux-limited diffusion (FLD) arrays (``duFLD``, ``lambda_FLD``, ``urad_FLD``)
used by the optional Forgan et al. (2009) hybrid cooling method.

Physical & Mathematical Description
-------------------------------------

**Table structure.**  The table ``eos_lom.dat`` is an ASCII file with :math:`N_\rho
\times N_u` rows, each containing six columns:

.. math::

   (\rho,\ T,\ u,\ \mu,\ \kappa_P,\ \kappa_R)

in CGS units (density in g cm\ :sup:`-3`, energy in erg g\ :sup:`-1`, opacity in
cm\ :sup:`2` g\ :sup:`-1`).  The table is read into the three-dimensional array
``optable(nx, ny, 6)``.

**Interpolation.**  Given :math:`(\rho_i, u_i)`, the module performs a binary
search along each axis to locate the enclosing cell, then bilinear interpolation:

.. math::

   f(\rho_i, u_i) =
   f_{00} + (f_{10}-f_{00})\,\frac{\rho_i - \rho_j}{\rho_{j+1}-\rho_j}
          + (f_{01}-f_{00})\,\frac{u_i - u_k}{u_{k+1}-u_k}
          + \cdots

(standard bilinear form).  Out-of-range inputs trigger a warning but are not
fatal; the boundary value is returned.

**Equilibrium energy.**  ``getintenerg_opdep`` inverts the :math:`T \to u` relation
by interpolating the :math:`u(T, \rho)` slice of the table, returning the specific
internal energy :math:`u_{\rm eq}` that corresponds to a given equilibrium
temperature :math:`T_{\rm eq}`.

Derivations
-----------

The effective adiabatic index is derived at each SPH particle location from

.. math::

   \gamma = 1 + \frac{P}{\rho\,u} = 1 + \frac{(k_B/\mu m_H)\,T}{u}

using the table-interpolated values of :math:`T` and :math:`\mu`.  No analytic
differentiation of the table is performed; the sound speed is then
:math:`c_s = \sqrt{\gamma P/\rho}`.

References
----------

The following works are referenced in this module but not yet present in ``phantom.bib``:

- Stamatellos, D., Whitworth, A. P., Bisbas, T. & Goodwin, S. 2007, A&A, 475, 37 — pseudo-cloud radiative cooling approximation
- Young, A. K. et al. 2024 — updated tabulated cooling method for Phantom (icooling=9)
- Lombardi, J. C. et al. 2015, MNRAS, 447, 25 — opacity/EoS table (eos_lom.dat source)
- Forgan, D., Rice, K., Stamatellos, D. & Whitworth, A. 2009, MNRAS, 394, 882 — FLD hybrid cooling method

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/eos_stamatellos.f90
===============

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

.. f:autosrcfile:: ../../../src/main/eos_stamatellos.f90
