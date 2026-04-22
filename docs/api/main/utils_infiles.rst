.. phantom-doc: hand-written

utils_infiles
=============

Overview
--------

The ``infile_utils`` module provides utilities for reading and writing
Phantom's ``.in`` (input parameter) files. It implements a simple
key–value store: each line of the ``.in`` file has the form
``key = value  ! description``, and the ``write_inopt`` / ``read_inopt``
routines handle integers, reals (4-byte and 8-byte), strings, and logicals
through a generic interface. Section headers (lines starting with ``#``) are
preserved for readability.

The module also provides ``check_and_unroll_infile`` which processes
``-DVAL`` override directives embedded in the ``.in`` file, ``infile_exists``
to test for a file's presence, and ``get_optstring`` to retrieve a named
option's value as a string. The ``get_options`` routine supports the
``--option=value`` command-line override syntax used by phantomsetup.

Physical & Mathematical Description
------------------------------------

This is a pure I/O utility module; it contains no physics equations. The
``.in`` file format is designed to be human-readable and self-documenting: the
description string embedded in each ``write_inopt`` call appears as a comment
in the generated file, so the parameter file serves as its own reference
manual. The ``read_inopt`` routines return error counts so that the calling
code can check whether all required parameters were found.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_infiles.f90
