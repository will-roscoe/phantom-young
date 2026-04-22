.. phantom-doc: hand-written

analysis_protostar_environ
==========================

Overview
--------

``analysis_protostar_environ`` characterises the environment around protostellar objects in star formation simulations. Based on the analysis of Price & Bate (2007) and Wurster, Price & Bate (2016), it identifies disc particles as those above a density threshold of :math:`10^{-13}` g cm:math:`^{-3}` and computes the disc radius as the radius enclosing 99% of the disc mass.

The routine handles gas, dust, and stellar disc components, computing separate radial mass and density profiles for each type. It uses the NICIL non-ideal MHD module when active to evaluate magnetic field diffusivities in the disc and envelope. Parameters are read from the simulation input file.

Output files record the disc radius, disc mass, and density profile at each dump, enabling the formation and early evolution of protostellar discs to be characterised quantitatively.

Physical & Mathematical Description
------------------------------------

Disc particles satisfy :math:`\rho_i > \rho_\mathrm{thresh} = 10^{-13}` g cm:math:`^{-3}` and lie within an angle ``angle`` of the midplane. The disc radius :math:`R_\mathrm{disc}` is the cylindrical radius enclosing 99% of the disc mass, obtained by sorting particles in cylindrical radius and integrating :math:`M_\mathrm{disc}(R) = \sum_{i: R_i < R} m_i` until :math:`M_\mathrm{disc}(R) = 0.99 M_\mathrm{disc,tot}`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_protostar_environ.F90`` for the complete source.
