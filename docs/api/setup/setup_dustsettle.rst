.. phantom-doc: hand-written

setup_dustsettle
================

Overview
--------

``setup_dustsettle`` initialises the dust settling test of Price & Laibe (2015). A local patch of a protoplanetary disc is modelled at a specified orbital radius ``Rdisc`` as a shearing-sheet box, with gas particles on a uniform Cartesian lattice and dust particles initially well-mixed throughout the vertical column. A vertical gravitational acceleration :math:`g_z = -\Omega_K^2 z` is applied as an external force to drive dust grains toward the disc midplane.

Multiple dust species spanning a size distribution from ``smincgs`` to ``smaxcgs`` with a power-law index ``sindex`` can be included, allowing the simultaneous settling of grains with different aerodynamic stopping times. The gas density at the midplane ``rhozero`` and the aspect ratio ``HonR`` set the vertical density profile; dust-to-gas ratio is set separately for each species.

This setup is a standard benchmark for the Epstein drag regime and is used to verify that the SPH dust-gas drag implementation correctly reproduces the analytic settling layer height as a function of time, grain size, and the Stokes number.

Physical & Mathematical Description
------------------------------------

In the Epstein drag regime the stopping time is :math:`t_s = \rho_\mathrm{grain} s / (\rho_g c_s)`, where :math:`s` is the grain radius, :math:`\rho_\mathrm{grain}` is the grain material density, and :math:`\rho_g` is the local gas density. The equilibrium dust layer half-thickness is :math:`H_d = H_g \sqrt{\alpha / (\alpha + \mathrm{St})}`, where :math:`\mathrm{St} = t_s \Omega_K` is the Stokes number and :math:`\alpha` is the turbulent diffusion parameter. The settling timescale is :math:`t_\mathrm{settle} \approx 1/(\mathrm{St}\, \Omega_K)`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_dustsettle.f90`` for the complete source.
