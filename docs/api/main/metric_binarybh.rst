.. phantom-doc: hand-written

Binary Black Hole Metric (Superposed Kerr-Schild)
==================================================

Overview
--------

The binary black hole metric module provides an approximate spacetime for a system of two
spinning black holes using the superposed Kerr-Schild (SKS) formalism of Combi & Ressler
(2024), arXiv:2403.13308 — not yet in phantom.bib. It implements Phantom's ``metric``
module interface with ``imetric = 5`` and ``metric_type = 'binarybh'``.

The metric is constructed as the sum of two individual Kerr-Schild perturbations, each
boosted to the frame of its black hole via a Lorentz transformation. The trajectories of
the two black holes :math:`(x_1(t), x_2(t), v_1(t), v_2(t))` are read from a user-supplied
ASCII trajectory file (default: ``cbwaves.txt``) and linearly interpolated in time. This
decouples the orbital dynamics (which may be supplied from a numerical relativity binary
inspiral, a post-Newtonian approximation, or a fixed circular orbit) from the fluid
evolution.

The metric computation in ``get_metric_cartesian`` is translated from the C implementation
of the original ``SuperposedBBH.c`` routine (Combi & Ressler 2024, Zenodo record 10841021).
For each spatial point and time, the algorithm Lorentz-boosts the field point to each
black hole's instantaneous rest frame, evaluates the single Kerr-Schild perturbation of
that BH, and Lorentz-boosts the result back to the coordinate frame. The flat metric
:math:`\eta_{\mu\nu}` is then added.

Because analytic Cartesian derivatives are prohibitively complex, metric derivatives are
computed numerically with centred finite differences (step :math:`\epsilon = 10^{-10}`).
An excision mask regularises the metric near each horizon. Runtime parameters include the
masses (``mass1``, ``mass2``), individual spin vectors (``a1x``, ``a1y``, ``a1z``,
``a2x``, ``a2y``, ``a2z``), and the trajectory file name.

Physical & Mathematical Description
-------------------------------------

The superposed covariant metric is:

.. math::

   g_{\mu\nu} = \eta_{\mu\nu}
              + \Lambda^{\alpha}{}_{\mu}(v_1)\, \tilde{g}^{(1)}_{\alpha\beta}\, \Lambda^{\beta}{}_{\nu}(v_1)
              + \Lambda^{\alpha}{}_{\mu}(v_2)\, \tilde{g}^{(2)}_{\alpha\beta}\, \Lambda^{\beta}{}_{\nu}(v_2)

where :math:`\tilde{g}^{(A)}_{\mu\nu}` is the Kerr-Schild perturbation of black hole
:math:`A` evaluated in its rest frame, and :math:`\Lambda^{\mu}{}_{\nu}(v_A)` is the
Lorentz boost with velocity :math:`v_A`. For a single Kerr-Schild source the perturbation
is:

.. math::

   \tilde{g}^{(A)}_{\mu\nu} = H_A\, l^{(A)}_\mu l^{(A)}_\nu

where :math:`l^{(A)}_\mu` is the ingoing null vector of that Kerr spacetime. The
perturbation amplitude as computed by the code (translated from Combi & Ressler 2024)
is:

.. math::

   H_A = \frac{M_A}{\sqrt{2}} \cdot \frac{r_A^{3/2}}{(\boldsymbol{a}_A \cdot \boldsymbol{x}_A)^2 + r_A^4/4}

where :math:`r_A` is the Boyer-Lindquist radial coordinate in the rest frame of black
hole :math:`A`, and :math:`\boldsymbol{a}_A \cdot \boldsymbol{x}_A` is the dot product
of the spin vector with the field-point displacement in that frame.

.. note::
   This normalisation differs from the standard single-BH Kerr-Schild amplitude
   :math:`H = Mr/\Sigma` (where :math:`\Sigma = r^2 + a^2\cos^2\theta`). The code
   follows the specific CAS-generated expressions from the original ``SuperposedBBH.c``
   (Combi & Ressler 2024, Zenodo 10841021); the two forms agree in the limit
   :math:`a \to 0`. The field coordinates
in each BH rest frame :math:`(x^0_A, x^i_A)` are obtained by the Lorentz transformation
applied to the coordinate displacement :math:`(x - x_A)`.

Near each horizon the BH field coordinate is regularised: if the Boyer-Lindquist
coordinate :math:`r_A < |a_A| + \epsilon_{\rm cutoff}` the :math:`z`-component is clamped
to prevent the metric from becoming singular.

The invariant :math:`\sqrt{-g}` is obtained by calling the analytic 4x4 matrix
determinant routine ``inv4x4`` on the covariant metric.

References
----------

Combi & Ressler (2024), arXiv:2403.13308 — not yet in phantom.bib.
Original C code: https://zenodo.org/records/10841021 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/metric_binarybh.f90`.
