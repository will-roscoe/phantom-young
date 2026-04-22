.. phantom-doc: hand-written

ptmass_heating — Accretion Heating from Sink Particles
=======================================================

Overview
--------

The ``ptmass_heating`` module computes the specific heating rate deposited into SPH
gas particles by luminous sink particles.  In Phantom, sink particles can carry a
nuclear or accretion luminosity :math:`L_{\rm nuc}` (stored in the
``xyzmh_ptmass(iLum, j)`` array entry) alongside an enclosed mass
``xyzmh_ptmass(imassenc, j)`` that sets the local energy density.  The module
exposes two routines: ``energ_sinkheat``, which accumulates the total heating rate
per unit energy on a given gas particle from all contributing sinks, and
``heating_kernel``, which supplies the radial weighting function.

The per-sink luminosity :math:`L_j` is stored in the sink property array as
:math:`\texttt{iLum}`.  The module also provides the public variable
:math:`\texttt{Lnuc}` (nuclear luminosity contribution), which may be summed into
:math:`L_j` by other modules (e.g.\ :mod:`ptmass`).

The heating is spatially confined to within the SPH kernel support radius of each
sink (i.e., :math:`q^2 = r^2 / h_{\rm soft}^2 < r_{\rm kern}^2`).  Only sinks
for which the ``sink_has_heating`` predicate is true contribute; this guards against
division by zero if the enclosed mass is unset.  The integer flag ``isink_heating``
selects between a spatially uniform distribution (mode 0, the default) and an
SPH-kernel-weighted distribution (mode 1), allowing the deposited energy to track
the kernel profile of the sink rather than spreading it uniformly.

Physical & Mathematical Description
-------------------------------------

**Heating rate.**  For a gas particle at position :math:`\mathbf{x}_i`, the
specific heating rate contributed by sink :math:`j` is

.. math::

   \left.\frac{du}{dt}\right|_{j \to i}
   = \frac{L_j}{M_{\rm enc,j}}\, W(q^2,\, {\rm isink\_heating})

where :math:`L_j = \mathtt{xyzmh\_ptmass(iLum,\,j)}` is the sink luminosity,
:math:`M_{\rm enc,j} = \mathtt{xyzmh\_ptmass(imassenc,\,j)}` is the enclosed mass,
and :math:`q^2 = |\mathbf{x}_i - \mathbf{x}_j|^2 / h_{\rm soft,j}^2` is the
dimensionless squared separation.  The sum runs over all sinks with
:math:`q^2 < r_{\rm kern}^2`.

**Heating kernel.**  The weight function is

.. math::

   W(q^2, k) =
   \begin{cases}
     c_{\rm norm}\, w(q^2, q) & k = 1 \quad (\text{kernel-weighted}) \\
     1 & \text{otherwise} \quad (\text{uniform})
   \end{cases}

where :math:`w(q^2, q)` is the SPH kernel evaluated at :math:`q = \sqrt{q^2}` and
:math:`c_{\rm norm}` is the kernel normalisation constant ``cnormk`` from the
``kernel`` module.

**Symbol table**

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Symbol
     - Definition
   * - :math:`L_j`
     - Sink luminosity ``xyzmh_ptmass(iLum, j)`` (code units of energy per time)
   * - :math:`M_{\rm enc,j}`
     - Enclosed mass ``xyzmh_ptmass(imassenc, j)``
   * - :math:`h_{\rm soft,j}`
     - Sink softening length ``xyzmh_ptmass(ihsoft, j)``
   * - :math:`q`
     - Dimensionless separation :math:`r / h_{\rm soft,j}`
   * - :math:`r_{\rm kern}`
     - Kernel compact-support radius (``radkern`` from the ``kernel`` module)
   * - :math:`c_{\rm norm}`
     - Kernel normalisation constant (``cnormk``)

References
----------

No entries from ``phantom.bib`` are directly cited by this module.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/ptmass_heating.f90
