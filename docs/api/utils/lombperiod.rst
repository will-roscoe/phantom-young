.. phantom-doc: hand-written

lombperiod
==========

Overview
--------

``lombperiod`` computes the Lomb-Scargle periodogram of an irregularly sampled time series from a Phantom mass flow (``.mflow``) file, enabling period detection in disc or binary simulations without requiring uniform time sampling. It uses the ``powerspectrum`` routine from the ``powerspectrums`` module to evaluate the power at each frequency.

The program reads a two-column ASCII file (time and data value) between user-specified times ``time1`` and ``time2``, then computes the power spectrum at ``nfreq = 5000`` frequencies up to ``maxfreq = maxmultiple * tbin`` where ``tbin`` is the binary orbital timescale. The output frequency and power arrays are written to a file for further analysis.

Usage is ``lombperiod time1 time2 *-colxxxxx.mflow file``. The periodogram peak frequency gives the dominant oscillation period in the selected data, which can be compared with the Keplerian orbital period of the binary.

Physical & Mathematical Description
------------------------------------

The Lomb-Scargle periodogram power at angular frequency :math:`\omega` is :math:`P(\omega) = \frac{1}{2\sigma^2}\left[\frac{(\sum_j x_j \cos(\omega(t_j-\tau)))^2}{\sum_j \cos^2(\omega(t_j-\tau))} + \frac{(\sum_j x_j \sin(\omega(t_j-\tau)))^2}{\sum_j \sin^2(\omega(t_j-\tau))}\right]`, where :math:`\tau` is the phase shift that removes the cross terms, :math:`x_j` is the data value at time :math:`t_j`, and :math:`\sigma^2` is the data variance. The routine uses the ``powerspectrum`` module which implements this via complex exponential sums.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/lombperiod.f90
