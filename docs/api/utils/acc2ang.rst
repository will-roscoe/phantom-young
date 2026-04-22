.. phantom-doc: hand-written

acc2ang
=======

Overview
--------

``acc2ang`` is a post-processing utility that reads an accretion evolution file (``accretion.ev``) produced by Phantom and computes the angular momentum accreted onto a specified sink particle as a function of time. It was written by Chris Nixon in March 2014 to support analysis of angular momentum transport in accretion disc simulations.

The program takes three command-line arguments: the sink particle identifier, a minimum time interval ``dt_min`` for binning, and the name of the accretion file. For each accreted particle record in the file, it accumulates the angular momentum contribution and writes a time series to the output file ``accretion.ang``.

Derived quantities include the total accreted angular momentum vector components, the total angular momentum magnitude, and the circularisation radius :math:`r_\mathrm{circ} = L^2 / (G M)`, providing a direct measure of the specific angular momentum of material reaching the sink.

Physical & Mathematical Description
------------------------------------

The angular momentum accreted per time step is :math:`\Delta \mathbf{L} = m_\mathrm{part}\, \mathbf{r} \times \mathbf{v}`, where :math:`\mathbf{r}` and :math:`\mathbf{v}` are the position and velocity of the accreted particle at the time of accretion. The circularisation radius for a Keplerian orbit is :math:`r_\mathrm{circ} = |\mathbf{L}|^2 / (G M_\mathrm{sink})`, which characterises the radius at which the accreted material would circularise into an orbit. Gravitational constant :math:`G = 1` in code units.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/acc2ang.f90
