.. phantom-doc: hand-written

analysis_radiotde
=================

Overview
--------

``analysis_radiotde`` analyses the outflow properties in a tidal disruption event simulation for radio TDE modelling. It computes the velocity, radial distribution, and angular distribution (:math:`\theta`, :math:`\phi`) of particles within a capture region defined by a spherical shell of inner radius ``rad_cap`` and thickness ``drad_cap``, with angular limits on :math:`\theta` and :math:`\phi` for directional selection.

The routine accumulates outflowing mass :math:`M_\mathrm{cap}` and computes the mean and maximum radial velocities within the capture region, enabling the construction of velocity distributions relevant to radio synchrotron emission modelling. Parameters are read from a ``.params`` file that the user can configure for each analysis.

Output includes time-series files of outflow velocity distributions and the total captured mass, suitable for input to radio emission models that predict the synchrotron light curve of the TDE.

Physical & Mathematical Description
------------------------------------

The total outflow mass in the capture region :math:`[r_\mathrm{cap}, r_\mathrm{cap} + \Delta r_\mathrm{cap}]` with angular constraints :math:`\theta \in [\theta_\min, \theta_\max]` and :math:`\phi \in [\phi_\min, \phi_\max]` is :math:`M_\mathrm{cap} = \sum_i m_i`, where the sum is over outflowing particles (:math:`v_{r,i} > 0`) satisfying the radial and angular constraints. The mean outflow velocity is :math:`\bar{v}_r = \sum_i m_i v_{r,i} / M_\mathrm{cap}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_radiotde.f90`` for the complete source.
