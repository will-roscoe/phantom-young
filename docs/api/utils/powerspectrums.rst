.. phantom-doc: hand-written

powerspectrums
==============

Overview
--------

``powerspectrums`` is a module providing the ``powerspectrum`` routine for computing power spectra of irregularly sampled scalar data as a function of frequency. It is used by ``lombperiod`` to evaluate the Lomb-Scargle periodogram of mass flow rate data from Phantom simulations.

The routine evaluates the discrete Fourier transform at each specified frequency using a direct summation over data points, which is correct for irregularly sampled data (unlike the FFT which requires uniform sampling). The output power array is proportional to the squared magnitude of the Fourier amplitude at each frequency.

For uniformly sampled data with ``npts`` points at frequencies ``freq(1:nfreqpts)``, the routine gives the same result as a standard FFT power spectrum but is applicable to arbitrary irregular sampling.

Physical & Mathematical Description
------------------------------------

The power spectrum at frequency :math:`f_k` is :math:`P(f_k) = |A(f_k)|^2 / n`, where the complex amplitude is :math:`A(f_k) = \sum_{j=1}^n x_j e^{-2\pi i f_k t_j}`, :math:`x_j` is the data value at time :math:`t_j`, and :math:`n` is the number of data points. For the Lomb-Scargle normalisation, this is further divided by twice the data variance :math:`\sigma^2 = \langle x^2 \rangle - \langle x \rangle^2`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/powerspectrums.f90
