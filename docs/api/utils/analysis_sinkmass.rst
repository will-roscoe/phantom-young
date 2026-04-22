.. phantom-doc: hand-written

analysis_sinkmass
=================

Overview
--------

``analysis_sinkmass`` writes the mass of each sink particle as a function of time to a separate output file per sink. At each dump it opens (or creates) an output file named ``sinkXX.ev`` (where ``XX`` is the sink index) and appends the current time and sink mass from ``xyzmh_ptmass``.

This routine provides a lightweight and robust way to track the mass accretion history of each sink particle in a star formation or binary simulation. The output files can be plotted directly with SPLASH or any plotting tool to produce mass-time curves.

On the first call the user is prompted (via ``prompt``) to confirm or modify the maximum number of sink particles to track. Subsequent calls append to the existing files without user interaction.

Physical & Mathematical Description
------------------------------------

The mass of sink particle :math:`k` at time :math:`t` is :math:`M_k(t) = \texttt{xyzmh\_ptmass}(\texttt{imass}, k)`, where ``imass`` indexes the mass column in the sink properties array. The growth rate is :math:`\dot{M}_k = \Delta M_k / \Delta t`, which can be estimated from differences between consecutive dump values.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_sinkmass.f90`` for the complete source.
