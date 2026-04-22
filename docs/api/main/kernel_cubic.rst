.. phantom-doc: hand-written

kernel_cubic
============

Overview
--------

The ``kernel`` module in ``kernel_cubic.f90`` implements the M\ :sub:`4`
cubic B-spline, the default SPH smoothing kernel in Phantom :cite:`price12`.
The kernel is characterised by ``kernelname = 'M_4 cubic'``, a compact support
radius of ``radkern = 2.0`` (in units of the smoothing length :math:`h`), and a
3D normalisation constant ``cnormk = 1/pi``. The default smoothing-length
factor ``hfact_default = 1.2`` yields approximately 58 neighbours per particle
in three dimensions, a value that has been found to give a good balance between
accuracy and computational cost for most astrophysical applications.

Because the file is named ``kernel_cubic.f90`` but the Fortran module it
defines is simply called ``kernel``, any other kernel file (quartic, quintic,
Wendland) can replace this one at compile time without changing any calling
code. The build system selects the active kernel via a compile-time flag, and
all kernel-dependent parameters (``radkern``, ``cnormk``, ``hfact_default``)
are exported through the common ``kernel`` module interface.

The cubic spline is twice continuously differentiable (C\ :sup:`2`) and has a
cusp-free first derivative, making it numerically well-behaved in SPH force
evaluations. Its piecewise polynomial form is inexpensive to evaluate and
branch-predictable on modern hardware, which is why it remains the default
choice despite the availability of smoother alternatives.

Physical & Mathematical Description
------------------------------------

An SPH kernel :math:`W(r, h)` must satisfy the normalisation condition
:math:`\int W\,\mathrm{d}V = 1` and must approach a Dirac delta distribution
as :math:`h \to 0`. The M\ :sub:`4` cubic spline kernel in three dimensions is

.. math::

   W(q) = \frac{1}{\pi h^3}
   \begin{cases}
     \tfrac{3}{4}q^3 - \tfrac{3}{2}q^2 + 1, & 0 \le q < 1, \\[4pt]
     -\tfrac{1}{4}(q - 2)^3,                  & 1 \le q < 2, \\[4pt]
     0,                                         & q \ge 2,
   \end{cases}

where :math:`q = r/h` is the dimensionless particle separation :cite:`price12`.
The kernel gradient required in SPH summations is

.. math::

   \nabla_i W_{ij}(h) = \frac{1}{h}\frac{\mathrm{d}W}{\mathrm{d}q}\,\frac{\hat{\mathbf{r}}_{ij}}{h},

with

.. math::

   \frac{\mathrm{d}W}{\mathrm{d}q} = \frac{1}{\pi}
   \begin{cases}
     q(2.25q - 3), & 0 \le q < 1, \\[4pt]
     -0.75(q-2)^2, & 1 \le q < 2, \\[4pt]
     0,             & q \ge 2.
   \end{cases}

The smoothing length :math:`h` adapts so that each particle encloses a fixed
mass of neighbours:

.. math::

   h_i = h_\mathrm{fact} \left(\frac{m_i}{\rho_i}\right)^{1/3}.

Variable smoothing lengths introduce a grad-h correction term

.. math::

   \Omega_i = 1 - \frac{\partial h_i}{\partial \rho_i}
              \sum_j m_j \frac{\partial W(r_{ij}, h_i)}{\partial h_i},

which appears in both the momentum and energy equations to ensure conservation
:cite:`price12`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/kernel_cubic.f90
