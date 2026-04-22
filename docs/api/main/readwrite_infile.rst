.. phantom-doc: hand-written

readwrite_infile
================

Overview
--------

The ``readwrite_infile`` module provides the two top-level routines that handle
Phantom's ``.in`` runtime parameter file: ``write_infile`` and ``read_infile``. The
``.in`` file uses a simple ``key = value`` text format (one option per line, comments
prefixed with ``#``), and is written and read through the lower-level
``infile_utils`` module, which maintains a database (``inopts``) of key–value pairs.

``write_infile`` assembles the complete ``.in`` file by calling the
``write_options_*`` routine of every physics module compiled into the binary. The
sections written include I/O control, timestepping, neighbour-tree accuracy, smoothing
length parameters, shock capturing, damping, equation of state, cooling, MCFOST
coupling, sink particles, external forces, physical viscosity, turbulent forcing, dust
(single-fluid and multi-fluid), dust growth, injection, nucleation, non-ideal MHD,
radiation, general relativity metric, dynamic boundaries, adaptive particle refinement
(APR), H II region treatment, and optional diagnostic outputs. A date–time stamp is
written in the file header.

``read_infile`` opens the ``.in`` file as a key–value database, dispatches each option
to its owning module via ``read_options_from_db``, warns about unrecognised keys, and
rewrites the file if options are missing (i.e. if the binary was compiled with more
modules than the existing ``.in`` file covers). If the supplied filename matches the
pattern of a Phantom dump file name (``prefix_NNNNN``), the code infers the
corresponding ``.in`` filename automatically.

Physical & Mathematical Description
------------------------------------

The ``.in`` file format is line-oriented. Each non-comment line has the structure:

.. math::

   \underbrace{\mathtt{key}}_{\text{option name}}
   \;\mathtt{=}\;
   \underbrace{\mathtt{value}}_{\text{scalar or string}}
   \quad \mathtt{\#}\; \underbrace{\text{description}}_{\text{comment}}

Version compatibility is maintained implicitly: if a key is absent from the file,
the corresponding variable retains the default value set by its module's
``set_defaults_*`` routine, and the key is added when the file is rewritten. If a key
is present but unrecognised, a warning is issued via the ``io`` module.

The smoothing-length convergence tolerance ``tolh`` and the smoothing-length factor
``hfact`` (stored in ``part``) satisfy the relation:

.. math::

   \left| h - h_{\mathrm{fact}}\left(\frac{m}{\rho}\right)^{1/3} \right|
   < \mathtt{tolh} \times h

which is used to terminate the iterative Newton–Raphson solve for :math:`h` in the
density calculation. Both parameters are written to and read from the ``.in`` file by
this module.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/readwrite_infile.f90
