.. phantom-doc: hand-written

inject_galcen_winds
===================

Overview
--------

The ``inject_galcen_winds`` module (module name ``inject``,
``inject_type = 'galcen_winds'``) injects stellar wind particles from a
population of point-mass stars near the Galactic Centre, following the
approach of Cuadra et al. (2008). Each sink particle represents a
mass-losing star whose wind speed and mass-loss rate are read from an
external datafile (``winddata.txt``). Particles are injected isotropically
around each star at a rate proportional to :math:`\dot{M}`, with positions
distributed uniformly on a sphere using the ``ran2`` random number generator.

Runtime parameters are ``datafile`` (path to the wind data file) and
``outer_boundary`` (radius beyond which gas particles are removed). The module
reads the wind data at initialisation and accumulates per-star injection
counts to maintain the correct mass-flux ratio between stars with different
mass-loss rates. A ``first_iteration`` flag handles restarts by re-computing
the total number of particles already injected based on the elapsed time.

Physical & Mathematical Description
------------------------------------

For each star :math:`k` with mass-loss rate :math:`\dot{M}_k` and wind
velocity :math:`v_k`, the number of particles to inject in a time interval
:math:`\Delta t` is

.. math::

   N_\text{inject,k} = \left\lfloor \frac{\dot{M}_k \Delta t}{m_\text{SPH}} \right\rfloor
   - N_\text{already,k},

where :math:`m_\text{SPH}` is the SPH particle mass and
:math:`N_\text{already,k}` is the cumulative count for star :math:`k`. Each
injected particle is placed at a random position on a sphere of radius
:math:`r_\text{inj}` around the star and given velocity
:math:`v_k \hat{r} + \mathbf{v}_\star`, where :math:`\hat{r}` is the
outward radial unit vector and :math:`\mathbf{v}_\star` is the star's velocity.
The wind temperature is set from :math:`kT / (\mu m_H)` using the mean
molecular weight ``gmw`` and the equation of state module. Particles that
move beyond ``outer_boundary`` are killed each timestep.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note:: Autodoc not available for this file (excluded from Fortran index due to parser incompatibility).
