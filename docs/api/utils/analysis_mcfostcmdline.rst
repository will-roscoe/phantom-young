.. phantom-doc: hand-written

analysis_mcfostcmdline
======================

Overview
--------

``analysis_mcfostcmdline`` is a stub version of the MCFOST interface that reads a temperature field previously computed by MCFOST and updates the SPH internal energy accordingly. Unlike ``analysis_mcfost``, this variant uses MCFOST as an external command-line tool rather than as a linked library, communicating via files.

The routine reads a temperature array ``T_SPH`` from a binary file previously written by MCFOST, converts temperatures to internal energies using the equation of state, and updates the ``vxyzu`` array. This decoupled approach allows MCFOST to be run separately (e.g. on a different cluster) with results imported into Phantom post-processing.

The conversion from temperature to specific internal energy uses :math:`u = k_B T / (\mu m_H (\gamma - 1))`, where :math:`\mu` is the mean molecular weight obtained from the EOS module.

Physical & Mathematical Description
------------------------------------

The specific internal energy corresponding to temperature :math:`T` is :math:`u = C_V T = k_B T / (\mu m_H (\gamma - 1))`, where :math:`C_V` is the specific heat at constant volume, :math:`k_B` is Boltzmann's constant, :math:`m_H` is the proton mass, and :math:`\mu` is the mean molecular weight ``gmw``. The routine uses the ``temperature_coef = k_B / (\mu m_H)`` pre-computed by the EOS module.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_mcfostcmdline.f90`` for the complete source.
