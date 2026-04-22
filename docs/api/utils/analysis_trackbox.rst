.. phantom-doc: hand-written

analysis_trackbox
=================

Overview
--------

``analysis_trackbox`` tracks the positions and velocities of gas and dust particles in a dusty wave or dusty box simulation, comparing their trajectories with an analytic prediction. It reads initial conditions and computes the predicted analytic trajectory for gas and dust separately, then records the simulation particle positions for direct comparison.

The routine is designed to validate dust-gas drag implementations against analytic solutions for a dusty standing wave in a periodic box. It tracks ``maxtrack = 200`` individual particles at specified radial positions and height-to-radius ratios, writing their phase-space coordinates to per-particle output files.

By comparing the tracked particle trajectories with the analytic prediction (stored in variables ``vgas_pred``, ``vdust_pred``, etc.), the accuracy of the drag coupling and velocity integration can be quantitatively assessed.

Physical & Mathematical Description
------------------------------------

For a dusty standing wave with drag coefficient :math:`K` and sound speed :math:`c_s`, the analytic velocity of the gas at position :math:`x` and time :math:`t` involves a combination of exponentially decaying modes :math:`v_g(x,t) = \sum_k A_k e^{s_k t} \cos(kx)`, where the complex growth rates :math:`s_k` are roots of the cubic dispersion relation for gas-dust sound waves. The terminal velocity solution is :math:`\Delta v = v_g - v_d = -\nabla P / (K \rho)` at late times.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_trackbox.f90`` for the complete source.
