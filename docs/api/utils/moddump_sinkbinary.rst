.. phantom-doc: hand-written

moddump\_sinkbinary
===================

Overview
--------

``moddump_sinkbinary`` adds a sink-particle binary to an existing Phantom dump, enabling post-setup insertion of a compact-object or stellar binary without re-running the full setup procedure. It was written by Mike Lau and uses the ``setbinary`` routine to initialise the orbital elements of the two sinks.

The user specifies the component masses, semi-major axis, and eccentricity interactively. The routine places the two sinks at the correct Keplerian positions and velocities, resets the centre of mass, and optionally configures the gravitational-wave inspiral external force (``iext_gwinspiral``) for neutron-star or black-hole binary simulations.

Timing parameters ``dtmax`` and ``tmax`` are also updated to values appropriate for the binary orbital period, ensuring the time-step control remains well resolved through periastron passage.

Physical & Mathematical Description
------------------------------------

The binary is initialised at separation :math:`a(1 - e)` (periastron) with relative velocity :math:`v_\mathrm{rel} = \sqrt{G(m_1 + m_2)(1+e)/[a(1-e)]}` for eccentricity :math:`e`. The orbital period :math:`T = 2\pi\sqrt{a^3/[G(m_1+m_2)]}` sets the recommended output cadence. Gravitational-wave energy loss follows the Peters formula :math:`\dot{E}_\mathrm{GW} \propto (m_1 m_2)^2 (m_1 + m_2) / a^5` when the inspiral module is active.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_sinkbinary.f90`` for the complete source.
