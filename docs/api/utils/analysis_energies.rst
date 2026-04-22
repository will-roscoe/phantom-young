.. phantom-doc: hand-written

analysis_energies
=================

Overview
--------

``analysis_energies`` computes the global energy budget of a Phantom simulation at each post-processing dump, accounting for accreted particles. It calls ``compute_energies`` to evaluate the kinetic energy :math:`E_k`, magnetic energy :math:`E_\mathrm{mag}`, thermal energy :math:`E_\mathrm{therm}`, potential energy :math:`E_\mathrm{pot}`, and total energy :math:`E_\mathrm{tot}`, and also accumulates the energy of accreted particles in ``eacc``.

The routine initialises the evolution file writer on the first call and writes results to the ``.ev`` file at each dump, giving a time series of all energy components. In GR simulations it also initialises the metric via ``init_metric``. External forces and corotating frame corrections are included via ``iexternalforce``.

This routine provides the most direct check of energy conservation in a Phantom simulation and is indispensable for verifying the correctness of novel physics implementations.

Physical & Mathematical Description
------------------------------------

The total mechanical energy (Newtonian) is :math:`E = E_k + E_p + E_\mathrm{therm}`, where :math:`E_k = \frac{1}{2}\sum_i m_i v_i^2`, :math:`E_p = \frac{1}{2}\sum_i m_i \phi_i` (with :math:`\phi_i` the gravitational potential), and :math:`E_\mathrm{therm} = \sum_i m_i u_i`. In MHD simulations the magnetic energy :math:`E_\mathrm{mag} = \sum_i m_i B_i^2 / (8\pi \rho_i)` is added.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_energies.f90`` for the complete source.
