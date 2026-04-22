.. phantom-doc: hand-written

ev2dot_utils
============

Overview
--------

``ev2dot_utils`` is a library module providing utility routines for computing time derivatives (``mdot`` and ``kdot``) from sequences of Phantom ``.ev`` evolution files. It implements the core ``ev2dot`` routine that reads a list of ``.ev`` files, splices them into a continuous time series (handling restarts and duplicate time entries), and numerically differentiates the selected column to produce ``.mdot`` or ``.kdot`` output files.

The module is shared between the ``ev2mdot`` and ``ev2kdot`` programs, allowing either the mass accretion rate :math:`\dot{M}` or the entropy derivative :math:`\dot{K}` to be computed from the same infrastructure. The splicing logic uses ``files_are_sequential`` from the ``fileutils`` module to detect whether consecutive files overlap in time.

The differentiation is performed using finite differences over a minimum time interval ``dtmin`` to suppress noise from individual dump fluctuations, producing a smooth accretion rate as a function of time.

Physical & Mathematical Description
------------------------------------

The accretion rate is computed as :math:`\dot{M}(t) = \Delta M / \Delta t`, where :math:`\Delta M` is the change in accreted mass column between two dump times :math:`\Delta t` apart. To reduce noise, values are averaged over a minimum time window ``dtmin``, corresponding to a running average with window :math:`\Delta t \geq t_\mathrm{min}`. The entropy time derivative is :math:`\dot{K} = \Delta K / \Delta t` where :math:`K` is the entropy-related column in the ``.ev`` file.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/ev2dot_utils.f90
