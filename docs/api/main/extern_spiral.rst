.. phantom-doc: hand-written

extern_spiral — Composite Galactic Potential (Disc, Bulge, Halo, Arms, Bar)
=============================================================================

Overview
--------

The ``extern_spiral`` module provides a comprehensive library of analytic galactic
gravitational potentials for simulations of gas dynamics in disc galaxies.  It was
developed by Clare Dobbs and Alex Pettitt for Phantom and encompasses four distinct
structural components — disc, bulge, dark-matter halo, and spiral arms — each with
multiple analytic prescriptions selectable via integer flags, plus a freely rotating
or static galactic bar.  The module is activated when
``iexternalforce = iext_spiral``.

The composite potential is assembled by calling sub-routines for each component in
turn, accumulating their contributions to the acceleration and potential.  Each
component can be switched off independently by setting its flag to zero.  The
available choices are:

- **Disc** (``idisk``): logarithmic Binney–Tremaine disc (1), Miyamoto–Nagai
  flattened disc (2), or Khoperskov–Freeman disc with built-in bar and arm
  perturbations (3).
- **Bulge** (``ibulg``): Plummer sphere (1), Hernquist profile (2), or Hubble
  luminosity profile (3).
- **Dark-matter halo** (``ihalo``): Caldwell–Ostriker logarithmic–arctangent halo
  (1), flat logarithmic halo (2), Allen–Martos power-law halo (3),
  Khoperskov–Begeman isothermal halo (4), or NFW profile (5).
- **Spiral arms** (``iarms``): Cox–Gomez (2002) trailing-wave approximation (1),
  or Pichardo et al. (2003) superposition of Schmidt spheroids with linear (2,3) or
  inverse (4) density laws.
- **Bar** (``ibar``): Long–Murali biaxial (1) or triaxial (2) bars, Wang orthogonal
  basis bar (3), Dehnen cosine bar (4), Vogt–Letelier S-shape bar (5), or Wada
  sinusoidal bar (6).

An additional option (``read_from_file = .true.``) allows the potential to be read
from a pre-tabulated three-dimensional grid file.

Runtime parameters are specified in physical units (km s :sup:`-1` kpc :sup:`-1` for
pattern speeds, kpc for bar axes, degrees for pitch angle) and converted to code
units at initialisation.

Physical & Mathematical Description
-------------------------------------

The force at position :math:`(x,y,z)` is the gradient of the sum of component
potentials:

.. math::

   \mathbf{f} = -\nabla\Phi_\mathrm{total},
   \qquad
   \Phi_\mathrm{total}
   = \Phi_\mathrm{disc} + \Phi_\mathrm{bulge} + \Phi_\mathrm{halo}
     + \Phi_\mathrm{arms} + \Phi_\mathrm{bar}.

Representative examples of the implemented forms are given below.

**Logarithmic disc** (Binney & Tremaine 1987)

.. math::

   \Phi_\mathrm{disc} = \frac{v_c^2}{2}\ln\!\left(R^2 + \frac{z^2}{q_z^2} + R_c^2\right),

where :math:`R^2 = x^2+y^2`, :math:`v_c` is the circular velocity, :math:`q_z` is
the flattening parameter, and :math:`R_c` is the core radius.

**Miyamoto–Nagai disc** (Miyamoto & Nagai 1975)

.. math::

   \Phi_\mathrm{disc}
   = -\frac{GM_d}{\sqrt{R^2 + (a_d + \sqrt{z^2+b_d^2})^2}},

with disc mass :math:`M_d`, scale length :math:`a_d`, and scale height :math:`b_d`.

**Cox–Gomez spiral arms** (Cox & Gomez 2002)

The spiral potential is a Fourier sum of arm harmonics:

.. math::

   \Phi_\mathrm{arms}(R,\phi,z)
   = -4\pi G H\,\rho_0
     \sum_{n=1}^{N_\mathrm{harm}} \frac{\cos(n\gamma)}{K_n D_n}
     \mathrm{sech}^2\!\left(\frac{K_n z}{\beta_n}\right),

where :math:`\gamma = N_\mathrm{arm}(\ln R/R_0 - \phi)/\tan\alpha_p` is the phase
along a logarithmic spiral with pitch angle :math:`\alpha_p` and
:math:`K_n = nN_\mathrm{arm}/(R\sin\alpha_p)`.

References
----------

The following works are cited in the source file:

- Cox, D. P. & Gomez, G. C. 2002, ApJS, 142, 261 — not yet in phantom.bib
- Pichardo, B. et al. 2003, ApJ, 582, 230 — not yet in phantom.bib
- Freeman, K. C. 1970, ApJ, 160, 811 — not yet in phantom.bib
- Miyamoto, M. & Nagai, R. 1975, PASJ, 27, 533 — not yet in phantom.bib
- Dobbs, C. L., Bonnell, I. A. & Pringle, J. E. 2006, MNRAS, 371, 1663 — not yet in phantom.bib
- Caldwell, J. A. R. & Ostriker, J. P. 1981, ApJ, 251, 61 — not yet in phantom.bib
- Allen, C. & Martos, M. A. 1986, Rev. Mex. Astron. Astrofis., 13, 137 — not yet in phantom.bib
- Long, K. & Murali, C. 1992, ApJ, 397, 44 — not yet in phantom.bib
- Vogt, D. & Letelier, P. S. 2011, MNRAS, 411, 2371 — not yet in phantom.bib
- Binney, J. & Tremaine, S. 1987, Galactic Dynamics, Princeton University Press — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_spiral.f90
