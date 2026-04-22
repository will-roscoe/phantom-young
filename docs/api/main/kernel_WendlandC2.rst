.. phantom-doc: hand-written

kernel_WendlandC2
=================

Overview
--------

The ``kernel`` module in ``kernel_WendlandC2.f90`` implements the Wendland
C\ :sup:`2` radial basis function kernel for three dimensions. It is identified
by ``kernelname = 'Wendland 2/3D C^2'``, with compact support radius
``radkern = 2.0`` and 3D normalisation constant ``cnormk = 1.3125/pi``
(i.e. :math:`21/(16\pi)`). The default smoothing-length factor
``hfact_default = 1.3`` yields a neighbour count similar to the cubic spline
while exploiting the Wendland kernel's superior spectral properties.

Wendland kernels, introduced by Wendland (1995), are compactly supported
radial basis functions that are strictly positive-definite in the relevant
spatial dimension. This positive-definiteness eliminates the SPH pairing
instability that can affect B-spline kernels at high neighbour counts, making
Wendland kernels preferable for large-:math:`N` simulations where
:math:`h_\mathrm{fact}` must be increased :cite:`price12`. The C\ :sup:`2`
variant is twice continuously differentiable and the lowest-order member of
the Wendland family available in Phantom.

Like all Phantom kernel files, ``kernel_WendlandC2.f90`` exports a module
named ``kernel`` and can replace the default cubic kernel at compile time.

Physical & Mathematical Description
------------------------------------

The Wendland C\ :sup:`2` kernel in three dimensions is (Wendland 1995;
:cite:`price12`)

.. math::

   W(q) = \frac{21}{16\pi h^3}
   \begin{cases}
     \left(\frac{q}{2} - 1\right)^4 (2q + 1), & 0 \le q < 2, \\[4pt]
     0,                                         & q \ge 2,
   \end{cases}

where :math:`q = r/h`. The kernel is a single polynomial on :math:`[0, 2)`,
which makes it branch-free and especially cache-friendly. Its first derivative
is continuous at :math:`q = 2` (the support boundary), ensuring that the SPH
kernel gradient is well-defined throughout the support.

The normalisation :math:`\sigma = 21/(16\pi)` satisfies
:math:`\int W\,\mathrm{d}V = 1` in three dimensions :cite:`price12`. The
smoothing length and grad-h correction :math:`\Omega_i` are computed using the
same Newton-Raphson iteration as for the B-spline kernels, with
:math:`h_i = h_\mathrm{fact}(m_i/\rho_i)^{1/3}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/main/kernel_WendlandC2.f90`` for the complete source.
