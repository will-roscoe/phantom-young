kernels.py
==========

``scripts/kernels.py`` is Daniel Price's automatic SPH smoothing kernel
generation script.  It uses symbolic mathematics (via ``sympy``) to compute
kernel normalisation constants, gradient kernels, and force-softening kernels
in 1, 2, and 3 dimensions, then prints them in a form suitable for direct
inclusion in Fortran SPH codes.

Usage
-----

.. code-block:: bash

   python3 kernels.py

The script is self-contained and requires ``sympy``.  It prints kernel
functions and their normalisations to stdout.

What it computes
----------------

For each piecewise polynomial kernel:

1. **Normalisation constants** :math:`\sigma` in 1D, 2D, and 3D, derived by
   matching the integral of :math:`W(r, h)` to unity.
2. **Gradient kernel** :math:`dW/dq` where :math:`q = r/h`.
3. **Force-softening kernel** and its derivative, obtained from the density
   kernel by the method described in Price & Monaghan (2007).
4. **Kernel integrals** needed for the grad-h terms in the variable-smoothing-
   length SPH formulation.

The piecewise function matching ensures continuity across the support
boundaries and is verified symbolically before printing.

.. seealso::

   :doc:`../api/main/kernel_cubic` — the default (cubic spline) Fortran kernel module used at runtime.
