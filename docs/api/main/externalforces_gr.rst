.. phantom-doc: hand-written

GR External Forces Dispatcher (externalforces_gr)
==================================================

Overview
--------

The ``externalforces_gr`` module is the general-relativistic replacement for Phantom's
standard ``externalforces`` module. It provides the same public interface — particle
accretion checks, options I/O, and time-dependent force updates — but operates entirely
within the GR framework, delegating to the active metric module for geometry-dependent
tasks.

In GR the concept of an "external force" in the Newtonian sense is replaced by the
curvature source term evaluated in ``extern_gr``. As a result, the force evaluation
routines ``externalforce`` and ``externalforce_vdependent`` in this module are stubs that
return zero: the actual GR momentum source is computed separately. The module's primary
roles are (1) managing the soft and hard accretion radii ``accradius1`` and
``accradius1_hard``, (2) delegating particle accretion checks to the underlying metric
module via ``accrete_particles_metric``, (3) calling ``update_metric(t)`` at each
timestep to advance time-dependent metrics (important for the binary BH metric), and
(4) verifying that the code units satisfy :math:`G = c = 1` through
``initialise_externalforces``.

The module exposes ``mass1`` and ``a`` from the metric module as public quantities,
allowing other parts of the code to access the BH mass and spin without directly importing
the metric module.

Physical & Mathematical Description
-------------------------------------

In GR hydrodynamics the curvature coupling already captures all gravitational effects. The
momentum equation reads:

.. math::

   \frac{\mathrm{d}p_i}{\mathrm{d}t} = f_i^{\rm GR} + f_i^{\rm hydro}

where :math:`f_i^{\rm GR} = \tfrac{1}{2}T^{\mu\nu}\partial_i g_{\mu\nu}` is computed by
``extern_gr`` and :math:`f_i^{\rm hydro}` is the SPH pressure gradient. No additional
external force enters.

Particle accretion is based on a two-radius scheme:

- **Soft radius** :math:`r_{\rm soft} = r_1 \cdot M`: particles inside this radius are
  reclassified as boundary particles (rendered inert) if the phase-array is active.
- **Hard radius** :math:`r_{\rm hard} \leq r_{\rm soft}`: particles with
  :math:`r < r_{\rm hard}` are unconditionally accreted (smoothing length set negative).

For the binary BH metric the accretion condition is delegated to
``accrete_particles_metric`` in ``metric_binarybh``, which checks proximity to either
black hole.

Time-dependent metrics (binary BH, FLRW) require ``update_metric(t)`` to be called
before each force evaluation. The metric is updated via ``update_externalforce``.

References
----------

Liptai & Price (2019), MNRAS 485, 819 — not yet in phantom.bib.

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::
   Autodoc is not available for this file (excluded from the Fortran source index due to duplicate module name or parser incompatibility). The source file is :file:`src/main/externalforces_gr.f90`.
