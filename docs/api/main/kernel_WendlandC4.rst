.. phantom-doc: hand-written

kernel_WendlandC4
=================

Overview
--------

The ``kernel`` module in ``kernel_WendlandC4.f90`` implements the Wendland
C\ :sup:`4` radial basis function kernel for three dimensions. It is identified
by ``kernelname = 'Wendland 2/3D C^4'``, with compact support radius
``radkern = 2.0`` and 3D normalisation constant
``cnormk = 495/(256*pi)``. The default smoothing-length factor
``hfact_default = 1.5`` is larger than for the C\ :sup:`2` variant, reflecting
the fact that a higher-order Wendland kernel requires more neighbours to achieve
optimal accuracy.

The Wendland C\ :sup:`4` kernel (Wendland 1995) is four times continuously
differentiable, providing higher interpolation accuracy than the C\ :sup:`2`
variant at the cost of a slightly more expensive kernel evaluation. Like all
Wendland kernels it is strictly positive-definite in three dimensions, so it is
immune to the pairing instability :cite:`price12`. The C\ :sup:`4` kernel is a
good choice for problems that require both high smoothness and freedom from
pairing artefacts, such as galaxy-formation simulations with large neighbour
counts.

Like all Phantom kernel files, ``kernel_WendlandC4.f90`` exports a module
named ``kernel`` and can be substituted at compile time.

Physical & Mathematical Description
------------------------------------

The Wendland C\ :sup:`4` kernel in three dimensions is (Wendland 1995;
:cite:`price12`)

.. math::

   W(q) = \frac{495}{256\pi h^3}
   \begin{cases}
     \left(1 - \frac{q}{2}\right)^6
       \!\left(\frac{35q^2}{12} + 3q + 1\right), & 0 \le q < 2, \\[4pt]
     0,                                            & q \ge 2.
   \end{cases}

where :math:`q = r/h`. The kernel is again a single polynomial on
:math:`[0, 2)`, with C\ :sup:`4` continuity at :math:`q = 2`. The
normalisation :math:`\sigma = 495/(256\pi)` ensures
:math:`\int W\,\mathrm{d}V = 1` in three dimensions :cite:`price12`.

The kernel gradient is obtained analytically from the single polynomial,
giving a smooth, branch-free expression. The smoothing length and grad-h
correction :math:`\Omega_i` follow the same Newton-Raphson formalism as for
the other kernels, with :math:`h_i = h_\mathrm{fact}(m_i/\rho_i)^{1/3}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/main/kernel_WendlandC4.f90`` for the complete source.
