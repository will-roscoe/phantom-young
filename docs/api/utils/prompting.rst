.. phantom-doc: hand-written

prompting
=========

Overview
--------

``prompting`` is a Phantom utility module providing a generic interactive prompting interface for reading user input at the terminal. The generic ``prompt`` subroutine is overloaded to handle integer, real, double-precision, logical, and string variables, displaying the current value and accepting user input to update it.

The routine uses Fortran's non-advancing I/O and overloading (via an interface block) to present a consistent prompting experience across all variable types. If the user simply presses Enter without typing a new value, the variable retains its current value, making it easy to accept defaults when setting up a simulation.

This module is used extensively in Phantom's setup routines (``setup_*.f90``), analysis drivers (``phantomanalysis``), and moddump tools wherever interactive parameter entry is needed.

Physical & Mathematical Description
------------------------------------

The prompt for a real variable :math:`x` with current value :math:`x_0` displays the message ``prompt_string [x_0]`` and reads a new value if one is entered. Optional minimum and maximum limits :math:`(x_\mathrm{min}, x_\mathrm{max})` are enforced by re-prompting if the entered value is out of range. For logical variables, the prompt accepts ``T``, ``F``, ``y``, or ``n`` as input.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/prompting.f90
