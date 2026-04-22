.. phantom-doc: hand-written

utils_system
============

Overview
--------

The ``systemutils`` module provides utilities for retrieving command-line
arguments and flags in Phantom. The three public functions —
``get_command_option`` (integer), ``get_command_option_real`` (real), and
``get_command_option_logical`` (logical) — parse the Phantom command line
for options of the form ``--name=value``, returning the specified value or a
default if the option is not present. This is used by the main program to
handle the ``--maxp=`` option and by phantomsetup for various setup flags.

The parsing scans all command-line arguments looking for strings that match
``--name=``, then extracts the value portion and converts it to the
appropriate type using an internal read statement. The search is
case-sensitive. If multiple arguments match the same name (which should not
happen in normal use), the last one wins.

Physical & Mathematical Description
------------------------------------

This module is a pure command-line parsing utility with no physics content.
It avoids external dependencies on argument-parsing libraries by implementing
the minimal subset of functionality needed by Phantom: integer, real, and
logical ``--flag=value`` options. More complex argument structures (positional
arguments, short flags) are not supported.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_system.f90
