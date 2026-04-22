.. phantom-doc: hand-written

set_vfield
==========

Overview
--------

The ``set_vfield`` module sets up initial velocity fields on an existing
SPH particle distribution.  It supports three main velocity configurations:
turbulent (random-phase Fourier modes), Keplerian rotation (for disc
setups), and solid-body rotation.  For turbulent fields the module
generates a divergence-free random velocity field with a power spectrum
:math:`P(k) \propto k^{-n}` and then normalises it to a target Mach
number or kinetic energy using the ``normalise_vfield`` routine.

The module is used both for standalone turbulent-cloud setups and for
adding turbulent perturbations to stellar or disc distributions.  The
divergence-free condition is enforced by projecting the random Fourier
modes onto the plane perpendicular to the wave vector before inverse-
transforming, which is equivalent to taking the curl of a random vector
potential.

Physical & Mathematical Description
------------------------------------

A turbulent velocity field is constructed by superposing Fourier modes,

.. math::

   \mathbf{v}(\mathbf{r}) = \sum_{\mathbf{k}}
   \hat{\mathbf{v}}_\mathbf{k}\,e^{i\mathbf{k}\cdot\mathbf{r}},

where the amplitudes are drawn from a Rayleigh distribution with variance
:math:`P(k)` and the phases are uniformly random.  The solenoidal
projection

.. math::

   \hat{\mathbf{v}}_\mathbf{k} \to
   \hat{\mathbf{v}}_\mathbf{k}
   - \frac{(\hat{\mathbf{v}}_\mathbf{k}\cdot\hat{\mathbf{k}})\,\hat{\mathbf{k}}}
          {|\hat{\mathbf{k}}|^2}

removes the compressible component.  The resulting field is then
interpolated to particle positions and normalised so that either the
rms Mach number :math:`\mathcal{M} = \sigma_v / c_s` or the total
kinetic energy equals the specified target value.  For Keplerian rotation
the azimuthal velocity is :math:`v_\phi = \sqrt{GM/R}` corrected for
pressure support.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_vfield.f90
