.. phantom-doc: hand-written

kernel_quartic
==============

Overview
--------

The ``kernel`` module in ``kernel_quartic.f90`` implements the M\ :sub:`5`
quartic B-spline smoothing kernel. It is identified by
``kernelname = 'M_5 quartic'``, with a compact support radius
``radkern = 2.5`` (in units of :math:`h`) and a 3D normalisation constant
``cnormk = 0.05/pi``. The default smoothing-length factor
``hfact_default = 1.1`` is slightly lower than the cubic default, reflecting
the quartic kernel's higher polynomial order and correspondingly larger
effective neighbour volume near the particle centre.

The quartic spline is three times continuously differentiable (C\ :sup:`3`),
one degree smoother than the M\ :sub:`4` cubic. This additional smoothness
reduces interpolation errors for quantities with rapidly varying second
derivatives, at the cost of a slightly larger compact support radius and
therefore a somewhat larger neighbour sum. The three piecewise regions cover
:math:`q \in [0, 0.5)`, :math:`[0.5, 1.5)`, and :math:`[1.5, 2.5)`. The
density of neighbours near the edge of the support sphere is lower than for
the cubic, which can help reduce tensile instability artefacts in some
configurations :cite:`price12`.

Like all Phantom kernel files, ``kernel_quartic.f90`` defines a Fortran module
named ``kernel``, so it can replace ``kernel_cubic.f90`` at compile time
without modifying any calling code. The choice of kernel is made via a
compile-time preprocessor flag.

Physical & Mathematical Description
------------------------------------

The M\ :sub:`5` quartic B-spline kernel in three dimensions is defined by the
three-region piecewise polynomial (with :math:`q = r/h`)

.. math::

   W(q) = \frac{0.05}{\pi h^3}
   \begin{cases}
     6q^4 - 15q^2 + 14.375,                   & 0 \le q < 0.5,    \\[4pt]
     (q - 2.5)^4 - 5(q - 1.5)^4,              & 0.5 \le q < 1.5,  \\[4pt]
     (q - 2.5)^4,                              & 1.5 \le q < 2.5,  \\[4pt]
     0,                                         & q \ge 2.5.
   \end{cases}

The normalisation :math:`\sigma = 0.05/\pi` ensures :math:`\int W\,\mathrm{d}V = 1`
in three dimensions :cite:`price12`. The C\ :sup:`3` continuity guarantees
that the kernel and its first three derivatives are continuous across the
knot points at :math:`q = 0.5`, :math:`1.5`, and :math:`2.5`.

The smoothing length satisfies :math:`h_i = h_\mathrm{fact}(m_i/\rho_i)^{1/3}`,
and the grad-h correction term :math:`\Omega_i` is computed from
:math:`\partial W / \partial h` evaluated with the quartic polynomial, using
the same formalism as for the cubic kernel :cite:`price12`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/main/kernel_quartic.f90`` for the complete source.
