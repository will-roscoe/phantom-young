.. phantom-doc: hand-written

extern_geopot — Geopotential Model with Oblateness Correction
==============================================================

Overview
--------

The ``extern_geopot`` module extends the central point-mass gravity with higher-order
geopotential corrections that account for the departure of an extended body from a
perfect sphere.  Currently the :math:`J_2` zonal harmonic is implemented, capturing
the leading-order effect of equatorial oblateness; the framework is structured to
admit higher-order terms (:math:`J_3`, :math:`J_4`, …) with minimal code changes.

This module is activated when ``iexternalforce = iext_geopot``.  The
:math:`1/r^2` point-mass term is evaluated in the master dispatcher
(:doc:`externalforces`) and the :math:`J_2` correction is then added by calling
``get_geopot_force``.  The spin axis of the central body is specified by the tilt
(obliquity) angle ``tilt_angle`` in degrees, which is stored as a unit spin vector
``spinvec`` for fast evaluation at runtime.

An optional interface allows the reaction torque on the central body itself to be
computed simultaneously, enabling coupled spin–orbit precession studies.

Physical & Mathematical Description
-------------------------------------

The geopotential at distance :math:`r` from an oblate body of mass :math:`M`,
equatorial radius :math:`R_p`, and spin unit vector :math:`\hat{s}` is

.. math::

   \Phi = -\frac{GM}{r}
           \left[1 - J_2\left(\frac{R_p}{r}\right)^2
                 P_2(\hat{r}\cdot\hat{s})\right],

where :math:`P_2(x) = \tfrac{1}{2}(3x^2 - 1)` is the second Legendre polynomial and
:math:`\hat{r} = \mathbf{r}/r`.  The corresponding acceleration on a test particle,
following equation (1) of Hong et al. (2021), is

.. math::

   \mathbf{f}_{J_2}
   = \frac{3}{2}J_2\left(\frac{R_p}{r}\right)^2 \frac{GM}{r^3}
     \left[(5(\hat{r}\cdot\hat{s})^2 - 1)\,\mathbf{r}
            - 2(\hat{r}\cdot\hat{s})\,r\,\hat{s}\right].

In code notation, with ``mdr3`` :math:`= GM/r^3` and ``dr`` :math:`= 1/r`:

.. math::

   \texttt{term} &= \tfrac{3}{2}J_2(R_p\,\texttt{dr})^2\,\texttt{mdr3}, \\
   \texttt{term1} &= \texttt{term}(5(\hat{r}\cdot\hat{s})^2 - 1), \\
   \texttt{term2} &= \texttt{term}(-2(\hat{r}\cdot\hat{s})/\texttt{dr}),

giving :math:`\mathbf{f}_{J_2} = \texttt{term1}\,\mathbf{r} + \texttt{term2}\,\hat{s}`.

The potential correction added to :math:`\Phi` is

.. math::

   \delta\Phi = \tfrac{1}{2}J_2 R_p^2\,\texttt{mdr3}
                \bigl(3(\hat{r}\cdot\hat{s})^2 - 1\bigr).

References
----------

The :math:`J_2` acceleration formula is taken from:

- Hong, Y.-C. et al. 2021, ApJ, 920, 151 — not yet in phantom.bib
- https://en.wikipedia.org/wiki/Geopotential_model — not yet in phantom.bib

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/extern_geopot.f90
