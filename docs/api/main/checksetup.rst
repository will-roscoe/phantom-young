.. phantom-doc: hand-written

checksetup
==========

Overview
--------

The ``checksetup`` module performs a comprehensive sanity check of the
initial particle configuration before the time integration starts. The
single public subroutine ``check_setup`` examines the particle arrays and
runtime parameters, returning the number of errors ``nerror`` and warnings
``nwarn`` found.

Array dimension checks verify that ``npart`` does not exceed ``maxp`` and
that the ``npartoftype`` counts are consistent and non-negative. Individual
particle checks loop over all particles and flag those with non-positive or
NaN smoothing lengths, NaN positions or velocities, or incorrect particle
type labels. Sink particle checks verify that no two sinks overlap within
their accretion radii and that the accretion radii are physically reasonable.
EOS and unit checks ensure that the equation of state is self-consistent with
the initial conditions and that G is unity if self-gravity is enabled.

Several checks are suppressed on restart (when ``restart = .true.``) because
quantities like the centre of mass may legitimately differ from zero after
evolution. Dead or accreted particles are cleaned up via ``kill_particle``
and ``shuffle_part`` as a side effect of the check.

Physical & Mathematical Description
------------------------------------

The smoothing-length check flags particles with :math:`h \leq 0` or
:math:`h = \mathrm{NaN}`, which would cause division-by-zero in the density
summation :math:`\rho_i = m_i \sum_j W(|\mathbf{r}_{ij}|/h_i, h_i)`. The
sink overlap check verifies :math:`|\mathbf{r}_a - \mathbf{r}_b| >
h_\text{acc,a} + h_\text{acc,b}` for all sink pairs. These conditions are
necessary (but not sufficient) for a numerically stable SPH integration.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

.. seealso::

   :doc:`evolve_massloading` — mass loading parameters validated by this module when ``-DMASS_LOADING`` is set.

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/checksetup.f90
