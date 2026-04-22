.. phantom-doc: hand-written

writeheader
===========

Overview
--------

The ``writeheader`` module prints the human-readable run header to the
simulation log file at the start of each Phantom run. It is called twice by
the ``initial`` module: once before particle setup (``icall=1``) to record
the input file names, code version, and a copy of the ``.in`` parameter file,
and once after setup (``icall=2``) to report actual particle counts, kernel
parameters, and a summary of all active physics modules.

The ``write_codeinfo`` subroutine prints an ASCII-art Phantom logo together
with the version string and the output of ``get_and_print_gitinfo``, which
records the most recent git commit hash and recently changed source files. The
``write_header`` subroutine then produces a detailed summary of every active
physics option — MHD, gravity, H2 chemistry, dust (one-fluid or two-fluid,
with or without growth and porosity), cooling, radiation, sink particle
creation, physical viscosity, and the equation of state — so that each log
file is self-documenting.

Physical & Mathematical Description
------------------------------------

This module performs no physics or numerical calculations; it is purely
formatted I/O. For the mathematical content of the parameters it reports,
see the ``kernel``, ``viscosity``, and ``options`` module documentation. The
neighbour estimate printed in the header is

.. math::

   N_\text{neigh} \approx \frac{4}{3}\pi (q_\text{kern}\, h_\text{fact})^3,

where :math:`q_\text{kern}` is the kernel support radius in units of the
smoothing length :math:`h` and :math:`h_\text{fact}` is the normalisation
constant relating :math:`h` to the local particle spacing.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/writeheader.f90
