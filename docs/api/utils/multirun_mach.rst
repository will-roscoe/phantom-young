.. phantom-doc: hand-written

multirun_mach
=============

Overview
--------

``multirun_mach`` generates a series of Phantom input files varying the target RMS Mach number for driven turbulence simulations. It reads an existing ``.in`` file, modifies the turbulent driving parameters (``st_energy``, ``st_decay``, etc.) for each Mach number, and writes a new ``.in`` file for each run, also adjusting ``tmax`` and ``dtmax`` to the dynamical time.

For each Mach number :math:`\mathcal{M}` the program computes the required energy injection rate from the driving formula and sets the autocorrelation time of the stochastic forcing. The dynamical time :math:`t_\mathrm{dyn}` is estimated from the RMS Mach number and the box size, setting ``tmax = 10 t_\mathrm{dyn}``.

This utility makes it straightforward to run a suite of turbulence simulations at different Mach numbers, as required for testing compressible turbulence scaling relations.

Physical & Mathematical Description
------------------------------------

The turbulent energy injection rate required to maintain an RMS Mach number :math:`\mathcal{M}` in a box of size :math:`L` with sound speed :math:`c_s` is approximately :math:`\epsilon_\mathrm{drive} \sim \mathcal{M}^3 c_s^3 / L`. The stochastic forcing driving time is set to :math:`t_\mathrm{drive} = t_\mathrm{dyn} = L / (\mathcal{M} c_s)` and the energy per driving mode is proportional to the target Mach number squared.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/multirun_mach.f90
