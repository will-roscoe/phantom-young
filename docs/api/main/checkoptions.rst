.. phantom-doc: hand-written

checkoptions
============

Overview
--------

The ``checkoptions`` module validates compile-time configuration flags at
runtime, before any particle setup or time integration begins. The single
public subroutine ``check_compile_time_settings`` checks that the
preprocessor macros used to build the executable are mutually consistent and
that the resulting ``dim`` module variables match what those macros imply.

Checks include: ensuring that ``-DMHD`` is set when the ``mhd`` flag is true,
that ``-DNONIDEALMHD`` requires ``-DMHD``, that H2 chemistry is only enabled
in 3D, that the GR metric coordinate system is Cartesian, and that various
combinations of dust, disc viscosity, and turbulent driving flags are
consistent with each other and with the MPI configuration. Failures
increment the error counter ``ierr`` and print diagnostic messages on the
master MPI rank.

Physical & Mathematical Description
------------------------------------

This module performs purely logical checks on compile-time constants; it
contains no physical equations. It acts as a gate that prevents the code from
running with incompatible option combinations that could produce silently
wrong results, such as enabling non-ideal MHD without the underlying MHD
flag or using the GR metric module in non-Cartesian coordinates where the
implementation is not valid.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/checkoptions.F90
