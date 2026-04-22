.. phantom-doc: hand-written

set_star_utils
==============

Overview
--------

The ``set_star_utils`` module collects the low-level utility routines
shared by ``set_star``, the core-replacement modules, and any other
setup code that works with 1D stellar profiles.  Its responsibilities
include interpolating tabulated :math:`[\rho(m), P(m), T(m)]` profiles
onto the SPH particle mass coordinate, computing global energetics (binding
energy, gravitational potential energy), and writing diagnostic output
files that record the stellar density and pressure profiles after particle
placement.

The module also defines the integer profile-type flags (``ikepler``,
``imesa``, ``ipoly``, etc.) used throughout the star-setup chain to
select the correct profile reader and EOS handler.  Centralising these
flags here avoids hard-coded magic numbers in the calling modules and
makes it straightforward to add new profile types.

Physical & Mathematical Description
------------------------------------

Interpolation from the 1D profile grid to SPH particle positions uses
linear interpolation in enclosed mass :math:`m`.  For a particle at
radius :math:`r` with enclosed mass :math:`m_r`, the density is

.. math::

   \rho(r) = \rho_\mathrm{tab}(m_r),

where :math:`\rho_\mathrm{tab}` is the tabulated profile.  The
gravitational binding energy is computed as

.. math::

   E_\mathrm{bind} = -\int_0^{M_\star}
                      \frac{G m}{r(m)}\,dm
                    = -\sum_{a} m_a\,\frac{G M(<r_a)}{r_a},

where the sum runs over all SPH particles.  This quantity is used both as
a convergence diagnostic during relaxation and as a sanity check against
the analytic result for polytropes.  Subroutines for writing the profile
to a text file and for reading it back allow the modified (cored) profile
to be passed between stages of the setup pipeline without re-computation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_star_utils.f90
