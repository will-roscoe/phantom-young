.. phantom-doc: hand-written

evol_dustywaves
===============

Overview
--------

``evol_dustywaves`` is a standalone program that evolves the analytic dusty wave solution from the ``dustywaves`` module in time, producing output files for comparison with SPH simulations. It sweeps over a range of wavenumbers and computes the kinetic energy of gas and dust as a function of time, enabling comparison of the SPH energy evolution with the analytic prediction.

The program loops over ``nk = 7`` wavenumbers and for each computes the exact wave solution at ``npts = 200`` grid points across a domain of size ``lambda`` at ``nx`` time steps from ``tmin`` to ``tmax``. The kinetic energies of gas and dust are integrated over the domain and written to output files named ``ekin_gas_k*.dat`` and ``ekin_dust_k*.dat``.

By running ``evol_dustywaves`` before a Phantom dusty wave test, the user has the analytic reference solution at exactly the same wavenumber and drag coefficient as the SPH run, enabling a quantitative accuracy assessment.

Physical & Mathematical Description
------------------------------------

The analytic kinetic energy of the gas wave at time :math:`t` is :math:`E_{k,g}(t) = \frac{1}{2} \int_0^\lambda \rho_g v_g^2(x,t) \, dx`, where :math:`v_g(x,t)` is the gas velocity from the exact dusty wave solution (sum of three complex exponential modes from ``exact_dustywave``). The dust kinetic energy :math:`E_{k,d}(t)` is computed analogously.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/evol_dustywaves.f90
