.. phantom-doc: hand-written

setup_empty
===========

Overview
--------

``setup_empty`` is a minimal placeholder setup that creates no SPH particles. It is used as a starting point for simulations driven entirely by an injection module at run time, or for sink-particle-only simulations (e.g., pure N-body runs with no gas). The setup sets standard units in solar masses and astronomical units, initialises the smoothing-length factor to its default value, and returns immediately.

This setup is also useful during code development as a template for new setup routines — it compiles and runs correctly under any build configuration, providing a safe fallback when no physical particles are needed at initialisation. The adiabatic index defaults to 5/3 but is not used in the absence of gas particles.

No runtime parameter file is written or read, since there are no tunable parameters.

Physical & Mathematical Description
------------------------------------

No particles are placed; the only quantities initialised are the global unit conversion factors via ``set_units(dist=au, mass=solarm, G=1)`` and the SPH smoothing-length factor ``hfact``. The total particle count is set to zero: :math:`N_\mathrm{part} = 0`. Any mass, momentum, or energy subsequently introduced into the simulation comes entirely from the injection or sink-particle modules.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_empty.f90`` for the complete source.
