.. phantom-doc: hand-written

kernel_WendlandC6
=================

Overview
--------

The ``kernel`` module in ``kernel_WendlandC6.f90`` implements the Wendland
C\ :sup:`6` radial basis function kernel for three dimensions. It is identified
by ``kernelname = 'Wendland 2/3D C^6'``, with compact support radius
``radkern = 2.0`` and 3D normalisation constant
``cnormk = 1365/(512*pi)``. The C\ :sup:`6` kernel is the smoothest Wendland
kernel available in Phantom, being six times continuously differentiable, and is
recommended for high-resolution simulations where minimising interpolation error
is the primary concern.

Like all Wendland kernels (Wendland 1995), the C\ :sup:`6` variant is strictly
positive-definite in three dimensions and therefore immune to the pairing
instability that can afflict high-order B-spline kernels :cite:`price12`. Its
single-polynomial form on :math:`[0, 2)` is branch-free, making kernel and
gradient evaluation efficient on modern SIMD hardware. The higher smoothness
comes at the cost of a broader effective kernel profile, so a larger
``hfact`` is needed to achieve accurate density estimates; users should choose
``hfact`` so that the neighbour count is at least 100 in three dimensions when
using this kernel.

Like all Phantom kernel files, ``kernel_WendlandC6.f90`` exports a module
named ``kernel`` and can replace the default cubic kernel at compile time via
the build-system kernel flag.

Physical & Mathematical Description
------------------------------------

The Wendland C\ :sup:`6` kernel in three dimensions is (Wendland 1995;
:cite:`price12`)

.. math::

   W(q) = \frac{1365}{512\pi h^3}
   \begin{cases}
     \left(\frac{q}{2} - 1\right)^8
       \!\left(4q^3 + \tfrac{25}{4}q^2 + 4q + 1\right), & 0 \le q < 2, \\[4pt]
     0,                                                    & q \ge 2,
   \end{cases}

where :math:`q = r/h`. The normalisation :math:`\sigma = 1365/(512\pi)`
ensures :math:`\int W\,\mathrm{d}V = 1` in three dimensions :cite:`price12`.
The kernel and its first six derivatives are all continuous at :math:`q = 2`,
providing the smoothest possible kernel gradient within the Wendland family.

The kernel gradient follows by analytic differentiation of the single
polynomial and is again branch-free. The smoothing length and grad-h
correction :math:`\Omega_i` use the same Newton-Raphson iteration as the
other kernels, with :math:`h_i = h_\mathrm{fact}(m_i/\rho_i)^{1/3}`
:cite:`price12`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/main/kernel_WendlandC6.f90`` for the complete source.
