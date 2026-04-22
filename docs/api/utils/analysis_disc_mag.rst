.. phantom-doc: hand-written

analysis_disc_mag
=================

Overview
--------

``analysis_disc_mag`` computes radial profiles of magnetic field quantities in a magnetised accretion disc, adapted from a routine by Chris Nixon by Rebecca Nealon. It uses ``analysistype = 'MRI'`` and targets studies of the magneto-rotational instability (MRI) and disc magnetic stress.

The routine bins particles into ``nr = 300`` radial annuli and computes azimuthally averaged profiles of the magnetic field components :math:`B_r`, :math:`B_\phi`, :math:`B_z`, the Maxwell stress :math:`-B_r B_\phi / (4\pi)`, and the ratio of magnetic to thermal pressure :math:`\beta_\mathrm{mag} = P / (B^2 / 8\pi)`. The tilt of the angular momentum vector is also tracked.

Output files (named ``MRI_NNN``) allow the growth and saturation of MRI-driven turbulence to be characterised as a function of radius and time.

Physical & Mathematical Description
------------------------------------

The Maxwell stress component responsible for angular momentum transport in a disc is :math:`T_{r\phi}^\mathrm{Maxwell} = -B_r B_\phi / (4\pi \rho)`. The plasma beta parameter is :math:`\beta_\mathrm{mag} = P_\mathrm{thermal} / P_\mathrm{mag}` with :math:`P_\mathrm{mag} = B^2 / (8\pi)`. MRI growth requires :math:`\beta_\mathrm{mag} > 1` and a vertical field wavelength :math:`\lambda_\mathrm{MRI} \sim v_A / \Omega < H`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_disc_mag.f90`` for the complete source.
