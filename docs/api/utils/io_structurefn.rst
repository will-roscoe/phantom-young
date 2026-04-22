.. phantom-doc: hand-written

io_structurefn
==============

Overview
--------

``io_structurefn`` is a module for reading and writing velocity structure function data in multiple file formats: ASCII (``_longd.struct``, ``_trans.struct``), split format (``_longd1.struct``, ``_trans1.struct``, etc.), KITP format (``.sfn``), and the Federrath et al. format (``_SF_*.dat``). It is used by ``analysis_structurefn``, ``get_struct_slope``, and ``struct2struct``.

The module provides ``read_structurefn`` and ``write_structurefn`` routines that handle the format conversion transparently, together with helper functions for format detection. The ``sftype`` array labels the two structure function types as ``'longitudinal'`` and ``'transverse'``.

This module ensures that structure function data computed in Phantom can be read by other analysis tools and compared with published results from different numerical codes that use different file format conventions.

Physical & Mathematical Description
------------------------------------

A structure function file stores the lag array :math:`\ell_k` (in code units), the order array :math:`p_m`, and the structure function values :math:`S_p^{L,T}(\ell_k)` for each lag and order pair. The ``power_unit = 14`` file unit is reserved for structure function power law fit output. Each format uses a different header convention to specify the number of lags, orders, and the normalisation of the structure function.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/io_structurefn.f90
