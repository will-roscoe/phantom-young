.. phantom-doc: hand-written

moddump_dustsinkfrac
====================

Overview
--------

``moddump_dustsinkfrac`` modifies the dust fraction of gas particles in the vicinity of sink particles, reducing the dust-to-gas ratio near sinks to prevent spurious shadowing effects in radiative transfer post-processing (e.g. with MCFOST). Written by Josh Calcino, it sets the dust fraction of particles within a specified radius of each sink to a reduced value.

The user is prompted for the radius (in au) within which the dust fraction should be reduced and the target dust fraction value. Particles within this radius have their ``dustfrac`` array updated accordingly, while particles outside the radius are unchanged.

This moddump is a pragmatic solution to a known artefact in MCFOST post-processing where high dust densities near sink particles produce incorrect shadows on the disc. By reducing the dust fraction in the sink neighbourhood, more physically realistic synthetic images can be obtained.

Physical & Mathematical Description
------------------------------------

For each gas particle :math:`i` within radius :math:`r_\mathrm{inner}` of a sink, the dust fraction is set to :math:`\epsilon_i = \epsilon_\mathrm{target}` for each dust species. The one-fluid dust fraction satisfies :math:`0 \leq \epsilon_i \leq 1` and is stored in ``dustfrac(k, i)`` for dust species :math:`k`. The modification preserves the total mass since :math:`m_\mathrm{gas} = m_\mathrm{particle} (1 - \sum_k \epsilon_{i,k})` is unchanged in the ``massoftype`` array.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_dustsinkfrac.f90`` for the complete source.
