.. phantom-doc: hand-written

mflow
=====

Overview
--------

``mflow`` is a post-processing utility that reads a sequence of Phantom mass flow (``.mf``) files and integrates the mass flux through spherical shells, producing a time series of mass flow rates. It is the driver program for the ``mf_write`` module, which handles the column layout and radial bin definitions.

The program accepts a minimum time interval ``dt_min`` as the first argument and then one or more ``.mf`` filenames. It reads the mass flux column for each radial bin from each file, integrates over the minimum time interval, and writes the result to an output file. The radial bin edges are read from the ``nradi`` variable in ``mf_write``.

The output file contains columns for time and the mass flow rate through each radial shell, enabling accretion rates as a function of radius to be measured and compared with disc evolution models.

Physical & Mathematical Description
------------------------------------

The mass flow rate through a spherical shell at radius :math:`r_k` is :math:`\dot{M}_k = \oint_{S_k} \rho \mathbf{v} \cdot \hat{\mathbf{n}} \, dA`, approximated in SPH as :math:`\dot{M}_k = \sum_{i: |r_i - r_k| < \Delta r/2} m_i v_{r,i} / \Delta t` for particles crossing the shell in time :math:`\Delta t`. The radial bins are defined in ``mf_write`` and the number of radii is ``nradi``.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/mflow.f90
