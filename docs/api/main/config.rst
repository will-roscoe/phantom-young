.. phantom-doc: hand-written

config
======

Overview
--------

The ``config`` module (source file ``config.F90``, which maps to the ``dim``
module at compile time) is the central repository of compile-time dimension
parameters for Phantom. It defines ``maxp`` (maximum particle count),
``maxvxyzu`` (velocity/energy array width), ``maxalpha`` (shock viscosity
switch array), ``maxtypes`` (number of particle types), and a large set of
logical flags such as ``mhd``, ``gr``, ``ind_timesteps``, ``use_apr``, and
``periodic`` that determine which physics branches are compiled in.

The version string and build metadata are injected via the
``phantom-version.h`` include file generated at build time. All arrays in
Phantom are dimensioned using constants from this module, which means that a
given executable has a fixed maximum particle capacity and physics set
determined entirely at compile time. Runtime allocation is handled by the
``memory`` module using the ``maxp_alloc`` variable, which can be overridden
on the command line.

Physical & Mathematical Description
------------------------------------

This module contains no physics equations. Its purpose is to centralise
array-dimension and feature-flag constants so that the compiler can optimise
loops and eliminate dead code for physics branches that are not compiled in.
The separation of compile-time parameters (``dim``) from runtime parameters
(``options``, ``readwrite_infile``) is a deliberate design choice to keep
memory usage minimal.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/config.F90
