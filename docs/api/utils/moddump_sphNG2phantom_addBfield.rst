.. phantom-doc: hand-written

moddump\_sphNG2phantom\_addBfield
==================================

Overview
--------

``moddump_sphNG2phantom_addBfield`` ports an sphNG dump that contains no magnetic-field data into a Phantom dump by adding a magnetic field initialisation. It was written by Daniel Price. The routine sets ``hfact`` to the default kernel ratio and flags the magnetic field as not yet set (``ihavesetupB = .false.``), triggering Phantom's standard field initialisation on the next run.

The conversion handles the differences between sphNG and Phantom binary formats: particle positions, velocities, smoothing lengths, and thermodynamic quantities are preserved while the MHD arrays are introduced fresh. This is intended for MHD restarts of non-magnetised sphNG simulations.

This moddump is a lightweight wrapper around the format-conversion logic in ``moddump_sphNG2phantom`` that additionally enables the MHD arrays, making it straightforward to explore the effect of seeding magnetic fields into a pre-existing hydrodynamic snapshot.

Physical & Mathematical Description
------------------------------------

The magnetic field is initialised to zero (:math:`\mathbf{B} = 0`) and subsequently set by the Phantom setup or IC routine on the first step. The divergence-cleaning scalar :math:`\psi` is likewise zeroed. Particle smoothing lengths satisfy :math:`h = h_\mathrm{fac} (m/\rho)^{1/3}` with :math:`h_\mathrm{fac}` set to ``hfact_default`` to match Phantom's default kernel support radius.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_sphNG2phantom_addBfield.f90`` for the complete source.
