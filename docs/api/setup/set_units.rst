.. phantom-doc: hand-written

set_units
=========

Overview
--------

The ``set_units`` module is a thin convenience wrapper around the core
``units`` module, providing a single entry point for setup routines that
need to define the simulation's physical unit system.  It calls
``units.set_units`` with appropriate values of the distance unit, mass
unit, and time (or gravitational) unit, and optionally prints a summary
of the unit conversion factors to the standard output.

Most Phantom setup routines call ``set_units`` at the start of the
``setup`` subroutine to fix the code unit system before any physical
quantities are computed.  A consistent unit system is essential because
the dimensionless code quantities stored in the dump file must be
multiplied by the unit factors to recover physical values in CGS or SI.

Physical & Mathematical Description
------------------------------------

Phantom uses a gravitational unit system defined by three independent
scales: the unit of length :math:`\ell_0`, the unit of mass
:math:`m_0`, and the unit of time :math:`t_0` (or equivalently the
unit of velocity :math:`v_0 = \ell_0/t_0`).  From these, all other
units are derived:

.. math::

   [G] = \frac{\ell_0^3}{m_0 \, t_0^2}, \qquad
   [E] = m_0 \ell_0^2 / t_0^2, \qquad
   [\rho] = m_0 / \ell_0^3.

Common choices for disc simulations are
:math:`\ell_0 = \mathrm{au}`, :math:`m_0 = M_\odot`,
:math:`t_0 = \mathrm{yr}/2\pi` (which gives :math:`G = 1` exactly for
a 1 au orbit around 1 :math:`M_\odot`).  For stellar setups one typically
uses :math:`\ell_0 = R_\odot` and :math:`m_0 = M_\odot`.  The
``set_units`` wrapper accepts these choices as string or real arguments
and passes them to the lower-level unit-conversion machinery.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_units.f90
