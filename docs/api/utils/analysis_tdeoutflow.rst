.. phantom-doc: hand-written

analysis_tdeoutflow
===================

Overview
--------

``analysis_tdeoutflow`` computes the outflow rate and velocity distribution of particles crossing a spherical surface of radius ``r_in`` (in cm) in a TDE simulation. Written by Fitz Hu, it accumulates the mass of outflowing particles (those passing through the capture surface for the first time) and computes mean and cumulative outflow velocities.

Angular constraints (:math:`\theta \in [\theta_\min, \theta_\max]` and :math:`\phi \in [\phi_\min, \phi_\max]`) enable directional selection of the outflow, making it possible to study jet-like or disc-wind outflows separately from the isotropic debris stream.

Parameters are read from a ``.params`` file. Output files record the outflow mass, velocity distribution, and angular distribution at each dump, which can be used to construct radio TDE light curve models or compare with X-ray wind observations.

Physical & Mathematical Description
------------------------------------

The outflow rate is computed by tracking particles that cross the surface :math:`r = r_\mathrm{in}` (inward-to-outward) for the first time, recording their velocity :math:`v_r > 0` at crossing. The cumulative mass is :math:`M_\mathrm{out}(t) = \sum_{i: \text{first crossing before } t} m_i`. The velocity distribution :math:`dM/dv` is the mass fraction of outflowing particles per unit velocity interval.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_tdeoutflow.f90`` for the complete source.
