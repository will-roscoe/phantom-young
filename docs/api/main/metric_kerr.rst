.. phantom-doc: hand-written

Kerr Metric (Boyer-Lindquist Coordinates)
==========================================

Overview
--------

The Kerr metric module provides the exact vacuum solution to the Einstein field equations
for a rotating black hole characterised by mass :math:`M` and specific angular momentum
:math:`a` (spin parameter, :math:`|a| \leq M` in geometrised units). It implements
Phantom's ``metric`` module interface with ``imetric = 3`` and ``metric_type = 'Kerr'`,
following the Boyer-Lindquist coordinate convention described in Liptai & Price (2019),
MNRAS 485, 819 — not yet in phantom.bib.

Both Cartesian-like and spherical forms are provided. The Cartesian-like form, which is
used in production runs, is obtained by an algebraic transformation from Boyer-Lindquist
spherical coordinates. Analytic first derivatives of the Cartesian metric are implemented
in ``metric_cartesian_derivatives`` using symbolic expressions for all non-zero components.
These derivatives are exact and avoid the :math:`\mathcal{O}(10^{-8})` truncation error of
the finite-difference fallback used in the Kerr-Schild module.

The Boyer-Lindquist form is convenient for analytic calculations of orbital properties,
including the ISCO radius and the frame-dragging angular velocity. The coordinate
singularity at the horizon (:math:`\Delta = 0`) is a well-known limitation of
Boyer-Lindquist coordinates; for simulations that require horizon-penetrating capability,
the Kerr-Schild module should be used instead.

Runtime parameters are ``mass1`` and ``a`` (default ``a = 0.9``). The spin parameter is
constrained to :math:`|a| \leq 1`.

Physical & Mathematical Description
-------------------------------------

The Kerr metric in Boyer-Lindquist coordinates :math:`(t, r, \theta, \phi)` is:

.. math::

   \mathrm{d}s^2 = -\!\left(1-\frac{r_s r}{\Sigma}\right)\mathrm{d}t^2
                   - \frac{2 a r_s r \sin^2\!\theta}{\Sigma}\,\mathrm{d}t\,\mathrm{d}\phi
                   + \frac{\Sigma}{\Delta}\mathrm{d}r^2
                   + \Sigma\,\mathrm{d}\theta^2
                   + \frac{A\sin^2\!\theta}{\Sigma}\,\mathrm{d}\phi^2

where :math:`r_s = 2M`, the auxiliary functions are:

.. math::

   \Sigma = r^2 + a^2\cos^2\!\theta, \qquad
   \Delta = r^2 - r_s r + a^2, \qquad
   A = (r^2+a^2)^2 - a^2\Delta\sin^2\!\theta

The key metric components are:

.. math::

   g_{tt} = -1 + \frac{r_s r}{\Sigma}, \qquad
   g_{t\phi} = -\frac{a r_s r \sin^2\!\theta}{\Sigma}, \qquad
   g_{rr} = \frac{\Sigma}{\Delta}, \qquad
   g_{\theta\theta} = \Sigma, \qquad
   g_{\phi\phi} = \frac{A\sin^2\!\theta}{\Sigma}

The angular velocity of a zero-angular-momentum observer (ZAMO frame) is:

.. math::

   \omega = -\frac{g_{t\phi}}{g_{\phi\phi}}
          = \frac{a r_s r}{\Sigma(r^2+a^2) + a^2 r_s r \sin^2\!\theta}

The Cartesian-like form uses the Boyer-Lindquist radial coordinate defined implicitly by:

.. math::

   r^2 = \frac{1}{2}\!\left[(x^2+y^2+z^2-a^2) +
         \sqrt{(x^2+y^2+z^2-a^2)^2 + 4a^2 z^2}\right]

The ISCO radius for a prograde equatorial orbit is:

.. math::

   r_{\rm ISCO} = M\!\left[3 + Z_2 \mp \sqrt{(3-Z_1)(3+Z_1+2Z_2)}\right]

where :math:`Z_1` and :math:`Z_2` are functions of :math:`a/M` (upper sign: prograde).
For :math:`a = 0` this reduces to :math:`r_{\rm ISCO} = 6M`; for maximally spinning
:math:`a = M`, :math:`r_{\rm ISCO} = M`.

References
----------

Kerr (1963), Phys. Rev. Lett. 11, 237 — not yet in phantom.bib.
Liptai & Price (2019), MNRAS 485, 819 — not yet in phantom.bib.
Tejeda, Gafton & Rosswog (2017), MNRAS 468, 4483 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/metric_kerr.f90`.
