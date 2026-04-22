.. phantom-doc: hand-written

moddump_radiotde
================

Overview
--------

``moddump_radiotde`` sets up a circumnuclear gas cloud around an outflowing TDE debris stream for radio TDE modelling. Written by Fitz Hu, it adds a spherical or power-law density profile cloud of particles around the existing TDE particles, with optional overlap removal between the cloud and the outflowing stream.

The cloud can have a broken power-law density profile with up to ``nbreak`` segments, or can read a custom profile from a file (``profile_filename``). The target cloud mass ``m_target`` or the central density ``rho0`` can be specified, with the code solving for the normalisation that gives the desired total mass within ``[rad_min, rad_max]``.

This moddump enables the interaction between TDE outflow and the pre-existing circumnuclear material to be simulated, which is crucial for modelling the radio synchrotron emission from the shock between the outflow and the ambient medium.

Physical & Mathematical Description
------------------------------------

The circumnuclear gas cloud density profile is a broken power law: :math:`\rho(r) = \rho_0 (r / r_\mathrm{min})^{-n_k}` for :math:`r \in [r_{k-1}, r_k]`, with the normalisation :math:`\rho_0` set to give the target total mass :math:`M_\mathrm{target} = \int_{r_\mathrm{min}}^{r_\mathrm{max}} 4\pi r^2 \rho(r) \, dr`. Particles are placed using an acceptance-rejection method with the probability distribution proportional to :math:`\rho(r) r^2 \sin\theta`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_radiotde.f90`` for the complete source.
