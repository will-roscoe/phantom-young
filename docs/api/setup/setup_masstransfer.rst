.. phantom-doc: hand-written

setup_masstransfer
==================

Overview
--------

``setup_masstransfer`` configures a binary system in Roche-lobe overflow (RLOF), representing mass transfer from a donor star to a compact accretor. The donor star is modelled either as a sink particle or as a full SPH star built by ``setstar``, while the accretor is always a sink. Wind particles are continuously injected from near the inner Lagrange point L1 using the injection module, simulating the gas stream that flows from the donor's Roche lobe toward the accretor.

Runtime parameters include the donor mass ``mdon`` and accretor mass ``macc``, the binary semi-major axis ``a``, the mass transfer rate ``mdot`` in solar masses per year, the gas temperature ``gastemp``, and the accretion radii ``hdon`` and ``hacc`` for the two stars. Optionally the donor can be represented by a full MESA-profile star (``use_mesa_file``), or the accretor modelled as a fully resolved SPH star (``use_resolved_accretor``).

This setup is used for AM CVn systems, cataclysmic variables, X-ray binaries, and common-envelope precursor scenarios where stream dynamics and disc formation are of interest.

Physical & Mathematical Description
------------------------------------

The mass transfer rate through the L1 point scales as :math:`\dot{M} \propto \exp[-(R_{L1} - R_\mathrm{donor})/H_p]` where :math:`H_p = c_s^2 R_L / (GM_\mathrm{donor}/R_L^2)` is the pressure scale height at the Roche surface. The gas stream velocity at L1 is :math:`v_\mathrm{L1} \approx c_s` (sonic). The Roche lobe radius of the donor is given by :cite:`eggleton83`: :math:`R_L/a \approx 0.49 q^{2/3} / [0.6 q^{2/3} + \ln(1+q^{1/3})]` with :math:`q = M_\mathrm{donor}/M_\mathrm{acc}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_masstransfer.f90`` for the complete source.
