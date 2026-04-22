.. phantom-doc: hand-written

moddump\_sphNG2phantom
=======================

Overview
--------

``moddump_sphNG2phantom`` converts a generic sphNG dump file into the Phantom binary format. It was written by Daniel Price. The conversion sets ``hfact`` to the default value, applies the sphNG-to-Phantom unit velocity scaling, and resets the boundary box to enclose the full particle distribution.

The routine prints the sound speed in both code units and CGS, and initialises the polytropic constants ``polyk`` and ``polyk2`` for single- and two-fluid simulations respectively. It is the foundational format-conversion moddump on which the specialised disc and MHD variants are built.

This utility enables re-use of sphNG initial conditions or evolved snapshots within the Phantom simulation framework without the need to regenerate the particle distribution from scratch.

Physical & Mathematical Description
------------------------------------

The isothermal sound speed obeys :math:`c_s = \sqrt{K_{\rm poly}}` in code units (where ``polyk`` = :math:`K_{\rm poly}`), and in CGS the conversion is :math:`c_s^\mathrm{CGS} = c_s \times v_\mathrm{unit}`. Particle smoothing lengths satisfy the resolution constraint :math:`h = h_\mathrm{fac} (m/\rho)^{1/3}` with :math:`h_\mathrm{fac}` fixed to ``hfact_default``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_sphNG2phantom.f90`` for the complete source.
