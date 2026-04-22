.. phantom-doc: hand-written

phantom_moddump
===============

Overview
--------

``phantom_moddump`` is the main driver program for Phantom's dump modification framework. It reads an input dump file, calls the ``modify_dump`` routine from the linked ``moddump`` module to apply the desired modification, and writes the modified particles to an output dump file.

The program accepts command-line arguments ``dumpfilein dumpfileout [time] [outformat] [--maxp=N]``, enabling the output time and format to be overridden. The ``moddump_flags`` string in each ``moddump_*.f90`` module documents any additional command-line options accepted by that specific moddump routine.

``phantom_moddump`` handles initialisation of the equation of state, magnetic field setup, and check routines (``check_setup``, ``get_conserv``) before and after the modification, ensuring that the modified dump satisfies all required constraints.

Physical & Mathematical Description
------------------------------------

The modification is applied by the ``modify_dump(npart, npartoftype, massoftype, xyzh, vxyzu)`` interface, which receives the full particle arrays and may add, remove, or modify particles, change particle types, or update the equation of state parameters. After modification, ``check_setup`` verifies that the modified dump is consistent (no overlapping particles, correct density normalisation, etc.).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom_moddump.f90
