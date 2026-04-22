.. phantom-doc: hand-written

plot_kernel
===========

Overview
--------

``plot_kernel`` is a standalone program that outputs the values of the SPH smoothing kernel function and its associated quantities for plotting with GIZA or another plotting library. It evaluates the kernel function :math:`W(q, h)` and the softened gravitational potential :math:`\phi(q)` over a range of :math:`q = r/h` values.

The program computes ``wfunc(q) = wkern(q*q, q)`` (the kernel function) and a simple :math:`1/r` potential ``potk(q) = 1/q`` for comparison, then calls the GIZA plotting library to produce output figures. It is primarily used to verify that the compiled kernel has the expected shape and normalisation.

The kernel function and its gradient are central to SPH interpolation: the kernel determines the effective resolution, force softening, and tensor viscosity coefficients in Phantom.

Physical & Mathematical Description
------------------------------------

The SPH kernel function :math:`W(r, h) = \sigma_d h^{-d} w(q)` with :math:`q = r/h` satisfies the normalisation :math:`\int W(r, h) \, dV = 1`. For the M4 cubic spline (Phantom default): :math:`w(q) = (1 - 3q^2/2 + 3q^3/4)` for :math:`0 \leq q \leq 1`, :math:`w(q) = (2-q)^3/4` for :math:`1 < q \leq 2`, and :math:`w(q) = 0` for :math:`q > 2`. The 3D normalisation is :math:`\sigma_3 = 1/\pi`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/plot_kernel.f90
