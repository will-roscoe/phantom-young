.. phantom-doc: hand-written

relax_star
==========

Overview
--------

The ``relax_star`` module iteratively drives a freshly constructed stellar
particle distribution to hydrostatic equilibrium.  After ``set_star``
maps particles onto a density profile, residual pressure-gradient and
gravity imbalances lead to oscillations and particle rearrangement.
``relax_star`` damps these motions by running a sequence of short SPH
integrations with a velocity-damping term proportional to the local
velocity, removing kinetic energy until the ratio of kinetic to
potential energy falls below a user-specified tolerance.

The relaxation loop writes periodic dump files so that the process can
be restarted, and it prints convergence diagnostics at each iteration.
The converged particle distribution is then used as the initial condition
for the actual simulation.  Runtime parameters ``maxits`` and
``tol_ekin`` control the maximum number of iterations and the
kinetic-energy tolerance respectively.

Physical & Mathematical Description
------------------------------------

At each relaxation step the SPH momentum equation is augmented with a
damping acceleration

.. math::

   \frac{d\mathbf{v}}{dt}\bigg|_\mathrm{damp} = -\alpha_\mathrm{damp}\,\mathbf{v},

where :math:`\alpha_\mathrm{damp}` is chosen to remove kinetic energy on
a timescale shorter than the dynamical time.  Convergence is assessed by
the ratio

.. math::

   \varepsilon = \frac{E_\mathrm{kin}}{|E_\mathrm{pot}|} < \epsilon_\mathrm{tol},

where :math:`E_\mathrm{kin} = \tfrac{1}{2}\sum_a m_a v_a^2` and
:math:`E_\mathrm{pot}` is the gravitational potential energy.  The
default tolerance ``tol_ekin`` is :math:`10^{-7}`.  The density profile
is re-evaluated after each iteration to check whether it has drifted from
the target, allowing the routine to reapply the stretch map if necessary.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/relax_star.f90
