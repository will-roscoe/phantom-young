.. phantom-doc: hand-written

evwrite
=======

Overview
--------

The ``evwrite`` module is responsible for producing the ``.ev`` evolution log
file that Phantom writes once per dump. Each line of the ``.ev`` file records
a snapshot of the simulation state — time, all energy components, linear and
angular momentum, centre of mass, density extremes, timestep, and a
configurable list of physics-dependent diagnostic quantities — in a compact,
columnar format that is easy to plot with standard tools.

The module provides three public routines. ``init_evfile`` opens the output
file, determines which quantities to log based on compile-time physics flags
and runtime options (MHD, dust, radiation, real viscosity, etc.), and writes
the column-header line. ``write_evfile`` calls ``compute_energies`` in the
``energies`` module to accumulate all conserved and derived quantities, then
formats and appends one row. ``write_evlog`` prints a more verbose
human-readable summary to the simulation log file (stdout or ``.log``).

A flexible tag-and-action system lets developers add new diagnostics by
calling ``fill_ev_tag`` with an integer tag, a column label, and an action
string that selects whether to record the sum, maximum, mean, or minimum of
each per-particle quantity: ``'0'`` passes the sum directly, ``'s'`` sums,
and ``'x'``/``'a'``/``'n'`` record max/mean/min respectively. The ``.ev``
file format therefore adapts automatically to the physics modules active in a
given build.

Physical & Mathematical Description
------------------------------------

The energies accumulated in the ``.ev`` file are computed in the companion
``energies`` module by summing over SPH particles. The total energy is

.. math::

   E_\text{tot} = E_\text{kin} + E_\text{therm} + E_\text{pot} + E_\text{mag}

where :math:`E_\text{kin} = \tfrac{1}{2}\sum_i m_i v_i^2`,
:math:`E_\text{therm} = \sum_i m_i u_i` with :math:`u_i` the specific
internal energy, :math:`E_\text{pot}` the gravitational potential energy, and
:math:`E_\text{mag} = \sum_i m_i B_i^2 / (8\pi\rho_i)` for MHD runs. The
angular momentum :math:`\mathbf{L} = \sum_i m_i \mathbf{r}_i \times \mathbf{v}_i`
and linear momentum :math:`\mathbf{p} = \sum_i m_i \mathbf{v}_i` are also
accumulated and reported each dump.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/evwrite.f90
