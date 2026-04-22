.. phantom-doc: hand-written

mf_write
========

Overview
--------

The ``mf_write`` module provides diagnostic output routines for tracking
the radial mass flux and other flow quantities in Phantom simulations.
The module writes time-series files recording the accretion rate or mass
flow through a series of radial bins, enabling post-processing analysis of
accretion histories and disc structure evolution.

The public routines ``mflow_init`` and ``mflow_write`` manage the radial
mass-flow file (binned by radius), while ``vmflow_init`` and
``vmflow_write`` manage a similar file for volumetric flow. The
``binpos_init`` and ``binpos_write`` routines write a companion file of
particle positions binned by radius. The ``flow_analysis`` routine performs
an on-the-fly analysis of the mass flux through each radial shell.

Physical & Mathematical Description
------------------------------------

The radial mass flux through a shell of radius :math:`r` is computed by
binning SPH particles into ``nradi`` radial shells of equal width up to
``maxradius`` and summing the contribution :math:`\dot{M}(r) = \sum_i m_i
v_{r,i} \delta(r - r_i)` per time interval. The resulting time-series files
can be integrated to give cumulative accreted mass as a function of time
and disc radius, useful for comparing with analytic viscous disc evolution
models.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/mf_write.f90
