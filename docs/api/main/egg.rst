.. phantom-doc: hand-written

egg
===

Overview
--------

The ``easter_egg`` module provides a hidden 2048-style game embedded within
Phantom, implemented by Cheryl Lau and Fitz Hu for entertainment during long
simulation runs. When triggered, it pauses the simulation immediately and
presents an interactive game in the terminal. The module uses Phantom's
``random`` module for tile placement and ``io`` for terminal output.

The public subroutine ``bring_the_egg`` starts the game; the public flag
``egged`` records whether the easter egg has already been activated. The
module is invoked only under specific (undocumented) conditions and is
explicitly marked as "FOR EMERGENCY USE ONLY". Future plans noted in the
source include deleting all dump files if the user loses, though this has
not been implemented.

Physical & Mathematical Description
------------------------------------

This module contains no physics or numerical algorithms. It is a pure
entertainment utility. The only numerical content is the random tile
placement using ``ran2`` from the ``random`` module, which generates uniform
deviates used to select free grid positions for new tiles.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/egg.f90
