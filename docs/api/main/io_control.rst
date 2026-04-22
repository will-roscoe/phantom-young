.. phantom-doc: hand-written

io_control
==========

Overview
--------

The ``io_control`` module manages the runtime control flags that govern when Phantom
writes output files and when it terminates a simulation. The key integer parameters
are ``nfulldump`` (full dump every *n* dump outputs), ``nmaxdumps`` (abort after *n*
full dumps), ``nout`` (write a dump every *n* multiples of ``dtmax``), and ``nmax``
(maximum number of timesteps). The real-valued parameters ``tmax``, ``dtmax``, and
``twallmax`` set the physical end-time, the time interval between dump files, and a
wall-clock limit, respectively.

The module provides ``set_defaults_iocontrol``, ``write_options_iocontrol``, and
``read_options_iocontrol`` to integrate with the standard ``.in`` parameter-file
mechanism. The function ``at_simulation_end`` returns ``.true.`` when any termination
criterion is satisfied: the simulation time exceeds ``tmax``, the step count reaches
``nmax``, or the maximum gas density exceeds ``rhofinal_cgs`` (if set). The function
``check_for_full_dump`` additionally promotes partial dumps to full dumps when the
remaining wall-clock budget is insufficient for one more full dump, preventing data
loss at batch-queue time limits.

The verbosity flag ``iverbose`` (re-exported from ``io``) is read and written here,
ranging from ``-1`` (quiet) through ``0`` (default) to ``5`` (maximum debug output).
The ``set_rhofinal1`` subroutine converts the CGS density threshold ``rhofinal_cgs``
into the inverse code-unit density ``rhofinal1 = unit_density / rhofinal_cgs``,
allowing the terminal-density test to be evaluated without a division at every step.

Physical & Mathematical Description
------------------------------------

The simulation end condition is a logical disjunction of three independent criteria:

.. math::

   \mathrm{end} = \bigl(t \ge t_{\max}\bigr)
   \;\lor\; \bigl(n_{\mathrm{steps}} \ge n_{\max},\; n_{\max} \ge 0\bigr)
   \;\lor\; \bigl(\rho_{\max}\,\rho_{\mathrm{final}}^{-1} \ge 1\bigr)

where :math:`\rho_{\mathrm{final}}^{-1} \equiv u_\rho / \rho_{\mathrm{final,cgs}}`
is precomputed by ``set_rhofinal1`` using the code density unit :math:`u_\rho`.

The wall-clock abort logic in ``check_for_full_dump`` uses the following heuristic.
Let :math:`T_w` be the elapsed wall time and :math:`\Delta T_d` the wall time consumed
by the most recent dump interval. A full dump is promoted and the run is flagged for
abort if:

.. math::

   T_w + n_{\mathrm{full}}\,\Delta T_d > T_{w,\max}
   \quad (\text{for a scheduled full dump}),

or

.. math::

   T_w + 3\,\Delta T_d > T_{w,\max}
   \quad (\text{for a partial dump, promoting to full})

The factor of three provides a safety margin for steps that may take longer than the
previous interval.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/io_control.f90
