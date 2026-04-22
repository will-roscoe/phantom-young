.. phantom-doc: hand-written

kernel_quintic
==============

Overview
--------

The ``kernel`` module in ``kernel_quintic.f90`` implements the M\ :sub:`6`
quintic B-spline smoothing kernel. It is identified by
``kernelname = 'M_6 quintic'``, with a compact support radius
``radkern = 3.0`` (in units of :math:`h`) and a 3D normalisation constant
``cnormk = 1/(120*pi)``. The default smoothing-length factor
``hfact_default = 1.0`` reflects the fact that the kernel's larger support
radius already provides an adequate neighbour count without the larger
:math:`h_\mathrm{fact}` values needed for the cubic.

The quintic spline is four times continuously differentiable (C\ :sup:`4`),
making it the smoothest member of the B-spline family available in Phantom.
Its compact support extends to :math:`3h`, larger than the cubic
(:math:`2h`) or quartic (:math:`2.5h`), so the number of neighbours and
the cost per force evaluation are both higher. The M\ :sub:`6` quintic is
therefore recommended for problems where low interpolation error is paramount,
such as turbulence studies or high-order convergence tests, rather than for
large-:math:`N` production runs where computational cost dominates
:cite:`price12`.

Like all Phantom kernel files, ``kernel_quintic.f90`` exports a module named
``kernel`` and can replace the default cubic kernel at compile time via the
build-system kernel flag.

Physical & Mathematical Description
------------------------------------

The M\ :sub:`6` quintic B-spline kernel in three dimensions is (with
:math:`q = r/h`)

.. math::

   W(q) = \frac{1}{120\pi h^3}
   \begin{cases}
     -10q^5 + 30q^4 - 60q^2 + 66, & 0 \le q < 1, \\[4pt]
     -(q-3)^5 + 6(q-2)^5,          & 1 \le q < 2, \\[4pt]
     -(q-3)^5,                      & 2 \le q < 3, \\[4pt]
     0,                             & q \ge 3.
   \end{cases}

The normalisation :math:`\sigma = 1/(120\pi)` ensures
:math:`\int W\,\mathrm{d}V = 1` in three dimensions :cite:`price12`. The
three knot points at :math:`q = 1`, :math:`2`, and :math:`3` partition the
compact support, and C\ :sup:`4` continuity is maintained across all of them.

The kernel gradient is obtained by differentiating the piecewise polynomial
analytically in each region. The smoothing length and grad-h correction
:math:`\Omega_i` follow the same formalism as for the cubic kernel, with
:math:`h_i = h_\mathrm{fact}(m_i/\rho_i)^{1/3}` :cite:`price12`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/main/kernel_quintic.f90`` for the complete source.
