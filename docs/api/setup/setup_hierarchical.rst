.. phantom-doc: hand-written

setup_hierarchical
==================

Overview
--------

``setup_hierarchical`` places N sink particles in an hierarchical multiple-star configuration using the ``sethierarchical`` module. No gas particles are created; the entire system consists of point-mass sinks. The hierarchy — which can represent a triple, quadruple, or higher-order system — is described by nested binary pairs, each with its own mass ratio, semi-major axis, eccentricity, and inclination as defined by the ``set_hierarchical`` routine.

The module reads all orbital parameters from the standard Phantom parameter file through the ``get_options`` interface, and provides the ``print_chess_logo`` output for identification. Units are set in solar masses and astronomical units, making this setup suitable for hierarchical stellar systems such as :math:`\alpha` Centauri (triple) or Castor (sextuple).

This setup is used to test the hierarchical orbit integrator, study Kozai-Lidov oscillations in inclined triple systems, and provide initial conditions for studying the dynamical evolution and eventual mergers of compact hierarchical multiples.

Physical & Mathematical Description
------------------------------------

A hierarchical triple consists of an inner binary of masses :math:`m_1, m_2` on an orbit of semi-major axis :math:`a_\mathrm{in}` and an outer companion :math:`m_3` on a wider orbit of semi-major axis :math:`a_\mathrm{out}`. For stability the ratio :math:`a_\mathrm{out}/a_\mathrm{in} \gtrsim 3 (1 + m_3/(m_1+m_2))^{1/3}` must be satisfied. Kozai-Lidov oscillations exchange eccentricity and inclination on a timescale :math:`t_\mathrm{KL} \approx T_\mathrm{out}^2 / T_\mathrm{in} \cdot (m_1+m_2+m_3)/m_3` when the mutual inclination exceeds :math:`\approx 39°`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_hierarchical.f90`` for the complete source.
