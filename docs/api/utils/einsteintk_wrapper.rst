.. phantom-doc: hand-written

einsteintk_wrapper
==================

Overview
--------

``einsteintk_wrapper`` is the top-level interface module that couples Phantom to the Einstein Toolkit (ET), following the approach of Magnall et al. (2023, Phys. Rev. D 108, 103534). It exposes Fortran-callable routines (``init_et2phantom``, ``step_et2phantom``) that allow ET to drive Phantom as a matter evolution code within the Cactus computational framework.

The ``init_et2phantom`` routine initialises Phantom from an input file, sets up the MPI communicator shared with ET, and prepares the grid data structures. The ``step_et2phantom`` routine advances the SPH particles by one ET time step, recomputes the stress-energy tensor on the ET grid, and returns control to ET for the metric evolution step. This design allows two-way coupling between the matter (SPH) and spacetime (ET) evolution.

The wrapper handles unit conversion between Phantom's internal units and the geometrised units used by ET, and manages the synchronisation of dump and evolution file output between the two codes.

Physical & Mathematical Description
------------------------------------

The coupled system solves the Einstein equations :math:`G_{\mu\nu} = 8\pi T_{\mu\nu}` (Einstein Toolkit, BSSN/moving puncture) simultaneously with the relativistic SPH equations of motion for the matter. At each ET time step, Phantom updates the particle positions and velocities via the SPH momentum equation :math:`\frac{Du^\mu}{d\tau} = -\frac{1}{\rho_0 h} \nabla^\mu P + f^\mu_\mathrm{visc}`, then maps :math:`T^{\mu\nu}` back to the ET grid for the next metric step.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/einsteintk_wrapper.f90
