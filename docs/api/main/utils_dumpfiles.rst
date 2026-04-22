.. phantom-doc: hand-written

utils_dumpfiles
===============

Overview
--------

The ``dump_utils`` module provides the low-level binary I/O primitives for
reading and writing Phantom dump files. It implements the tagged-block format
used by all Phantom ``.dump`` files: each data block is preceded by a
16-character tag string and a block-length header, allowing readers to skip
unknown blocks and identify data by name rather than position. The module
provides ``open_dumpfile_w`` / ``open_dumpfile_r`` for file opening,
``write_array`` / ``read_array`` for typed array I/O, and
``add_to_header`` / ``extract`` for manipulating the file header.

The ``tag`` / ``check_tag`` / ``match_tag`` routines manage the tag
strings, and ``get_error_text`` converts numeric error codes to human-readable
messages. This module is used by ``readwrite_dumps`` and is also used directly
by splash and other analysis tools that read Phantom dump files without
linking against the full code.

Physical & Mathematical Description
------------------------------------

This is a pure I/O utility module with no physics content. The block-tagged
format provides forward and backward compatibility across code versions:
new blocks can be added without breaking old readers (which skip unknown
tags), and old blocks can be marked deprecated without breaking new code
(which handles missing blocks gracefully). The format version is tracked by
a parameter in the dump header.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_dumpfiles.f90
