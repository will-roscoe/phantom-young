.. phantom-doc: hand-written

moddump\_sphNG2phantom\_disc
=============================

Overview
--------

``moddump_sphNG2phantom_disc`` ports an sphNG disc dump that includes sink particles into the Phantom format. It was written by Alison Young. The routine handles unit conversion, boundary setup, and centre-of-mass reset, while preserving the sink-particle table (``xyzmh_ptmass``, ``vxyz_ptmass``) and the disc particle distribution.

The moddump translates sphNG's internal unit system (using AU and solar masses as reference quantities) to Phantom code units, recomputes the adiabatic index :math:`\gamma`, and ensures the boundary box encloses the disc. Particles outside a user-specified sphere can optionally be deleted to reduce the problem size.

Dynamic time-step control parameters ``dtmax_max`` and ``dtmax_min`` are set to values appropriate for the disc orbital time-scale, and the restart time and step are preserved from the original sphNG dump header.

Physical & Mathematical Description
------------------------------------

Unit conversion applies :math:`\tilde{x} = x / d_0`, :math:`\tilde{v} = v / v_0`, and :math:`\tilde{u} = u / e_0` where :math:`d_0`, :math:`v_0`, and :math:`e_0` are the sphNG distance, velocity, and specific energy units. The adiabatic sound speed in the disc satisfies :math:`c_s = \sqrt{\gamma P / \rho}`, and the orbital period at radius :math:`r` is :math:`T_\mathrm{orb} = 2\pi r^{3/2} / \sqrt{G M_\star}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_sphNG2phantom_disc.f90`` for the complete source.
