.. phantom-doc: hand-written

analysis_bzrms
====================================================================================================================================================================================================

Overview
--------

``analysis_bzrms`` computes the root-mean-square magnetic field component :math:`B_{z,\mathrm{rms}}` as a function of time in MHD wave test simulations. It is designed for fixed-coefficient ambipolar diffusion and Hall effect tests where analytic solutions are available, enabling direct comparison of the SPH result with theory.

The routine reads the magnetic field array ``Bxyz`` from each dump and computes the instantaneous :math:`B_{z,\mathrm{rms}}`, averaging over all particles. Parameters for the ambient state and wave amplitude are read from a parameter file on the first call.

Output is written to a time-series file, allowing the decay or growth rate of the magnetic wave to be measured and compared with the analytic dispersion relation.

Physical & Mathematical Description
------------------------------------

The root-mean-square :math:`z`-component of the magnetic field is :math:`B_{z,\mathrm{rms}} = \sqrt{\langle B_z^2 \rangle}`, averaged over all particles. For a linearly polarised MHD wave with wavenumber :math:`k` and angular frequency :math:`\omega`, the analytic decay rate due to ambipolar diffusion is :math:`\gamma = C_{\mathrm{AD}} k^2 / (1 + \xi_n^{-1})`, where :math:`C_{\mathrm{AD}}` is the ambipolar diffusion coefficient and :math:`\xi_n` is the neutral fraction.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_bzrms.f90`` for the complete source.
