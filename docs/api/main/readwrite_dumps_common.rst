.. phantom-doc: hand-written

readwrite_dumps_common
======================

Overview
--------

The ``readwrite_dumps_common`` module contains shared utility routines used by both
the binary dump path (``readwrite_dumps``) and the HDF5 dump path. Its primary exports
are ``fileident``, which constructs the file-identifier string embedded at the start of
every Phantom dump file, and ``fill_header`` / ``unfill_header``, which translate
between the in-memory ``dump_h`` header structure and the named scalar variables used
throughout the code.

The ``fileident`` function assembles a fixed-length character string encoding the dump
type (``F`` full / ``S`` small), whether tagged arrays are used (``T``), the code name
(``Phantom`` or ``sphNG``), the semantic version string from ``dim``, the git SHA from
``gitinfo``, a summary of active compile-time physics flags (``+grav``, ``+dust``,
``+1dust``, ``+mhd``, ``+H2chem``, ``+dustgrowth``, ``+krome``, ``+Tdust``,
``+nucleation``), and a wall-clock timestamp. This string is written as the first record
of every dump file and is read back by ``get_options_from_fileid`` to determine whether
the file is a full or small dump, whether tagged binary format is in use, whether it
originates from Phantom or sphNG, and whether one-fluid dust was active.

The ``unfill_header`` subroutine extracts particle counts, code units, and all physical
scalars from a ``dump_h`` object into named Phantom variables, including backwards-
compatible handling of older field names (e.g. ``ndustfluids`` as a fallback for the
current ``ndustsmall``). It calls ``set_units_extra`` after reading ``udist``,
``umass``, and ``utime`` from the header, ensuring that all derived unit conversions
are consistent with the file being read.

Physical & Mathematical Description
------------------------------------

The file-identifier string is a fixed-length record whose structure can be described
schematically. For a tagged full dump the record takes the form:

.. math::

   \underbrace{c_1 c_2}_{\text{type flags}}
   \mathtt{:}
   \underbrace{\text{code}}_{\le 7}
   \mathtt{:}
   \underbrace{v_{\mathrm{str}}}_{\text{version}}
   \mathtt{:}
   \underbrace{\mathrm{SHA}_{8}}_{\text{git}}
   \;\mathtt{(}
   \underbrace{\text{flag}_1\cdots\text{flag}_k}_{\text{physics}}
   \mathtt{)}\;
   \underbrace{dd/mm/yyyy\;hh:mm:ss}_{\text{timestamp}}

where :math:`c_1 \in \{F, S\}` and :math:`c_2 = T` indicate full/small and tagged
format respectively. The ``lenid`` parameter (imported from ``dump_utils``) defines the
total character length of this identifier, ensuring fixed-size binary records.

The header extraction in ``unfill_header`` reads the three fundamental code units and
propagates them to all derived units via ``set_units_extra``:

.. math::

   u_v = \frac{u_r}{u_t},\quad
   u_\rho = \frac{u_m}{u_r^3},\quad
   u_P = \frac{u_m}{u_r\,u_t^2},\quad
   u_B = \frac{u_m}{u_t\,u_q}

ensuring that quantities read from the dump file can be converted to physical units
immediately after the header is processed.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/readwrite_dumps_common.f90
