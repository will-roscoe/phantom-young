.. phantom-doc: hand-written

ev2kdot
=======

Overview
--------

``ev2kdot`` is a command-line utility that computes the time derivative of total entropy :math:`K` from one or more Phantom ``.ev`` evolution files, writing the result to ``.kdot`` files. It uses the shared infrastructure in ``ev2dot_utils`` (the ``ev2dot`` routine) with the ``output_type = 'kdot'`` flag.

The program accepts an optional first argument specifying the minimum time interval ``dt_min`` for averaging, followed by one or more ``.ev`` filenames. If multiple files are provided, they are spliced into a continuous time series before differentiation, handling the standard Phantom restart convention where ``.ev`` files are numbered sequentially.

Usage is ``ev2kdot [dt_min] file01.ev file02.ev ...``. The output ``.kdot`` file records time and :math:`\dot{K}` in code units, providing a measure of entropy production (or consumption) due to dissipation and heating.

Physical & Mathematical Description
------------------------------------

The entropy derivative :math:`\dot{K} = dK/dt` is approximated by finite differences: :math:`\dot{K}_n \approx (K_{n+1} - K_{n-1}) / (t_{n+1} - t_{n-1})` for interior points, or one-sided differences at the boundaries. The entropy :math:`K` is read from the appropriate column of the ``.ev`` file as set by the Phantom EOS choice. For a polytropic gas, :math:`K = P / \rho^\gamma`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/ev2kdot.f90
