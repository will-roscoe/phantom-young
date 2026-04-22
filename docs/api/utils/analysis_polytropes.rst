.. phantom-doc: hand-written

analysis_polytropes
===================

Overview
--------

``analysis_polytropes`` analyses single or binary polytrope simulations by computing the density profile, comparing it with the analytic Lane-Emden solution, and tracking the orbital period of binary stars. It uses ``rho_polytrope`` from the ``rho_profile`` module to generate the reference analytic profile.

For single stars the routine computes the :math:`L_1` error norm of the density profile against the Lane-Emden solution. For binaries it additionally tracks the orbit by monitoring centre-of-mass positions, detecting each orbital period from zero-crossings in the relative separation vector.

Output files record the density profile at each frequency-th dump and the orbital period estimate as a function of time, enabling verification of both the stellar equilibrium structure and the binary orbital dynamics.

Physical & Mathematical Description
------------------------------------

The Lane-Emden equation governing a polytrope of index :math:`n` is :math:`\frac{1}{\xi^2} \frac{d}{d\xi}\left(\xi^2 \frac{d\theta}{d\xi}\right) + \theta^n = 0`, with :math:`\rho = \rho_c \theta^n` and :math:`\xi` the dimensionless radius. The :math:`L_1` error norm is :math:`\epsilon_1 = \int_0^{R_*} |\rho_\mathrm{SPH}(r) - \rho_\mathrm{LE}(r)| \, 4\pi r^2 dr / M_*`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_polytropes.f90`` for the complete source.
