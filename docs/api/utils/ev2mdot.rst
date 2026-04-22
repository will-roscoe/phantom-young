.. phantom-doc: hand-written

ev2mdot
=======

Overview
--------

``ev2mdot`` is a command-line utility that extracts the mass accretion rate :math:`\dot{M}(t)` from Phantom ``.ev`` evolution files. Written by Daniel Price (March 2011, rewritten August 2017), it splices multiple ``.ev`` files together and differentiates the accreted mass column to produce a smooth accretion rate time series.

The program uses the ``ev2dot`` routine from ``ev2dot_utils``, called with the default ``output_type = 'mdot'`` flag. It accepts the same command-line interface as ``ev2kdot`` (optional ``dt_min`` argument followed by filenames). Output is written to ``.mdot`` files with columns for time and :math:`\dot{M}` in code units.

This utility is widely used for computing accretion luminosities (assuming :math:`L = \eta \dot{M} c^2`), constructing TDE light curves, and diagnosing steady-state accretion rates in disc simulations.

Physical & Mathematical Description
------------------------------------

The mass accretion rate is :math:`\dot{M}(t_n) = (M_\mathrm{acc}(t_{n+1}) - M_\mathrm{acc}(t_{n-1})) / (t_{n+1} - t_{n-1})`, where :math:`M_\mathrm{acc}` is the cumulative accreted mass column from the ``.ev`` file. When ``dt_min > 0`` the accretion rate is averaged over intervals of at least ``dt_min`` to suppress fluctuations from individual dump timesteps.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/ev2mdot.f90
